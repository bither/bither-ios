//
//  ImportBip38PrivateKeySetting.m
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

#import "ImportBip38PrivateKeySetting.h"
#import "BTPasswordSeed.h"
#import "DialogProgress.h"
#import "BTKey+BIP38.h"
#import "DialogCentered.h"
#import "DialogWithActions.h"
#import "AppDelegate.h"
#import "PeerUtil.h"

@interface CheckPasswordBip38Delegate : NSObject <DialogPasswordDelegate>
@property(nonatomic, strong) UIViewController *controller;
@property(nonatomic, strong) NSString *privateKeyStr;
@property(nonatomic, strong) NSString *password;
@end

@implementation CheckPasswordBip38Delegate

- (void)onPasswordEntered:(NSString *)password {
    self.password = password;
    NSMutableArray *actions = [NSMutableArray new];
    [actions addObject:[[Action alloc]initWithName:NSLocalizedString(@"get data from_bither.net", nil) target:self andSelector:@selector(tapFromBitherToGetTxData)]];
    [actions addObject:[[Action alloc]initWithName:NSLocalizedString(@"get data from_blockChain.info", nil) target:self andSelector:@selector(tapFromBlockChainToGetTxData)]];
    [[[DialogWithActions alloc]initWithActions:actions]showInWindow:self.controller.view.window];
}
#pragma mark - tapFromBitherToGetTxData
- (void)tapFromBitherToGetTxData{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.importType = BITHER_NET;
    ImportPrivateKey *improtPrivateKey = [[ImportPrivateKey alloc] initWithController:self.controller content:self.privateKeyStr passwrod:self.password importPrivateKeyType:PrivateText];
    [improtPrivateKey importPrivateKey];
}
#pragma mark - tapFromBlockChainToGetTxData
- (void)tapFromBlockChainToGetTxData{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.importType = BLOCK_CHAIN_INFO;
    ImportPrivateKey *improtPrivateKey = [[ImportPrivateKey alloc] initWithController:self.controller content:self.privateKeyStr passwrod:self.password importPrivateKeyType:PrivateText];
    [improtPrivateKey importPrivateKey];
}

@end


@implementation ImportBip38PrivateKeySetting

static Setting *importPrivateKeySetting;


+ (Setting *)getImportBip38PrivateKeySetting {
    if (!importPrivateKeySetting) {
        ImportBip38PrivateKeySetting *scanPrivateKeySetting = [[ImportBip38PrivateKeySetting alloc] initWithName:NSLocalizedString(@"Import BIP38-private key", nil) icon:nil];
        __weak ImportBip38PrivateKeySetting *sself = scanPrivateKeySetting;
        [scanPrivateKeySetting setSelectBlock:^(UIViewController *controller) {
            sself.controller = controller;
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Import BIP38-private key", nil)
                                                                     delegate:sself cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:NSLocalizedString(@"From BIP38-private key QR Code", nil), NSLocalizedString(@"From BIP38-private key text", nil), nil];

            actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            [actionSheet showInView:controller.navigationController.view];
        }];
        importPrivateKeySetting = scanPrivateKeySetting;
    }
    return importPrivateKeySetting;
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc] initWithDelegate:self title:NSLocalizedString(@"Scan BIP38-private key QR Code", nil) message:@""];
        [self.controller presentViewController:scan animated:YES completion:nil];
    } else if (buttonIndex == 1) {
        DialogImportPrivateKey *dialogImportPrivateKey = [[DialogImportPrivateKey alloc] initWithDelegate:self importPrivateKeyType:Bip38];
        [dialogImportPrivateKey showInWindow:self.controller.view.window];
    }
}

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
    if ([result isValidBitcoinBIP38Key]) {
        _result = result;
        [reader playSuccessSound];
        [reader vibrate];
        [reader.presentingViewController dismissViewControllerAnimated:YES completion:^{
            DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
            [dialog showInWindow:self.controller.view.window];

        }];
    } else {
        [reader vibrate];
    }

}

- (void)importKeyFormQrcode:(NSString *)keyStr password:(NSString *)password dp:(DialogProgress *)dp {
    [dp dismiss];
    ImportPrivateKey *importPrivateKey = [[ImportPrivateKey alloc] initWithController:self.controller content:keyStr passwrod:password importPrivateKeyType:BitherQrcode];
    [importPrivateKey importPrivateKey];
}

- (BOOL)checkPassword:(NSString *)password {
    _key = [BTKey keyWithBIP38Key:_result andPassphrase:password];
    return _key != nil;
}

- (void)onPasswordEntered:(NSString *)password {
    [self showCheckPassword:[_key privateKey]];
}

- (NSString *)passwordTitle {
    return NSLocalizedString(@"Enter password of BIP38-private key", nil);
}


//delegate of dialogImportPrivateKey
- (void)onPrivateKeyEntered:(NSString *)privateKey {
    _result = privateKey;
    DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
    [dialog showInWindow:self.controller.view.window];
}

static CheckPasswordBip38Delegate *checkPasswordDelegate;

- (void)showCheckPassword:(NSString *)privateKey {
    checkPasswordDelegate = [[CheckPasswordBip38Delegate alloc] init];
    checkPasswordDelegate.controller = self.controller;
    checkPasswordDelegate.privateKeyStr = privateKey;

    DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:checkPasswordDelegate];
    [dialog showInWindow:self.controller.view.window];
}

- (void)showMsg:(NSString *)msg {
    if ([self.controller respondsToSelector:@selector(showMsg:)]) {
        [self.controller performSelector:@selector(showMsg:) withObject:msg];
    }

}

@end
