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
#import "StringUtil.h"
#import "BitherSetting.h"
#import "BTPasswordSeed.h"
#import "UserDefaultsUtil.h"
#import "KeyUtil.h"
#import "DialogProgress.h"
#import "UIViewController+PiShowBanner.h"
#import "NSString+Base58.h"
#import "BTSettings.h"
#import "TransactionsUtil.h"
#import "Bitheri/BTKey+Bitcoinj.h"
#import "BTAddressManager.h"
#import "BTQRCodeUtil.h"
#import "BTPrivateKeyUtil.h"
#import "ImportPrivateKey.h"

@interface CheckPasswordBip38Delegate : NSObject<DialogPasswordDelegate>
@property(nonatomic,strong) UIViewController *controller;
@property(nonatomic,strong) NSString * privateKeyStr;
@end

@implementation CheckPasswordBip38Delegate

-(void)onPasswordEntered:(NSString *)password{
    ImportPrivateKey *improtPrivateKey=[[ImportPrivateKey alloc] initWithController:self.controller content:self.privateKeyStr passwrod:password importPrivateKeyType:PrivateText];
    [improtPrivateKey importPrivateKey];
}
@end


@implementation ImportBip38PrivateKeySetting

static Setting* importPrivateKeySetting;


+(Setting *)getImportBip38PrivateKeySetting{
    if(!importPrivateKeySetting){
        ImportBip38PrivateKeySetting*  scanPrivateKeySetting=[[ImportBip38PrivateKeySetting alloc] initWithName:NSLocalizedString(@"Import Private Key", nil) icon:nil ];
        __weak ImportBip38PrivateKeySetting * sself=scanPrivateKeySetting;
        [scanPrivateKeySetting setSelectBlock:^(UIViewController * controller){
            sself.controller=controller;
            UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Import Private Key", nil)
                                                                  delegate:sself                                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:NSLocalizedString(@"From Bither Private Key QR Code", nil),NSLocalizedString(@"From Private Key Text", nil),nil];
            
            actionSheet.actionSheetStyle=UIActionSheetStyleDefault;
            [actionSheet showInView:controller.navigationController.view];
        }];
        importPrivateKeySetting = scanPrivateKeySetting;
    }
    return importPrivateKeySetting;
}



-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc]initWithDelegate:self title:NSLocalizedString(@"Scan Private Key QR Code",nil) message:NSLocalizedString(@"Scan QR code No.1 provided by Bither", nil)];
        [self.controller presentViewController:scan animated:YES completion:nil];
    }else if(buttonIndex==1){
        DialogImportPrivateKey * dialogImportPrivateKey=[[DialogImportPrivateKey alloc] initWithDelegate:self];
        [dialogImportPrivateKey showInWindow:self.controller.view.window];
    }
}

-(void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader{
    if ([BTQRCodeUtil verifyQrcodeTransport:result]&&[[BTQRCodeUtil splitQRCode:result] count]==3) {
        _result=result;
        [reader playSuccessSound];
        [reader vibrate];
        [reader dismissViewControllerAnimated:YES completion:^{
            DialogPassword *dialog = [[DialogPassword alloc]initWithDelegate:self];
            [dialog showInWindow:self.controller.view.window];
            
        }];
    }else{
        [reader vibrate];
    }
    
}
-(void)onPasswordEntered:(NSString *)password{
    DialogProgress * dp = [[DialogProgress alloc]initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    [dp showInWindow:self.controller.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            BTPasswordSeed * passwordSeed=[[UserDefaultsUtil instance] getPasswordSeed];
            if (passwordSeed) {
                BOOL checkPassword=[passwordSeed checkPassword:password];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (checkPassword) {
                        [self importKeyFormQrcode:_result password:password dp:dp];
                    }else{
                        [self showMsg:NSLocalizedString(@"Password of the private key to import is different from ours. Import failed.", nil)];
                        [dp dismiss];
                    }
                    
                });
            }else{
                [self importKeyFormQrcode:_result password:password dp:dp];
            }
        });
    }];
    
    
}
-(void) importKeyFormQrcode:(NSString *)keyStr password:(NSString *)password dp:(DialogProgress *)dp{
    [dp dismiss];
    ImportPrivateKey *importPrivateKey=[[ImportPrivateKey alloc] initWithController:self.controller content:keyStr passwrod:password importPrivateKeyType:BitherQrcode];
    [importPrivateKey importPrivateKey];
}
-(BOOL)checkPassword:(NSString *)password{
    BTKey * key=[ BTKey  keyWithBitcoinj:_result andPassphrase:password];
    BOOL result=key!=nil;
    key=nil;
    return result;
}

-(NSString *)passwordTitle{
    return NSLocalizedString(@"Enter original password", nil);
}

static CheckPasswordBip38Delegate *checkPasswordDelegate;
//delegate of dialogImportPrivateKey
-(void)onPrivateKeyEntered:(NSString *)privateKey{
    [self showCheckPassword:privateKey ];
    
}
-(void)showCheckPassword:(NSString *)privateKey{
    checkPasswordDelegate=[[CheckPasswordBip38Delegate alloc] init];
    checkPasswordDelegate.controller=self.controller;
    checkPasswordDelegate.privateKeyStr=privateKey;
    DialogPassword *dialog = [[DialogPassword alloc]initWithDelegate:checkPasswordDelegate];
    [dialog showInWindow:self.controller.view.window];
    _result=privateKey;
}
-(void) showMsg:(NSString *)msg{
    if([self.controller respondsToSelector:@selector(showMsg:)]){
        [self.controller performSelector:@selector(showMsg:) withObject:msg];
    }
    
}

@end
