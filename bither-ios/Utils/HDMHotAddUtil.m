//
//  HDMHotAddUtil.m
//  bither-ios
//
//  Created by 宋辰文 on 15/2/2.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import "HDMHotAddUtil.h"
#import "DialogProgress.h"
#import "PasswordGetter.h"
#import "DialogHDMKeychainAddHot.h"
#import "UEntropyViewController.h"
#import "DialogXrandomInfo.h"
#import "BTHDMKeychain.h"
#import "BTAddressManager.h"
#import "DialogAlert.h"
#import "ScanQrCodeViewController.h"
#import "BTUtils.h"
#import "BitherSetting.h"
#import "BTHDMBid.h"
#import "NSError+HDMHttpErrorMessage.h"

@import MobileCoreServices;
@import AVFoundation;

#define kSaveProgress (0.1)
#define kStartProgress (0.01)
#define kProgressKeyRate (0.5)
#define kProgressEncryptRate (0.5)
#define kMinGeneratingTime (2.4)

@interface HDMHotAddUtil()<PasswordGetterDelegate, UEntropyViewControllerDelegate, ScanQrCodeDelegate>{
    PasswordGetter* passwordGetter;
    DialogProgress *dp;
    NSData* coldRoot;
    BTHDMBid* hdmBid;
    BOOL hdmKeychainLimit;
    SEL afterQRScanSelector;
    BOOL serverPressed;
}
@property (weak) UIViewController<HDMHotAddUtilDelegate>* controller;
@property (weak) UIWindow* window;
@end

@implementation HDMHotAddUtil
-(instancetype)initWithViewContoller:(UIViewController<HDMHotAddUtilDelegate>*)controller{
    self = [super init];
    if(self){
        self.controller = controller;
        self.window = self.controller.view.window;
        [self firstConfigure];
    }
    return self;
}

-(void)firstConfigure{
    serverPressed = NO;
    hdmBid = nil;
    hdmKeychainLimit = [BTAddressManager instance].hasHDMKeychain;
    dp = [[DialogProgress alloc]initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    dp.touchOutSideToDismiss = NO;
    passwordGetter = [[PasswordGetter alloc]initWithWindow:self.window andDelegate:self];
}

-(void)hot{
    if(hdmKeychainLimit){
        return;
    }
    __block __weak HDMHotAddUtil* s;
    [[[DialogHDMKeychainAddHot alloc]initWithBlock:^(BOOL xrandom) {
        if(xrandom){
            [self hotWithXRandom];
        }else{
            NSString* password = passwordGetter.password;
            if(!password){
                return;
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [UIApplication sharedApplication].idleTimerDisabled = YES;
                XRandom *xRandom=[[XRandom alloc] initWithDelegate:nil];
                BTHDMKeychain* keychain = nil;
                while (!keychain) {
                    @try {
                        NSData* seed = [xRandom randomWithSize:32];
                        keychain = [[BTHDMKeychain alloc]initWithMnemonicSeed:seed password:password andXRandom:NO];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"generate HDM keychain error %@", exception.debugDescription);
                    }
                }
                [BTAddressManager instance].hdmKeychain = keychain;
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dp dismissWithCompletion:^{
                        if(keychain){
                            [s.controller moveToCold:YES];
                        } else {
                            [s showMsg:NSLocalizedString(@"xrandom_generating_failed", nil)];
                        }
                    }];
                });
            });
        }
    }]showInWindow:self.window];
}

// MARK: hot xrandom
-(void)hotWithXRandom{
    if([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined ||
       [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] == AVAuthorizationStatusNotDetermined){
        [self getPermissions:^{
            [self hotWithXRandom];
        }];
        return;
    }
    passwordGetter.delegate = nil;
    NSString* password = passwordGetter.password;
    passwordGetter.delegate = self;
    if(!password){
        return;
    }
    UEntropyViewController* uentropy = [[UEntropyViewController alloc]initWithPassword:password andDelegate:self];
    [self.controller presentViewController:uentropy animated:YES completion:nil];
}

-(void)onUEntropyGeneratingWithController:(UEntropyViewController*)controller collector:(UEntropyCollector*)collector andPassword:(NSString*)password{
    float progress = kStartProgress;
    float itemProgress = 1.0 - kStartProgress - kSaveProgress;
    NSTimeInterval startGeneratingTime = [[NSDate date] timeIntervalSince1970];
    [collector onResume];
    [collector start];
    [controller onProgress:progress];
    XRandom* xrandom = [[XRandom alloc]initWithDelegate:collector];
    if(controller.testShouldCancel){
        return;
    }
    BTHDMKeychain* keychain = nil;
    while (!keychain) {
        @try {
            NSData* seed = [xrandom randomWithSize:32];
            keychain = [[BTHDMKeychain alloc]initWithMnemonicSeed:seed password:password andXRandom:YES];
        }
        @catch (NSException *exception) {
            NSLog(@"generate HDM keychain error %@", exception.debugDescription);
        }
    }
    progress += itemProgress * kProgressKeyRate;
    [controller onProgress:progress];
    [BTAddressManager instance].hdmKeychain = keychain;
    progress += itemProgress * kProgressEncryptRate;
    [controller onProgress:progress];
    [collector stop];
    while ([[NSDate new] timeIntervalSince1970] - startGeneratingTime < kMinGeneratingTime) {
        
    }
    [controller onSuccess];
}

-(void)successFinish:(UEntropyViewController*)controller{
    __weak __block HDMHotAddUtil* s = self;
    [controller dismissViewControllerAnimated:YES completion:^{
        [s.controller moveToCold:YES];
    }];
}

-(void)getPermisionFor:(NSString*)mediaType completion:(void(^)(BOOL))completion{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            completion(granted);
        }];
    }else{
        completion(authStatus == AVAuthorizationStatusAuthorized);
    }
}

-(void)getPermissions:(void(^)())completion{
    __weak __block HDMHotAddUtil* s = self;
    [[[DialogXrandomInfo alloc] initWithPermission:^{
        [s getPermisionFor:AVMediaTypeVideo completion:^(BOOL result) {
            [s getPermisionFor:AVMediaTypeAudio completion:^(BOOL result) {
                dispatch_async(dispatch_get_main_queue(), completion);
            }];
        }];
    }] showInWindow:self.window];
}

-(void)cold{
    if(hdmKeychainLimit){
        return;
    }
    [[[DialogAlert alloc]initWithMessage:NSLocalizedString(@"hdm_keychain_add_scan_cold", nil) confirm:^{
        afterQRScanSelector = @selector(coldScanned:);
        ScanQrCodeViewController* scan = [[ScanQrCodeViewController alloc]initWithDelegate:self];
        [self.controller presentViewController:scan animated:YES completion:nil];
    } cancel:nil]showInWindow:self.window];
}

-(void)coldScanned:(NSString*)result{
    coldRoot = [result hexToData];
    if(!coldRoot){
        [self showMsg:NSLocalizedString(@"hdm_keychain_add_scan_cold", nil)];
        return;
    }
    NSUInteger count = HDM_ADDRESS_PER_SEED_PREPARE_COUNT - [BTAddressManager instance].hdmKeychain.uncompletedAddressCount;
    if(!dp.shown && passwordGetter.hasPassword && count > 0){
        [dp showInWindow:self.window];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if(count > 0){
            NSString* password = passwordGetter.password;
            if(!password){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dp dismiss];
                });
                return ;
            }
            [[BTAddressManager instance].hdmKeychain prepareAddressesWithCount:(UInt32)count password:password andColdExternalPub:[NSData dataWithBytes:coldRoot.bytes length:coldRoot.length]];
            [self initHDMBidFromColdRoot];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
               [dp dismissWithCompletion:^{
                   if(serverPressed){
                       [self server];
                   }else{
                       [self.controller moveToServer:YES];
                   }
               }];
            });
        }
    });
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

-(void)server{
    if(hdmKeychainLimit){
        return;
    }
    if(!coldRoot && !hdmBid){
        serverPressed = YES;
        [self cold];
    }
    serverPressed = NO;
    if(!dp.shown){
        [dp showInWindow:self.window];
    }
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
                
            });
        }
    });
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

-(void)beforePasswordDialogShow{
    if(dp.shown){
        [dp dismiss];
    }
}

-(void)afterPasswordDialogDismiss{
    if(!dp.shown){
        [dp showInWindow:self.window];
    }
}
@end
