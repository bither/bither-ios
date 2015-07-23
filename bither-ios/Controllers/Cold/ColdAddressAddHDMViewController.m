//
//  ColdAddressAddHDMViewController.m
//  bither-ios
//
//  Created by 宋辰文 on 15/1/29.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import "ColdAddressAddHDMViewController.h"
#import "DialogProgress.h"
#import "DialogPassword.h"
#import "DialogAlert.h"
#import "UEntropyViewController.h"
#import <Bitheri/BTAddressManager.h>
#import "DialogXrandomInfo.h"
#import "UIViewController+PiShowBanner.h"

@import AVFoundation;

#define kSaveProgress (0.1)
#define kStartProgress (0.01)
#define kProgressKeyRate (0.5)
#define kProgressEncryptRate (0.5)
#define kMinGeneratingTime (2.4)

@interface ColdAddressAddHDMViewController () <DialogPasswordDelegate, UEntropyViewControllerDelegate>
@property(weak, nonatomic) IBOutlet UIView *vNotice;
@property(weak, nonatomic) IBOutlet UITextView *tvNotice;
@property(weak, nonatomic) IBOutlet UIView *vBottom;
@property(weak, nonatomic) IBOutlet UIButton *btnXRandomCheck;
@property (weak, nonatomic) IBOutlet UIView *topBar;

@end

@implementation ColdAddressAddHDMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tvNotice.text = NSLocalizedString(@"hdm_seed_generation_notice", nil);
    CGFloat noticeHeight = [self.tvNotice sizeThatFits:CGSizeMake(self.tvNotice.frame.size.width, CGFLOAT_MAX)].height;
    noticeHeight = ceilf(noticeHeight);
    noticeHeight = noticeHeight + self.tvNotice.frame.origin.y * 2;
    CGRect frame = self.vNotice.frame;
    frame.size.height = noticeHeight;
    self.vNotice.frame = frame;
    frame = self.vBottom.frame;
    frame.origin.y = CGRectGetMaxY(self.vNotice.frame);
    self.vBottom.frame = frame;
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
    __weak __block ColdAddressAddHDMViewController *c = self;
    [[[DialogXrandomInfo alloc] initWithPermission:^{
        [c getPermisionFor:AVMediaTypeVideo completion:^(BOOL result) {
            [c getPermisionFor:AVMediaTypeAudio completion:^(BOOL result) {
                dispatch_async(dispatch_get_main_queue(), completion);
            }];
        }];
    }] showInWindow:self.view.window];
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
                [d dismissWithCompletion:^{
                    if (keychain) {
                        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                    } else {
                        [self showBannerWithMessage:NSLocalizedString(@"xrandom_generating_failed", nil) belowView:self.topBar];
                    }
                }];
            });
        });
    }
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

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)successFinish:(UEntropyViewController *)controller {
    [controller.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
