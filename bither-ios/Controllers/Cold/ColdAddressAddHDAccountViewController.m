//
//  ColdAddressAddHDAccountViewController.m
//  bither-ios
//
//  Created by 宋辰文 on 15/7/15.
//  Copyright (c) 2015年 Bither. All rights reserved.
//

#import <Bitheri/BTHDAccount.h>
#import "ColdAddressAddHDAccountViewController.h"
#import "UEntropyViewController.h"
#import "DialogPassword.h"
#import "DialogXrandomInfo.h"
#import "DialogAlert.h"
#import "DialogProgress.h"
#import "DialogHDMSingularColdSeed.h"
#import "UIViewController+PiShowBanner.h"
#import "BTHDAccountCold.h"

@import AVFoundation;

#import <Bitheri/BTAddressManager.h>

#define kSaveProgress (0.1)
#define kStartProgress (0.3)
#define kMinGeneratingTime (2.4)

@interface ColdAddressAddHDAccountViewController () <DialogPasswordDelegate, UEntropyViewControllerDelegate> {
    NSArray *words;
}
@property(weak, nonatomic) IBOutlet UIButton *btnXRandomCheck;

@end

@implementation ColdAddressAddHDAccountViewController

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
            BTHDAccountCold *account = nil;
            while (!account) {
                @try {
                    NSData *seed = [xRandom randomWithSize:16];
                    account = [[BTHDAccountCold alloc] initWithMnemonicSeed:seed password:password andFromXRandom:NO];
                }
                @catch (NSException *exception) {
                    NSLog(@"generate HD Account error %@", exception.debugDescription);
                }
            }
            words = [account seedWords:password];
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [d dismissWithCompletion:^{
                    if (account) {
                        __block ColdAddressAddHDAccountViewController *s = self;
                        [[[DialogHDMSingularColdSeed alloc] initWithWords:words qr:[BTAddressManager instance].hdAccountCold.getQRCodeFullEncryptPrivKey parent:self warn:NSLocalizedString(@"add_hd_account_show_seed_label", nil) button:NSLocalizedString(@"add_hd_account_show_seed_button", nil) andDismissAction:^{
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

    BTHDAccountCold *account = nil;
    while (!account) {
        @try {
            NSData *seed = [xrandom randomWithSize:16];
            account = [[BTHDAccountCold alloc] initWithMnemonicSeed:seed password:password andFromXRandom:YES];
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

    while ([[NSDate new] timeIntervalSince1970] - startGeneratingTime < kMinGeneratingTime) {

    }
    [controller onSuccess];

}

- (void)successFinish:(UEntropyViewController *)controller {
    __block ColdAddressAddHDAccountViewController *s = self;
    [[[DialogHDMSingularColdSeed alloc] initWithWords:words qr:[BTAddressManager instance].hdAccountCold.getQRCodeFullEncryptPrivKey parent:controller warn:NSLocalizedString(@"add_hd_account_show_seed_label", nil) button:NSLocalizedString(@"add_hd_account_show_seed_button", nil) andDismissAction:^{
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
    __weak __block ColdAddressAddHDAccountViewController *c = self;
    [[[DialogXrandomInfo alloc] initWithPermission:^{
        [c getPermisionFor:AVMediaTypeVideo completion:^(BOOL result) {
            [c getPermisionFor:AVMediaTypeAudio completion:^(BOOL result) {
                dispatch_async(dispatch_get_main_queue(), completion);
            }];
        }];
    }] showInWindow:self.view.window];
}

@end
