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
#import "DialogHDMServerUnsignedQRCode.h"
#import "NSError+HDMHttpErrorMessage.h"
#import "PeerUtil.h"
#import "BTHDMBid+Api.h"


#define kSaveProgress (0.1)
#define kStartProgress (0.01)
#define kProgressKeyRate (0.5)
#define kProgressEncryptRate (0.5)
#define kMinGeneratingTime (2.4)

@interface HDMHotAddUtil () <PasswordGetterDelegate, UEntropyViewControllerDelegate, ScanQrCodeDelegate> {
    PasswordGetter *_passwordGetter;
    DialogProgress *dp;
    NSData *coldRoot;
    BTHDMBid *hdmBid;
    BOOL hdmKeychainLimit;
    SEL afterQRScanSelector;
    BOOL serverPressed;
    __weak UIWindow *_window;
    HDMSingular *singular;
}
@property(weak) UIViewController <HDMHotAddUtilDelegate> *controller;
@property(readonly, weak) UIWindow *window;
@property(readonly) PasswordGetter *passwordGetter;
@end

@implementation HDMHotAddUtil
- (instancetype)initWithViewContoller:(UIViewController <HDMHotAddUtilDelegate> *)controller {
    self = [super init];
    if (self) {
        self.controller = controller;
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    singular = [[HDMSingular alloc] initWithController:self.controller andDelegate:self];
    serverPressed = NO;
    hdmBid = nil;
    [self refreshHDMLimit];
    dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    dp.touchOutSideToDismiss = NO;
    [self findCurrentStep];
}

- (void)refreshHDMLimit {
    hdmKeychainLimit = [BTAddressManager instance].hasHDMKeychain;
}

- (void)hot {
    if (hdmKeychainLimit) {
        return;
    }
    if (singular.isInSingularMode) {
        return;
    }
    [[[DialogHDMKeychainAddHot alloc] initWithBlock:^(BOOL xrandom) {
        if (xrandom) {
            [self hotWithXRandom];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSString *password = self.passwordGetter.password;
                if (!password) {
                    return;
                }
                if (singular.shouldGoSingularMode) {
                    [singular setPassword:password];
                    [singular hot:NO];
                    return;
                }
                [singular runningWithoutSingularMode];
                [UIApplication sharedApplication].idleTimerDisabled = YES;
                XRandom *xRandom = [[XRandom alloc] initWithDelegate:nil];
                BTHDMKeychain *keychain = nil;
                while (!keychain) {
                    @try {
                        NSData *seed = [xRandom randomWithSize:32];
                        keychain = [[BTHDMKeychain alloc] initWithMnemonicSeed:seed password:password andXRandom:NO];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"generate HDM keychain error %@", exception.debugDescription);
                    }
                }
                [BTAddressManager instance].hdmKeychain = keychain;
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dp dismissWithCompletion:^{
                        if (keychain) {
                            [self.controller moveToCold:YES andCompletion:nil];
                        } else {
                            [self showMsg:NSLocalizedString(@"xrandom_generating_failed", nil)];
                        }
                    }];
                });
            });
        }
    }] showInWindow:self.window];
}

// MARK: hot xrandom
- (void)hotWithXRandom {
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined ||
            [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] == AVAuthorizationStatusNotDetermined) {
        [self getPermissions:^{
            [self hotWithXRandom];
        }];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.passwordGetter.delegate = nil;
        NSString *password = self.passwordGetter.password;
        self.passwordGetter.delegate = self;
        if (!password) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (singular.shouldGoSingularMode) {
                [singular setPassword:password];
                [singular hot:YES];
            } else {
                [singular runningWithoutSingularMode];
                UEntropyViewController *uentropy = [[UEntropyViewController alloc] initWithPassword:password andDelegate:self];
                [self.controller presentViewController:uentropy animated:YES completion:nil];
            }
        });
    });
}

- (void)onUEntropyGeneratingWithController:(UEntropyViewController *)controller collector:(UEntropyCollector *)collector andPassword:(NSString *)password {
    float progress = kStartProgress;
    float itemProgress = 1.0 - kStartProgress - kSaveProgress;
    NSTimeInterval startGeneratingTime = [[NSDate date] timeIntervalSince1970];
    [collector onResume];
    [collector start];
    [controller onProgress:progress];
    XRandom *xrandom = [[XRandom alloc] initWithDelegate:collector];
    if (controller.testShouldCancel) {
        return;
    }
    BTHDMKeychain *keychain = nil;
    while (!keychain) {
        @try {
            NSData *seed = [xrandom randomWithSize:32];
            keychain = [[BTHDMKeychain alloc] initWithMnemonicSeed:seed password:password andXRandom:YES];
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

- (void)successFinish:(UEntropyViewController *)controller {
    __weak __block HDMHotAddUtil *s = self;
    [controller dismissViewControllerAnimated:YES completion:^{
        [s.controller moveToCold:YES andCompletion:nil];
    }];
}

- (void)getPermisionFor:(NSString *)mediaType completion:(void (^)(BOOL))completion {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            completion(granted);
        }];
    } else {
        completion(authStatus == AVAuthorizationStatusAuthorized);
    }
}

- (void)getPermissions:(void (^)())completion {
    __weak __block HDMHotAddUtil *s = self;
    [[[DialogXrandomInfo alloc] initWithPermission:^{
        [s getPermisionFor:AVMediaTypeVideo completion:^(BOOL result) {
            [s getPermisionFor:AVMediaTypeAudio completion:^(BOOL result) {
                dispatch_async(dispatch_get_main_queue(), completion);
            }];
        }];
    }] showInWindow:self.window];
}

- (void)cold {
    if (hdmKeychainLimit) {
        return;
    }
    if (singular.isInSingularMode) {
        return;
    }
    [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"hdm_keychain_add_scan_cold", nil) confirm:^{
        afterQRScanSelector = @selector(coldScanned:);
        ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc] initWithDelegate:self];
        [self.controller presentViewController:scan animated:YES completion:nil];
    }                              cancel:nil] showInWindow:self.window];
}

- (void)coldScanned:(NSString *)result {
    coldRoot = [result hexToData];
    if (!coldRoot) {
        [self showMsg:NSLocalizedString(@"hdm_keychain_add_scan_cold", nil)];
        return;
    }
    NSUInteger count = HDM_ADDRESS_PER_SEED_PREPARE_COUNT - [BTAddressManager instance].hdmKeychain.uncompletedAddressCount;
    if (!dp.shown && self.passwordGetter.hasPassword && count > 0) {
        [dp showInWindow:self.window];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (count > 0) {
            NSString *password = self.passwordGetter.password;
            if (!password) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dp dismiss];
                });
                return;
            }
            [[BTAddressManager instance].hdmKeychain prepareAddressesWithCount:(UInt32) count password:password andColdExternalPub:[NSData dataWithBytes:coldRoot.bytes length:coldRoot.length]];
        }
        [self initHDMBidFromColdRoot];
        dispatch_async(dispatch_get_main_queue(), ^{
            [dp dismissWithCompletion:^{
                if (serverPressed) {
                    [self server];
                } else {
                    [self.controller moveToServer:YES andCompletion:nil];
                }
            }];
        });
    });
}

- (void)initHDMBidFromColdRoot {
    if (hdmBid) {
        return;
    }
    BTBIP32Key *root = [[BTBIP32Key alloc] initWithMasterPubKey:[NSData dataWithBytes:coldRoot.bytes length:coldRoot.length]];
    BTBIP32Key *key = [root deriveSoftened:0];
    NSString *address = key.key.address;
    [root wipe];
    [key wipe];
    hdmBid = [[BTHDMBid alloc] initWithHDMBid:address];
}

- (void)server {
    if (hdmKeychainLimit) {
        return;
    }
    if (singular.isInSingularMode) {
        return;
    }
    if (!coldRoot && !hdmBid) {
        serverPressed = YES;
        [self cold];
        return;
    }
    serverPressed = NO;
    [dp showInWindow:self.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self initHDMBidFromColdRoot];
            NSError *error;
            NSString *preSign = [hdmBid getPreSignHashAndError:&error];
            if (error && !preSign) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showMsg:error.msg];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dp dismissWithCompletion:^{
                        [[[DialogHDMServerUnsignedQRCode alloc] initWithContent:preSign andAction:^{
                            afterQRScanSelector = @selector(serverScanned:);
                            ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc] initWithDelegate:self];
                            [self.controller presentViewController:scan animated:YES completion:nil];
                        }] showInWindow:self.window];
                    }];
                });
            }
        });
    }];
}

- (void)serverScanned:(NSString *)result {
    if (!hdmBid) {
        return;
    }
    [dp showInWindow:self.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString *password = self.passwordGetter.password;
            if (!password) {
                return;
            }
            __block NSError *error;
            [hdmBid changeBidPasswordWithSignature:result andPassword:password andError:&error];
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dp dismissWithCompletion:^{
                        [self showMsg:NSLocalizedString(@"hdm_keychain_add_sign_server_qr_code_error", nil)];
                    }];
                });
                return;
            }
            [[PeerUtil instance] stopPeer];
            NSArray *as = [[BTAddressManager instance].hdmKeychain completeAddressesWithCount:1 password:password andFetchBlock:^(NSString *password, NSArray *partialPubs) {

                [hdmBid createHDMAddress:partialPubs andPassword:password andError:&error];
            }];
            if (!error) {
                [[PeerUtil instance] startPeer];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [dp dismissWithCompletion:^{
                    if (as.count > 0) {
                        [self.controller moveToFinal:YES andCompletion:nil];
                    } else {
                        if (error && error.isHttp400) {
                            [self showMsg:error.msg];
                        } else {
                            [self showMsg:NSLocalizedString(@"Network failure.", nil)];
                        }
                    }
                }];
            });
        });
    }];
}

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
    if ([BTUtils isEmpty:result]) {
        return;
    }
    [reader.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if (afterQRScanSelector && [self respondsToSelector:afterQRScanSelector]) {
            [self performSelector:afterQRScanSelector withObject:result];
        }
        afterQRScanSelector = nil;
    }];
}

- (void)findCurrentStep {
    [self.controller moveToHot:NO andCompletion:nil];
    if ([BTAddressManager instance].hdmKeychain) {
        [self.controller moveToCold:NO andCompletion:nil];
        if ([BTAddressManager instance].hdmKeychain.uncompletedAddressCount > 0) {
            [self.controller moveToServer:NO andCompletion:nil];
            if (hdmKeychainLimit) {
                [self.controller moveToFinal:NO andCompletion:nil];
            }
        } else if (hdmKeychainLimit) {
            [self.controller moveToServer:NO andCompletion:nil];
            [self.controller moveToFinal:NO andCompletion:nil];
        }
    }
}

- (void)showMsg:(NSString *)msg {
    if (self.controller && [self.controller respondsToSelector:@selector(showMsg:)]) {
        [self.controller performSelector:@selector(showMsg:) withObject:msg];
    }
}

- (void)beforePasswordDialogShow {
    if (dp.shown) {
        [dp dismiss];
    }
}

- (void)afterPasswordDialogDismiss {
    if (!dp.shown && !self.controller.shouldGoSingularMode) {
        [dp showInWindow:self.window];
    }
}

- (BOOL)isHDMKeychainLimited {
    return hdmKeychainLimit;
}

- (UIWindow *)window {
    if (!_window) {
        _window = self.controller.view.window;
    }
    return _window;
}

- (PasswordGetter *)passwordGetter {
    if (!_passwordGetter) {
        _passwordGetter = [[PasswordGetter alloc] initWithWindow:self.window andDelegate:self];
    }
    return _passwordGetter;
}

- (void)setSingularModeAvailable:(BOOL)available {
    [self.controller setSingularModeAvailable:available];
}

- (void)onSingularModeBegin {
    [self.controller onSingularModeBegin];
}

- (BOOL)shouldGoSingularMode {
    return [self.controller shouldGoSingularMode];
}

- (void)singularHotFinish {
    [self.controller moveToCold:YES andCompletion:^{
        [singular cold];
    }];
}

- (void)singularColdFinish {
    [self.controller moveToServer:YES andCompletion:^{
        [singular server];
    }];
}

- (void)singularServerFinishWithWords:(NSArray *)words andColdQr:(NSString *)qr {
    [self.controller moveToFinal:YES andCompletion:^{
        [self.controller singularServerFinishWithWords:words andColdQr:qr];
    }];
}

- (void)singularShowNetworkFailure {
    [self.controller singularShowNetworkFailure];
}

- (BOOL)canCancel {
    if (singular) {
        return !singular.isInSingularMode;
    }
    return YES;
}


@end
