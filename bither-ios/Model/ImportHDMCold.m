#import "ImportHDMCold.h"
#import "DialogProgress.h"
#import "BTHDMKeychain.h"
#import "KeyUtil.h"
#import "BTBIP39.h"


@interface ImportHDMCold ()
@property(nonatomic, strong) NSString *passwrod;
@property(nonatomic, strong) NSString *content;
@property(nonatomic, readwrite) ImportHDSeedType importHDSeedType;
@property(nonatomic, weak) UIViewController *controller;
@property(nonatomic, strong) DialogProgress *dp;
@property(nonatomic, strong) NSArray *worldList;
@end

@implementation ImportHDMCold {

}

- (instancetype)initWithController:(UIViewController *)controller content:(NSString *)content worldList:(NSArray *)array passwrod:(NSString *)passwrod importHDSeedType:(ImportHDSeedType)importHDSeedType {
    self = [super init];
    if (self) {
        self.passwrod = passwrod;
        self.content = content;
        self.importHDSeedType = importHDSeedType;
        self.controller = controller;
        self.worldList = array;
    }
    return self;
}

- (void)importHDSeed {
    self.dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    [self.dp showInWindow:self.controller.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            switch (self.importHDSeedType) {
                case HDMColdSeedQRCode: {
                    NSString *keyStr = [self.content substringFromIndex:1];
                    BTHDMKeychain *keychain = [[BTHDMKeychain alloc] initWithEncrypted:keyStr password:self.passwrod andFetchBlock:nil];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self exit];
                        if (keychain == nil) {
                            [self showMsg:NSLocalizedString(@"Import failed.", nil)];
                        } else {
                            [KeyUtil setHDKeyChain:keychain];
                            [self showMsg:NSLocalizedString(@"Import success.", nil)];
                        }

                    });
                    break;
                }
                case  HDMColdPhrase: {
                    BTBIP39 *btbip39 = [BTBIP39 sharedInstance];
                    NSString *code = [btbip39 toMnemonicWithArray:self.worldList];
                    NSData *mnemonicCodeSeed = [btbip39 toEntropy:code];
                    if (mnemonicCodeSeed == nil) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self exit];
                            [self showMsg:NSLocalizedString(@"import_hdm_cold_seed_format_error", nil)];
                        });
                    } else {
                        BTHDMKeychain *keychain = [[BTHDMKeychain alloc] initWithMnemonicSeed:mnemonicCodeSeed password:self.passwrod andXRandom:NO];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self exit];
                            if (keychain == nil) {
                                [self showMsg:NSLocalizedString(@"Import failed.", nil)];
                            } else {
                                [KeyUtil setHDKeyChain:keychain];
                                [self.controller.navigationController popViewControllerAnimated:YES];

                                [self showMsg:NSLocalizedString(@"Import success.", nil)];
                            }

                        });
                    }
                    break;
                }
            }
        });

    }];
}

- (void)showMsg:(NSString *)msg {
    if ([self.controller respondsToSelector:@selector(showMsg:)]) {
        [self.controller performSelector:@selector(showMsg:) withObject:msg];
    }

}

- (void)exit {
    self.passwrod = nil;
    self.content = nil;
    [self.dp dismiss];

}


@end