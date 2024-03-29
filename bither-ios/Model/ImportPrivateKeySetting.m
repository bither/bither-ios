//
//  ScanPrivateKeyDelegate.m
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

#import <Bitheri/BTAddressProvider.h>
#import "ImportPrivateKeySetting.h"
#import "DialogProgress.h"
#import "BTAddressManager.h"
#import "BTQRCodeUtil.h"
#import "ImportHDMCold.h"
#import "ImportHDMColdSeedController.h"
#import "ImportHDAccountSeedController.h"
#import "PeerUtil.h"
#import "DialogCentered.h"
#import "DialogWithActions.h"
#import "AppDelegate.h"
#import "BTWordsTypeManager.h"
#import "DialogImportHdAccountSeedQrCodeSelectLanguage.h"

@interface CheckPasswordDelegate : NSObject <DialogPasswordDelegate, DialogImportHdAccountSeedQrCodeSelectLanguageDelegate>

@property(nonatomic, strong) UIViewController *controller;
@property(nonatomic, strong) NSString *privateKeyStr;

@end

@implementation CheckPasswordDelegate
#pragma mark - Get transactions data option phrase
- (void)onPasswordEntered:(NSString *)password {
    ImportPrivateKey *improtPrivateKey = [[ImportPrivateKey alloc] initWithController:self.controller content:self.privateKeyStr passwrod:password importPrivateKeyType:PrivateText];
    [improtPrivateKey importPrivateKey];
}
@end


@interface ImportPrivateKeySetting ()

@property(nonatomic, readwrite) BOOL isImportHDM;
@property(nonatomic, readwrite) BOOL isImportHDAccount;
@property NSArray *buttons;
@property (nonatomic,strong)NSString *keyStr;
@property(nonatomic, strong) NSString *selectHdWordList;

@end

@implementation ImportPrivateKeySetting

static Setting *importPrivateKeySetting;
+ (Setting *)getImportPrivateKeySetting {
    if (!importPrivateKeySetting) {
        ImportPrivateKeySetting *scanPrivateKeySetting = [[ImportPrivateKeySetting alloc] initWithName:NSLocalizedString(@"Import Private Key", nil) icon:nil];
        __weak ImportPrivateKeySetting *sself = scanPrivateKeySetting;
        [scanPrivateKeySetting setSelectBlock:^(UIViewController *controller) {
            sself.controller = controller;
            NSMutableArray *buttons = [NSMutableArray new];
            UIActionSheet *actionSheet = nil;
            [buttons addObjectsFromArray:@[NSLocalizedString(@"From Bither Private Key QR Code", nil), NSLocalizedString(@"From Private Key Text", nil)]];
            if ([[BTSettings instance] getAppMode] == COLD && ![[BTAddressManager instance] hasHDMKeychain]) {
                [buttons addObjectsFromArray:@[NSLocalizedString(@"import_hdm_cold_seed_qr_code", nil), NSLocalizedString(@"import_hdm_cold_seed_phrase", nil)]];
            }
            if (([BTSettings instance].getAppMode == COLD && ![BTAddressManager instance].hasHDAccountCold) || ([BTSettings instance].getAppMode == HOT && ![BTAddressManager instance].hasHDAccountHot)) {
                [buttons addObjectsFromArray:@[NSLocalizedString(@"import_hd_account_seed_qr_code", nil), NSLocalizedString(@"import_hd_account_seed_phrase", nil)]];
            }
            actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Import Private Key", nil) delegate:sself cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            for (NSString *title in buttons) {
                [actionSheet addButtonWithTitle:title];
            }
            [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
            actionSheet.cancelButtonIndex = buttons.count;
            sself.buttons = buttons;
            actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            [actionSheet showInView:controller.navigationController.view];
        }];
        importPrivateKeySetting = scanPrivateKeySetting;
    }
    return importPrivateKeySetting;
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex < 0 || buttonIndex >= self.buttons.count || buttonIndex == actionSheet.cancelButtonIndex){
        return;
    }
    NSString *button = [self.buttons objectAtIndex:buttonIndex];
    if ([StringUtil isEmpty:button]) {
        return;
    }
    self.isImportHDM = NO;
    self.isImportHDAccount = NO;
    if ([StringUtil compareString:button compare:NSLocalizedString(@"From Bither Private Key QR Code", nil)]) {
        [self scanQRCodeWithPrivateKey];
    } else if ([StringUtil compareString:button compare:NSLocalizedString(@"From Private Key Text", nil)]) {
        [self importPrivateKey];
    } else if ([StringUtil compareString:button compare:NSLocalizedString(@"import_hdm_cold_seed_qr_code", nil)]) {
        self.isImportHDM = YES;
        [self scanQRCodeWithHDMColdSeed];
    } else if ([StringUtil compareString:button compare:NSLocalizedString(@"import_hdm_cold_seed_phrase", nil)]) {
        self.isImportHDM = YES;
        [self importWithHDMColdPhrase];
    } else if ([StringUtil compareString:button compare:NSLocalizedString(@"import_hd_account_seed_qr_code", nil)]) {
        self.isImportHDAccount = YES;
        [self scanQRCodeWithHDAccount];
    } else if ([StringUtil compareString:button compare:NSLocalizedString(@"import_hd_account_seed_phrase", nil)]) {
        self.isImportHDAccount = YES;
        [self importWithHDAccountPhrase];
    }
}

- (void)scanQRCodeWithHDAccount {
    ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc] initWithDelegate:self title:NSLocalizedString(@"import_hd_account_seed_qr_scan_title", nil) message:NSLocalizedString(@"import_hd_account_seed_qr_scan_message", nil)];
    scan.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.controller presentViewController:scan animated:YES completion:nil];
}

- (void)importWithHDAccountPhrase {
    ImportHDAccountSeedController *vc = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"ImportHDAccountSeed"];
    [self.controller.navigationController pushViewController:vc animated:YES];
}

- (void)scanQRCodeWithPrivateKey {
    ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc] initWithDelegate:self title:NSLocalizedString(@"Scan Private Key QR Code", nil) message:NSLocalizedString(@"Scan QR code No.1 provided by Bither", nil)];
    scan.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.controller presentViewController:scan animated:YES completion:nil];
}

- (void)importPrivateKey {
    DialogImportPrivateKey *dialogImportPrivateKey = [[DialogImportPrivateKey alloc] initWithDelegate:self importPrivateKeyType:PrivateText];
    [dialogImportPrivateKey showInWindow:self.controller.view.window];
}

- (void)scanQRCodeWithHDMColdSeed {
    ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc] initWithDelegate:self title:NSLocalizedString(@"import_hdm_cold_seed_qr_code_scan_title", nil) message:NSLocalizedString(@"Scan QR code No.1 provided by Bither", nil)];
    scan.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.controller presentViewController:scan animated:YES completion:nil];

}

- (void)importWithHDMColdPhrase {
    ImportHDMColdSeedController *advanceController = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"ImportHDMColdSeedController"];
    UINavigationController *nav = self.controller.navigationController;
    [nav pushViewController:advanceController animated:YES];
}

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
    if (self.isImportHDAccount) {
        BOOL isHDSeed = [self isHdSeedWithResult:result];
        if ([BTQRCodeUtil verifyQrcodeTransport:result]) {
            [reader playSuccessSound];
            [reader vibrate];
            [reader.presentingViewController dismissViewControllerAnimated:YES completion:^{
                if (!isHDSeed || [[BTQRCodeUtil splitQRCode:result] count] != 3) {
                    [self showMsg:NSLocalizedString(@"import_hd_account_seed_format_error", nil)];
                } else {
                    NSString *hdWordList = [self getHDAccountWordList:result];
                    _result = result;
                    self.selectHdWordList = hdWordList;
                    if ([hdWordList isEqualToString:[BTWordsTypeManager getWordsTypeValue:EN_WORDS]]) {
                        DialogImportHdAccountSeedQrCodeSelectLanguage *dlSelectLanguage = [[DialogImportHdAccountSeedQrCodeSelectLanguage alloc] initWithDelegate:self];
                        [dlSelectLanguage showInWindow:self.controller.view.window];
                    } else {
                        DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
                        [dialog showInWindow:self.controller.view.window];
                    }
                }
            }];
        } else {
            [reader vibrate];
        }
        return;
    }
    NSRange range = [result rangeOfString:HDM_QR_CODE_FLAG];
    bool isHDMSeed = range.location == 0;
    if (self.isImportHDM) {
        if ([BTQRCodeUtil verifyQrcodeTransport:result]) {
            [reader playSuccessSound];
            [reader vibrate];
            [reader.presentingViewController dismissViewControllerAnimated:YES completion:^{
                if (!isHDMSeed || [[BTQRCodeUtil splitQRCode:result] count] != 3) {
                    [self showMsg:NSLocalizedString(@"Import failed.", nil)];
                } else {
                    _result = result;
                    DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
                    [dialog showInWindow:self.controller.view.window];
                }
            }];
        } else {
            [reader vibrate];
        }
    } else {
        if ([BTQRCodeUtil verifyQrcodeTransport:result]) {
            [reader playSuccessSound];
            [reader vibrate];
            [reader.presentingViewController dismissViewControllerAnimated:YES completion:^{
                if (isHDMSeed) {
                    [self showMsg:NSLocalizedString(@"can_not_import_hdm_cold_seed", nil)];
                } else if ([[BTQRCodeUtil splitQRCode:result] count] != 3) {
                    [self showMsg:NSLocalizedString(@"not_verify_bither_private_key_qrcode", nil)];
                } else {
                    _result = result;
                    DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
                    [dialog showInWindow:self.controller.view.window];
                }
            }];
        } else {
            [reader vibrate];
        }

    }
}

- (void)selectLanguage:(NSString *)hdWordList {
    self.selectHdWordList = hdWordList;
    DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
    [dialog showInWindow:self.controller.view.window];
}

- (BOOL)isHdSeedWithResult:(NSString *)result {
    BOOL isZhCNHDSeed = [self isHdSeedWithResult:result HDQrCodeFlat:ZHCN];
    if (isZhCNHDSeed) {
        return isZhCNHDSeed;
    }
    BOOL isZhTWHDSeed = [self isHdSeedWithResult:result HDQrCodeFlat:ZHTW];
    if (isZhTWHDSeed) {
        return isZhTWHDSeed;
    }
    BOOL isHDSeed = [self isHdSeedWithResult:result HDQrCodeFlat:EN];
    return isHDSeed;
}

- (BOOL)isHdSeedWithResult:(NSString *)result HDQrCodeFlat:(HDQrCodeFlatType)qrCodeFlat {
    NSRange range = [result rangeOfString:[BTQRCodeUtil getHDQrCodeFlat:qrCodeFlat]];
    BOOL isHDSeed = range.location == 0 && range.length == [BTQRCodeUtil getHDQrCodeFlat:qrCodeFlat].length;
    return isHDSeed;
}

- (NSString *)getHDAccountWordList:(NSString *)result {
    BOOL isZhCNHDSeed = [self isHdSeedWithResult:result HDQrCodeFlat:ZHCN];
    if (isZhCNHDSeed) {
        return [BTWordsTypeManager getWordsTypeValue:ZHCN_WORDS];
    }
    BOOL isZhTWHDSeed = [self isHdSeedWithResult:result HDQrCodeFlat:ZHTW];
    if (isZhTWHDSeed) {
        return [BTWordsTypeManager getWordsTypeValue:ZHTW_WORDS];
    }
    
    return [BTWordsTypeManager getWordsTypeValue:EN_WORDS];
}

- (NSString *)getHDAccountBTEncryptDataStr:(NSString *)result {
    BOOL isZhCNHDSeed = [self isHdSeedWithResult:result HDQrCodeFlat:ZHCN];
    BOOL isZhTWHDSeed = [self isHdSeedWithResult:result HDQrCodeFlat:ZHTW];
    if (isZhCNHDSeed || isZhTWHDSeed) {
        return [_result substringFromIndex:3];
    }
    return [_result substringFromIndex:1];
}

#pragma mark - import HDAccount、 HDM、 privateKey Through key Qrcode settings
- (void)importHDAccountAndHDMAccountAndPrivateKeyThroughQrcode:(NSString *)password{
    DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    if (self.isImportHDAccount) {
        [dp showInWindow:self.controller.view.window completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                BTPasswordSeed *passwordSeed = [BTPasswordSeed getPasswordSeed];
                if (passwordSeed) {
                    if (![passwordSeed checkPassword:password]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [dp dismissWithCompletion:^{
                                [self showMsg:NSLocalizedString(@"Password of the private key to import is different from ours. Import failed.", nil)];
                            }];
                        });
                        return;
                    }
                }
    
                BTBIP39 *selectBip39 = [[BTBIP39 alloc] initWithWordList:_selectHdWordList];
                if ([BTSettings instance].getAppMode == HOT) {
                    BTHDAccount *account;
                    @try {
                        account = [[BTHDAccount alloc] initWithEncryptedMnemonicSeed:[[BTEncryptData alloc] initWithStr:[self getHDAccountBTEncryptDataStr:_result]] btBip39:selectBip39 password:password syncedComplete:NO andGenerationCallback:nil];
                    } @catch (NSException *e) {
                        if ([e isKindOfClass:[DuplicatedHDAccountException class]]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [dp dismissWithCompletion:^{
                                    [self showMsg:NSLocalizedString(@"import_hd_account_failed_duplicated", nil)];
                                }];
                            });
                            return;
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [dp dismissWithCompletion:^{
                                    [self showMsg:NSLocalizedString(@"Import failed.", nil)];
                                }];
                            });
                            return;
                        }
                    }
                    if (!account) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [dp dismissWithCompletion:^{
                                [self showMsg:NSLocalizedString(@"Import failed.", nil)];
                            }];
                        });
                        return;
                    }
                    
                    [[PeerUtil instance] stopPeer];
                    [BTAddressManager instance].hdAccountHot = account;
                    [[PeerUtil instance] startPeer];
                } else {
                    BTHDAccountCold *account;
                    @try {
                        account = [[BTHDAccountCold alloc] initWithEncryptedMnemonicSeed:[[BTEncryptData alloc] initWithStr:[self getHDAccountBTEncryptDataStr:_result]] btBip39:selectBip39 andPassword:password addMode:Import];
                    } @catch (NSException *e) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [dp dismissWithCompletion:^{
                                [self showMsg:NSLocalizedString(@"Import failed.", nil)];
                            }];
                        });
                        return;
                    }
                    if (!account) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [dp dismissWithCompletion:^{
                                [self showMsg:NSLocalizedString(@"Import failed.", nil)];
                            }];
                        });
                        return;
                    }
                }
                [[BTWordsTypeManager instance] saveWordsTypeValue:selectBip39.wordList];
                [BTBIP39 sharedInstance].wordList = selectBip39.wordList;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dp dismissWithCompletion:^{
                        BOOL isHot = [[BTSettings instance] getAppMode] == HOT;
                        [self showMsg:NSLocalizedString(isHot ? @"Import hot wallet success." : @"Import success.", nil)];
                    }];
                });
            });
        }];
    } else if (self.isImportHDM) {
        [dp showInWindow:self.controller.view.window completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                BTPasswordSeed *passwordSeed = [BTPasswordSeed getPasswordSeed];
                if (passwordSeed) {
                    BOOL checkPassword = [passwordSeed checkPassword:password];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (checkPassword) {
                            [self importHDMColdSeedFormQRCode:_result password:password dp:dp];
                        } else {
                            [self showMsg:NSLocalizedString(@"Password of the private key to import is different from ours. Import failed.", nil)];
                            [dp dismiss];
                        }
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self importHDMColdSeedFormQRCode:_result password:password dp:dp];
                    });
                }
            });
        }];
    } else {
        [dp showInWindow:self.controller.view.window completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                BTPasswordSeed *passwordSeed = [BTPasswordSeed getPasswordSeed];
                if (passwordSeed) {
                    BOOL checkPassword = [passwordSeed checkPassword:password];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (checkPassword) {
                            [self importKeyFormQrcode:_result password:password dp:dp];
                        } else {
                            [self showMsg:NSLocalizedString(@"Password of the private key to import is different from ours. Import failed.", nil)];
                            [dp dismiss];
                        }
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self importKeyFormQrcode:_result password:password dp:dp];
                    });
                }
            });
        }];
        
    }

}

#pragma mark - import style chose
- (void)onPasswordEntered:(NSString *)password {
    [self importHDAccountAndHDMAccountAndPrivateKeyThroughQrcode:password];

}

- (void)importHDMColdSeedFormQRCode:(NSString *)keyStr password:(NSString *)password dp:(DialogProgress *)dp {
    [dp dismiss];
    ImportHDMCold *importPrivateKey = [[ImportHDMCold alloc] initWithController:self.controller content:keyStr worldList:nil passwrod:password importHDSeedType:HDMColdSeedQRCode];
    [importPrivateKey importHDSeed];
}
- (void)importKeyFormQrcode:(NSString *)keyStr password:(NSString *)password dp:(DialogProgress *)dp {
    [dp dismiss];
    ImportPrivateKey *importPrivateKey = [[ImportPrivateKey alloc] initWithController:self.controller content:keyStr passwrod:password importPrivateKeyType:BitherQrcode];
    [importPrivateKey importPrivateKey];
}
- (BOOL)checkPassword:(NSString *)password {
    NSString *checkKeyStr = _result;
    if (self.isImportHDM) {
        checkKeyStr = [checkKeyStr substringFromIndex:1];
    } else if (self.isImportHDAccount) {
        checkKeyStr = [self getHDAccountBTEncryptDataStr:_result];
    }
    BTEncryptData *encryptedData = [[BTEncryptData alloc] initWithStr:checkKeyStr];
    return [encryptedData decrypt:password] != nil;
}

- (NSString *)passwordTitle {
    return NSLocalizedString(@"Enter original password", nil);
}

static CheckPasswordDelegate *checkPasswordDelegate;

//delegate of dialogImportPrivateKey
- (void)onPrivateKeyEntered:(NSString *)privateKey {
    [self showCheckPassword:privateKey];
}

- (void)showCheckPassword:(NSString *)privateKey {
    checkPasswordDelegate = [[CheckPasswordDelegate alloc] init];
    checkPasswordDelegate.controller = self.controller;
    checkPasswordDelegate.privateKeyStr = privateKey;
    DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:checkPasswordDelegate];
    [dialog showInWindow:self.controller.view.window];
    _result = privateKey;
}

- (void)showMsg:(NSString *)msg {
    if ([self.controller respondsToSelector:@selector(showMsg:)]) {
        [self.controller performSelector:@selector(showMsg:) withObject:msg];
    }

}
@end


