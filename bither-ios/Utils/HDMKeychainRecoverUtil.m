//  HDMKeychainRecoverUtil.m
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

#import "HDMKeychainRecoverUtil.h"
#import "BTAddressManager.h"
#import "BTHDMAddress.h"
#import "BTHDMBid+Api.h"
#import "DialogAlert.h"
#import "ScanQrCodeTransportViewController.h"
#import "BTQRCodeUtil.h"
#import "BTUtils.h"
#import "PasswordGetter.h"
#import "DialogProgress.h"
#import "DialogHDMServerUnsignedQRCode.h"
#import "NSError+HDMHttpErrorMessage.h"
#import "PeerUtil.h"

@interface HDMKeychainRecoverUtil()<PasswordGetterDelegate,ScanQrCodeDelegate>{
    PasswordGetter* _passwordGetter;
    DialogProgress *dp;
    SEL afterQRScanSelector;
    NSData * coldRoot;
    BTHDMBid * hdmBid;
    NSString * hdmBidSignature;

}

@property (weak) UIViewController* controller;


@end

@implementation HDMKeychainRecoverUtil {

}

-(instancetype)initWithViewContoller:(UIViewController*)controller{
    self = [super init];
    if(self){
        self.controller = controller;
        [self firstConfigure];
    }
    return self;
}

-(void)firstConfigure{
    hdmBid = nil;
    dp = [[DialogProgress alloc]initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    dp.touchOutSideToDismiss = NO;
}

-(BOOL)canRecover {
    return [[BTAddressManager instance] hdmKeychain]== nil;
}
-(void)revovery {
    [self getColdRoot];
}
-(void )getColdRoot{
    if (coldRoot== nil) {
        [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"hdm_keychain_add_scan_cold", nil) confirm:^{
            afterQRScanSelector = @selector(coldScanned:);
            ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc] initWithDelegate:self];
            [self.controller presentViewController:scan animated:YES completion:nil];
        }                              cancel:nil] showInWindow:self.controller.view.window];

    }
}


-(void)coldScanned:(NSString*)result{
    coldRoot = [result hexToData];
    if(!coldRoot){
        [self showMsg:NSLocalizedString(@"hdm_keychain_add_scan_cold", nil)];
        return;
    }

    if(!dp.shown && self.passwordGetter.hasPassword ){
        [dp showInWindow:self.controller.view.window];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString* password = self.passwordGetter.password;
        if(!password){
            dispatch_async(dispatch_get_main_queue(), ^{
                [dp dismiss];
            });
            return ;
        }
        [self initHDMBidFromColdRoot];
        dispatch_async(dispatch_get_main_queue(), ^{
            [dp dismissWithCompletion:^{
                [self server];
            }];
        });
    });
}


-(void)server{
    if(!coldRoot && !hdmBid){
        //serverPressed = YES;
        [self getColdRoot];
        return;
    }
    //  serverPressed = NO;
    [dp showInWindow:self.controller.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self initHDMBidFromColdRoot];
            NSError* error;
            NSString* preSign = [hdmBid getPreSignHashAndError:&error];
            if(error && !preSign){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showMsg:error.msg];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dp dismissWithCompletion:^{
                        [[[DialogHDMServerUnsignedQRCode alloc]initWithContent:preSign andAction:^{
                            afterQRScanSelector = @selector(serverScanned:);
                            ScanQrCodeViewController* scan = [[ScanQrCodeViewController alloc]initWithDelegate:self];
                            [self.controller presentViewController:scan animated:YES completion:nil];
                        }]showInWindow:self.controller.view.window];
                    }];
                });
            }
        });
    }];
}



-(void)serverScanned:(NSString*)result{
    if(!hdmBid){
        return;
    }
    [dp showInWindow:self.controller.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString* password = self.passwordGetter.password;
            if(!password){
                return;
            }
            NSError* error;
            [hdmBid changeBidPasswordWithSignature:result andPassword:password andError:&error];
            if(error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dp dismissWithCompletion:^{
                        [self showMsg:NSLocalizedString(@"hdm_keychain_add_sign_server_qr_code_error", nil)];
                    }];
                });
                return;
            }
            [[PeerUtil instance]stopPeer];
            NSArray* as = [[BTAddressManager instance].hdmKeychain completeAddressesWithCount:1 password:password andFetchBlock:^(NSString *password, NSArray *partialPubs) {
                [hdmBid createHDMAddress:partialPubs andPassword:password  andError:^(NSError *error) {
                    NSLog(@"error:%@",error);
                }];
            }];


            [[PeerUtil instance]startPeer];
            dispatch_async(dispatch_get_main_queue(), ^{
                [dp dismissWithCompletion:^{
                    if(as.count > 0){
                       // [self.controller moveToFinal:YES];
                    }else{
                        if(error && error.isHttp400){
                            [self showMsg:error.msg];
                        }else{
                            [self showMsg:NSLocalizedString(@"Network failure.", nil)];
                        }
                    }
                }];
            });
        });
    }];
}

-(void)initHDMBidFromColdRoot{
    if(hdmBid){
        return;
    }
    BTBIP32Key* root = [[BTBIP32Key alloc]initWithMasterPubKey:[NSData dataWithBytes:coldRoot.bytes length:coldRoot.length]];
    BTBIP32Key* key = [root deriveSoftened:0];
    NSString* address = key.key.address;
    [root wipe];
    [key wipe];
    hdmBid = [[BTHDMBid alloc]initWithHDMBid:address];
}



-(void)handleResult:(NSString*)result byReader:(ScanQrCodeViewController*)reader{
    if([BTUtils isEmpty:result]){
        return;
    }
    [reader dismissViewControllerAnimated:YES completion:^{
        if(afterQRScanSelector && [self respondsToSelector:afterQRScanSelector]){
            [self performSelector:afterQRScanSelector withObject:result];
        }
        afterQRScanSelector = nil;

    }];
}

-(void)showMsg:(NSString*)msg{
    if(self.controller && [self.controller respondsToSelector:@selector(showMsg:)]){
        [self.controller performSelector:@selector(showMsg:) withObject:msg];
    }
}



- (PasswordGetter *)passwordGetter {
    if(!_passwordGetter){
        _passwordGetter = [[PasswordGetter alloc] initWithWindow:self.controller.view.window andDelegate:self];
    }
    return _passwordGetter;
}



-(void)beforePasswordDialogShow{
    if(dp.shown){
        [dp dismiss];
    }
}

-(void)afterPasswordDialogDismiss{
    if(!dp.shown){
        [dp showInWindow:self.controller.view.window];
    }
}

@end