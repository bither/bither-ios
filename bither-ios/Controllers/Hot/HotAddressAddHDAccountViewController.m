//
//  HotAddressAddHDAccountViewController.m
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
//
//  Created by 宋辰文 on 15/4/24.
//

#import "HotAddressAddHDAccountViewController.h"
#import "DialogXrandomInfo.h"
#import "DialogPassword.h"
#import "DialogAlert.h"
#import "UEntropyViewController.h"
#import "DialogProgress.h"
#import "KeyUtil.h"
#import "UIViewController+PiShowBanner.h"
#import "PeerUtil.h"
#import "DialogHDMSingularColdSeed.h"

@import AVFoundation;

#import <Bitheri/BTHDAccount.h>
#import <Bitheri/BTAddressManager.h>

#define kSaveProgress (0.03)
#define kStartProgress (0.01)
#define kMinGeneratingTime (2.4)

@interface HotAddressAddHDAccountViewController () <DialogPasswordDelegate, UEntropyViewControllerDelegate> {
    NSArray *words;
}
@property(weak, nonatomic) IBOutlet UIButton *btnXRandomCheck;

@end

@implementation HotAddressAddHDAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)xrandomInfoPressed:(id)sender {
    [[[DialogXrandomInfo alloc] initWithGuide:YES] showInWindow:self.view.window];
}

- (IBAction)xrandomCheckPressed:(id)sender {
    if (!self.btnXRandomCheck.selected) {
        self.btnXRandomCheck.selected = YES;
        [self.btnXRandomCheck setImage:[UIImage imageNamed:@"xrandom_checkbox_checked"] forState:UIControlStateNormal];
    } else {
        DialogAlert *alert = [[DialogAlert alloc] initWithMessage:NSLocalizedString(@"XRandom increases randomness.\nSure to disable?", nil) confirm:^{
            self.btnXRandomCheck.selected = NO;
            [self.btnXRandomCheck setImage:[UIImage imageNamed:@"xrandom_checkbox_normal"] forState:UIControlStateNormal];
        }                                                  cancel:nil];
        [alert showInWindow:self.view.window];
    }
}

- (IBAction)generatePressed:(id)sender {
    if (self.btnXRandomCheck.selected && (
            [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined ||
                    [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] == AVAuthorizationStatusNotDetermined)
            ) {
        [self getPermissions:^{
            DialogPassword *d = [[DialogPassword alloc] initWithDelegate:self];
            [d showInWindow:self.view.window];
        }];
    } else {
        DialogPassword *d = [[DialogPassword alloc] initWithDelegate:self];
        [d showInWindow:self.view.window];
    }
}

- (void)onPasswordEntered:(NSString *)password {
    if (self.btnXRandomCheck.selected) {
        UEntropyViewController *uentropy = [[UEntropyViewController alloc] initWithPassword:password andDelegate:self];
        [self presentViewController:uentropy animated:YES completion:nil];
    } else {
        DialogProgress *d = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
        d.touchOutSideToDismiss = NO;
        [d showInWindow:self.view.window];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            XRandom *xRandom = [[XRandom alloc] initWithDelegate:nil];
            BTHDAccount *account = nil;
            while (!account) {
                @try {
                    NSData *seed = [xRandom randomWithSize:16];
                    account = [[BTHDAccount alloc] initWithMnemonicSeed:seed password:password fromXRandom:NO andGenerationCallback:nil];
                }
                @catch (NSException *exception) {
                    NSLog(@"generate HD Account error %@", exception.debugDescription);
                }
            }
            words = [account seedWords:password];
            [[PeerUtil instance] stopPeer];
            [BTAddressManager instance].hdAccountHot = account;
            [[PeerUtil instance] startPeer];
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [d dismissWithCompletion:^{
                    if (account) {
                        __block HotAddressAddHDAccountViewController *s = self;
                        [[[DialogHDMSingularColdSeed alloc] initWithWords:words qr:[BTAddressManager instance].hdAccountHot.getQRCodeFullEncryptPrivKey parent:self warn:NSLocalizedString(@"add_hd_account_show_seed_label", nil) button:NSLocalizedString(@"add_hd_account_show_seed_button", nil) andDismissAction:^{
                            [s.parentViewController dismissViewControllerAnimated:YES completion:nil];
                        }] show];
                    } else {
                        [self showBannerWithMessage:NSLocalizedString(@"xrandom_generating_failed", nil) belowView:nil belowTop:0 autoHideIn:1 withCompletion:nil];
                    }
                }];
            });
        });
    }
}


- (void)onUEntropyGeneratingWithController:(UEntropyViewController *)controller collector:(UEntropyCollector *)collector andPassword:(NSString *)password {
    float progress = kStartProgress;
    float generationProgress = 1.0 - kStartProgress - kSaveProgress;
    NSTimeInterval startGeneratingTime = [[NSDate date] timeIntervalSince1970];
    [collector onResume];
    [collector start];
    [controller onProgress:progress];
    XRandom *xrandom = [[XRandom alloc] initWithDelegate:collector];

    if (controller.testShouldCancel) {
        return;
    }

    BTHDAccount *account = nil;
    while (!account) {
        @try {
            NSData *seed = [xrandom randomWithSize:16];
            __block UEntropyViewController *c = controller;
            account = [[BTHDAccount alloc] initWithMnemonicSeed:seed password:password fromXRandom:YES andGenerationCallback:^(CGFloat p) {
                [c onProgress:kStartProgress + p * generationProgress];
            }];
        }
        @catch (NSException *exception) {
            NSLog(@"generate HD Account error %@", exception.debugDescription);
        }
    }

    progress = 1.0 - kSaveProgress;
    [controller onProgress:progress];

    words = [account seedWords:password];

    if (controller.testShouldCancel) {
        return;
    }

    [collector stop];

    [[PeerUtil instance] stopPeer];
    [BTAddressManager instance].hdAccountHot = account;
    [[PeerUtil instance] startPeer];

    while ([[NSDate new] timeIntervalSince1970] - startGeneratingTime < kMinGeneratingTime) {

    }
    [controller onSuccess];

}

- (void)successFinish:(UEntropyViewController *)controller {
    __block HotAddressAddHDAccountViewController *s = self;
    [[[DialogHDMSingularColdSeed alloc] initWithWords:words qr:[BTAddressManager instance].hdAccountHot.getQRCodeFullEncryptPrivKey parent:controller warn:NSLocalizedString(@"add_hd_account_show_seed_label", nil) button:NSLocalizedString(@"add_hd_account_show_seed_button", nil) andDismissAction:^{
        [s.parentViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }] show];

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
    __weak __block HotAddressAddHDAccountViewController *c = self;
    [[[DialogXrandomInfo alloc] initWithPermission:^{
        [c getPermisionFor:AVMediaTypeVideo completion:^(BOOL result) {
            [c getPermisionFor:AVMediaTypeAudio completion:^(BOOL result) {
                dispatch_async(dispatch_get_main_queue(), completion);
            }];
        }];
    }] showInWindow:self.view.window];
}

@end
