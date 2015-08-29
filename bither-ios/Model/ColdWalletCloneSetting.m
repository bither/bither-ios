//
//  CloneQrCodeSetting.m
//  bither-ios
//
//  Copyright 2014 http://Bither.net
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


#import "ColdWalletCloneSetting.h"
#import "ScanQrCodeTransportViewController.h"
#import "DialogProgress.h"
#import "BTQRCodeUtil.h"
#import "KeyUtil.h"
#import "CloneQrCodeSetting.h"
#import "BTAddressManager.h"


static Setting *CloneScanSetting;
static Setting *CloneQrSetting;

@implementation ColdWalletCloneSetting

- (instancetype)init {
    self = [super initWithName:NSLocalizedString(@"Cold Wallet Clone", nil) icon:[UIImage imageNamed:@"scan_button_icon"]];
    if (self) {
        __weak ColdWalletCloneSetting *d = self;
        [self setSelectBlock:^(UIViewController *controller) {
            d.scanContent = nil;
            d.controller = controller;
            ScanQrCodeTransportViewController *scan = [[ScanQrCodeTransportViewController alloc] initWithDelegate:d title:NSLocalizedString(@"Scan The Clone Source", nil) pageName:NSLocalizedString(@"clone QR code", nil)];
            [controller presentViewController:scan animated:YES completion:nil];
        }];
    }
    return self;
}

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
    [reader.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if ([BTQRCodeUtil splitQRCode:result].count % 3 == 0) {
            self.scanContent = result;
            DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
            [dialog showInWindow:self.controller.view.window];
        } else {
            [self showMsg:NSLocalizedString(@"Clone failed.", nil)];
        }
    }];
}

- (void)onPasswordEntered:(NSString *)password {
    DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Cloning...", nil)];
    [dp showInWindow:self.controller.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *commponent = [BTQRCodeUtil splitQRCode:self.scanContent];
            BTHDMKeychain *keychain = nil;
            NSMutableArray *keys = [[NSMutableArray alloc] init];
            BOOL result = NO;
            @try {
                for (int i = 0; i < commponent.count; i += 3) {
                    if ([commponent[i] rangeOfString:HDM_QR_CODE_FLAG].location == 0) {
                        NSString *s = [BTQRCodeUtil joinedQRCode:[commponent subarrayWithRange:NSMakeRange(i, 3)]];
                        s = [s substringFromIndex:1];
                        keychain = [[BTHDMKeychain alloc] initWithEncrypted:s password:password andFetchBlock:nil];
                    } else if([commponent[i] rangeOfString:HD_QR_CODE_FLAT].location == 0){
                        NSString *s = [BTQRCodeUtil joinedQRCode:[commponent subarrayWithRange:NSMakeRange(i, 3)]];
                        s = [s substringFromIndex:1];
                        [[BTHDAccountCold alloc]initWithEncryptedMnemonicSeed:[[BTEncryptData alloc]initWithStr:s] andPassword:password];
                    } else {
                        NSString *s = [BTQRCodeUtil joinedQRCode:[commponent subarrayWithRange:NSMakeRange(i, 3)]];
                        [keys addObject:s];
                    }
                }
                result = YES;
            }
            @catch (NSException *exception) {
                result = NO;
            }
            if(result){
                if (keychain) {
                    [KeyUtil setHDKeyChain:keychain];
                }
                result = [KeyUtil addBitcoinjKey:keys withPassphrase:password error:nil];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.controller respondsToSelector:@selector(reload)]) {
                    [self.controller performSelector:@selector(reload)];
                }
                [dp dismissWithCompletion:^{
                    [self showMsg:result ? NSLocalizedString(@"Clone success.", nil) : NSLocalizedString(@"Clone failed.", nil)];
                }];
            });
        });
    }];
}

- (BOOL)notToCheckPassword {
    return YES;
}

- (NSString *)passwordTitle {
    return NSLocalizedString(@"Enter source password", nil);
}

- (void)showMsg:(NSString *)msg {
    if ([self.controller respondsToSelector:@selector(showMsg:)]) {
        [self.controller performSelector:@selector(showMsg:) withObject:msg];
    }
}

+ (Setting *)getCloneSetting {
    if ([BTAddressManager instance].privKeyAddresses.count > 0 || [[BTAddressManager instance] hasHDMKeychain] || [BTAddressManager instance].hasHDAccountCold) {
        if (!CloneQrSetting) {
            CloneQrSetting = [[CloneQrCodeSetting alloc] init];
        }
        return CloneQrSetting;
    } else {
        if (!CloneScanSetting) {
            CloneScanSetting = [[ColdWalletCloneSetting alloc] init];
        }
        return CloneScanSetting;
    }
}

@end
