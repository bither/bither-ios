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

#import "ScanPrivateKeyDelegate.h"
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
#import "QRCodeEncodeUtil.h"

@interface CheckPasswordDelegate : NSObject<DialogPasswordDelegate>
@property(nonatomic,strong) UIViewController *controller;
@property(nonatomic,strong) NSString * result;
@end

@implementation CheckPasswordDelegate
-(void)onPasswordEntered:(NSString *)password{
    __block NSString * bpassword=password;
    password=nil;
    DialogProgress * dp = [[DialogProgress alloc]initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    [dp showInWindow:self.controller.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            BTKey * key=[[BTKey alloc] initWithPrivateKey:self.result];
            NSString * encryptKey=[key bitcoinjKeyWithPassphrase:bpassword  andSalt:[NSData randomWithSize:8] andIV:[NSData randomWithSize:16]];
            NSError * error;
            [KeyUtil addBitcoinjKey:[[NSArray alloc] initWithObjects:encryptKey, nil] withPassphrase:bpassword error:&error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    [self showMsg:NSLocalizedString(@"Import success.", nil)];                }else{
                        [self showMsg:NSLocalizedString(@"Import failed.", nil)];
                    }
                [dp dismiss];
            });
            bpassword=nil;
            key=nil;
            self.result=nil;
        });
    }];
}

-(void) showMsg:(NSString *)msg{
    if([self.controller respondsToSelector:@selector(showMsg:)]){
        [self.controller performSelector:@selector(showMsg:) withObject:msg];
    }
    
}
@end

@interface ScanPrivateKeyDelegate()<UIActionSheetDelegate,ScanQrCodeDelegate,DialogPasswordDelegate,DialogImportPrivateKeyDelegate>

@property(nonatomic,strong) NSString * result;


@end

@implementation ScanPrivateKeyDelegate

static ScanPrivateKeyDelegate * scanPrivateKeyDelegate;
+ (ScanPrivateKeyDelegate *)instance {
    @synchronized(self) {
        if (scanPrivateKeyDelegate == nil) {
            scanPrivateKeyDelegate = [[self alloc] init];
            
        }
    }
    return scanPrivateKeyDelegate;
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
    if ([QRCodeEncodeUtil verifyQrcodeTransport:result]&&[[QRCodeEncodeUtil splitQRCode:result] count]==3) {
        self.result=result;
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
                        [self importKeyFormQrcode:self.result password:password dp:dp];
                    }else{
                        [self showMsg:NSLocalizedString(@"Password of the private key to import is different from ours. Import failed.", nil)];
                        [dp dismiss];
                    }
                    
                });
            }else{
                [self importKeyFormQrcode:self.result password:password dp:dp];
            }
        });
    }];
    
    
}
-(void) importKeyFormQrcode:(NSString *)keyStr password:(NSString *)password dp:(DialogProgress *)dp{
    if ([[BTSettings instance] getAppMode]==COLD) {
        [KeyUtil addBitcoinjKey:[[NSArray alloc] initWithObjects:keyStr, nil] withPassphrase:password error:nil];
        [self showMsg:NSLocalizedString(@"Import success.", nil)];
        [dp dismiss];
    }else{
        NSMutableArray * array=[NSMutableArray new];
        BTKey *key=[BTKey keyWithBitcoinj:keyStr andPassphrase:password];
        [array addObject:key.address];
        BTAddress *address=[[BTAddress alloc] initWithKey:key encryptPrivKey:nil];
        if ([[[BTAddressManager instance] privKeyAddresses] containsObject:address]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMsg:NSLocalizedString(@"This private key already exists.", nil)];
                [dp dismiss];
                
            });
        }else if([[[BTAddressManager instance] watchOnlyAddresses] containsObject:address]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMsg:NSLocalizedString(@"Can\'t import Bither Cold private key.", nil)];
                [dp dismiss];
            });
        }else{
            [TransactionsUtil checkAddress:array callback:^(id response) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    AddressType addressType=(AddressType)[response integerValue];
                    if (addressType==AddressNormal) {
                        [KeyUtil addBitcoinjKey:[[NSArray alloc] initWithObjects:keyStr, nil] withPassphrase:password error:nil];
                        [self showMsg:NSLocalizedString(@"Import success.", nil)];
                        
                    }else if(addressType==AddressTxTooMuch){
                        [self showMsg:NSLocalizedString(@"Cannot import private key with large amount of transactions.", nil)];
                       
                    }else{
                        [self showMsg:NSLocalizedString(@"Cannot import private key with special transactions.", nil)];
                       
                    }
                    [dp dismiss];
                });
            }andErrorCallback:^(NSError *error) {
                [self showMsg:NSLocalizedString(@"Network failure.", nil)];
                [dp dismiss];
            }];
            
        }
        
        
    }
}
-(BOOL)checkPassword:(NSString *)password{
    BTKey * key=[ BTKey  keyWithBitcoinj:self.result andPassphrase:password];
    return key!=nil;
}

-(NSString *)passwordTitle{
    return NSLocalizedString(@"Enter original password", nil);
}
static CheckPasswordDelegate *checkPasswordDelegate;
//delegate of dialogImportPrivateKey
-(void)onPrivateKeyEntered:(NSString *)privateKey{
    BTKey * key=[BTKey keyWithPrivateKey:privateKey];
    if ([[BTSettings instance] getAppMode]==COLD) {
        [self showCheckPassword:privateKey compressed:[key compressed]];
    }else{
        NSMutableArray * array=[NSMutableArray new];
        [array addObject:key.address];
        BTAddress *address=[[BTAddress alloc] initWithKey:key encryptPrivKey:nil];
        if ([[[BTAddressManager instance] privKeyAddresses] containsObject:address]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMsg:NSLocalizedString(@"This private key already exists.", nil)];
                
            });
        }else if([[[BTAddressManager instance] watchOnlyAddresses] containsObject:address]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMsg:NSLocalizedString(@"Can\'t import Bither Cold private key.", nil)];
            });
        }else{
            [TransactionsUtil checkAddress:array callback:^(id response) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    AddressType addressType=(AddressType)[response integerValue];
                    if (addressType==AddressNormal) {
                        [self showCheckPassword:privateKey compressed:[key compressed]];
                    }else if(addressType==AddressTxTooMuch){
                        [self showMsg:NSLocalizedString(@"Cannot import private key with large amount of transactions.", nil)];
                    }else{
                        [self showMsg:NSLocalizedString(@"Cannot import private key with special transactions.", nil)];
                    }
                });
            } andErrorCallback:^(NSError *error) {
                [self showMsg:NSLocalizedString(@"Network failure.", nil)];
            }];
        }
        
    }
    
}
-(void)showCheckPassword:(NSString *)privateKey compressed:(BOOL)compressed{
    if (!compressed) {
        [self showMsg:NSLocalizedString(@"Only supports the compressed format of private key", nil)];
    }else{
        checkPasswordDelegate=[[CheckPasswordDelegate alloc] init];
        checkPasswordDelegate.controller=self.controller;
        checkPasswordDelegate.result=privateKey;
        DialogPassword *dialog = [[DialogPassword alloc]initWithDelegate:checkPasswordDelegate];
        
        [dialog showInWindow:self.controller.view.window];
        self.result=privateKey;
    }
}
-(void) showMsg:(NSString *)msg{
    if([self.controller respondsToSelector:@selector(showMsg:)]){
        [self.controller performSelector:@selector(showMsg:) withObject:msg];
    }
    
}
@end


