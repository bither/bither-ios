//
//  HotAddressAddPrivateKeyViewController.m
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

#import "HotAddressAddPrivateKeyViewController.h"
#import "BitherSetting.h"
#import "DialogProgress.h"
#import "DialogPassword.h"
#import "DialogAlert.h"
#import "UEntropyViewController.h"
#import <Bitheri/BTAddressManager.h>
#import "KeyUtil.h"
#import "DialogXrandomInfo.h"
#import "UIViewController+PiShowBanner.h"
#import "BTPrivateKeyUtil.h"

@import AVFoundation;

#define kSaveProgress (0.1)
#define kStartProgress (0.01)
#define kProgressKeyRate (0.5)
#define kProgressEncryptRate (0.5)
#define kMinGeneratingTime (2.4)

@interface HotAddressAddPrivateKeyViewController ()
@property(weak, nonatomic) IBOutlet UIPickerView *pvCount;
@property(weak, nonatomic) IBOutlet UIButton *btnXRandomCheck;
@property(weak, nonatomic) IBOutlet UIView *vTopbar;
@property(weak, nonatomic) IBOutlet UIView *vContainer;
@property int countToGenerate;
@end

@interface HotAddressAddPrivateKeyViewController (DialogPassword) <DialogPasswordDelegate>
@end

@interface HotAddressAddPrivateKeyViewController (UIPickerViewDataSource) <UIPickerViewDataSource, UIPickerViewDelegate>
@end

@interface HotAddressAddPrivateKeyViewController (UEntropy) <UEntropyViewControllerDelegate>
@end

@implementation HotAddressAddPrivateKeyViewController
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[BTSettings instance] getAppMode] == COLD) {
        self.limit = PRIVATE_KEY_OF_COLD_COUNT_LIMIT;
    } else {
        self.limit = PRIVATE_KEY_OF_HOT_COUNT_LIMIT;
    }
    self.countToGenerate = 1;
    self.pvCount.delegate = self;
    self.pvCount.dataSource = self;
}

- (UIViewController *)successDismissingViewController {
    return self.parentViewController.presentingViewController.presentingViewController;
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

- (IBAction)xrandomInfoPressed:(id)sender {
    [[[DialogXrandomInfo alloc] initWithGuide:YES] showInWindow:self.view.window];
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
    __weak __block HotAddressAddPrivateKeyViewController *c = self;
    [[[DialogXrandomInfo alloc] initWithPermission:^{
        [c getPermisionFor:AVMediaTypeVideo completion:^(BOOL result) {
            [c getPermisionFor:AVMediaTypeAudio completion:^(BOOL result) {
                dispatch_async(dispatch_get_main_queue(), completion);
            }];
        }];
    }] showInWindow:self.view.window];
}

@end

@implementation HotAddressAddPrivateKeyViewController (DialogPassword)

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
            BOOL result = [KeyUtil addPrivateKeyByRandom:xRandom passphras:password count:self.countToGenerate];
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [d dismissWithCompletion:^{
                    if (result) {
                        [self.successDismissingViewController dismissViewControllerAnimated:YES completion:nil];
                    } else {
                        [self showBannerWithMessage:NSLocalizedString(@"xrandom_generating_failed", nil) belowView:self.vTopbar];
                    }
                }];
            });
        });
    }
}

@end

@implementation HotAddressAddPrivateKeyViewController (UIPickerViewDataSource)

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger preCount = [BTAddressManager instance].privKeyAddresses.count;
    return self.limit - preCount;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%ld", row + 1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.countToGenerate = (int) (row + 1);
}

@end

@implementation HotAddressAddPrivateKeyViewController (UEntropy)

- (void)onUEntropyGeneratingWithController:(UEntropyViewController *)controller collector:(UEntropyCollector *)collector andPassword:(NSString *)password {
    UInt32 count = self.countToGenerate;
    float progress = kStartProgress;
    float itemProgress = (1.0 - kStartProgress - kSaveProgress) / (float) count;
    NSTimeInterval startGeneratingTime = [[NSDate date] timeIntervalSince1970];
    [collector onResume];
    [collector start];
    [controller onProgress:progress];
    XRandom *xrandom = [[XRandom alloc] initWithDelegate:collector];
    NSMutableArray *addresses = [NSMutableArray new];

    for (int i = 0; i < count; i++) {
        if (controller.testShouldCancel) {
            return;
        }

        NSData *data = [xrandom randomWithSize:32];
        if (data) {
            BTKey *key = [BTKey keyWithSecret:data compressed:YES];
            key.isFromXRandom = YES;
            NSLog(@"uentropy outcome data %d/%lu", i + 1, (unsigned long) count);
            progress += itemProgress * kProgressKeyRate;
            [controller onProgress:progress];
            if (controller.testShouldCancel) {
                return;
            }

            NSString *privateKeyString = [BTPrivateKeyUtil getPrivateKeyString:key passphrase:password];
            if (!privateKeyString) {
                [controller onFailed];
                return;
            }
            BTAddress *btAddress = [[BTAddress alloc] initWithKey:key encryptPrivKey:privateKeyString isSyncComplete:YES isXRandom:YES];
            [addresses addObject:btAddress];
            progress += itemProgress * kProgressEncryptRate;
            [controller onProgress:progress];
        } else {
            [controller onFailed];
            return;
        }
    }

    if (controller.testShouldCancel) {
        return;
    }

    [collector stop];
    [KeyUtil addAddressList:addresses];
    while ([[NSDate new] timeIntervalSince1970] - startGeneratingTime < kMinGeneratingTime) {

    }
    [controller onSuccess];

}

- (IBAction)cancelPressed:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)successFinish:(UEntropyViewController *)controller {
    UInt32 count = self.countToGenerate;
    __block UIWindow *window = controller.view.window;
    __block UIViewController *dismissingVc = self.successDismissingViewController;
    [dismissingVc dismissViewControllerAnimated:YES completion:^{
        DialogAlert *alert = [[DialogAlert alloc] initWithMessage:[NSString stringWithFormat:NSLocalizedString(@"xrandom_final_confirm", nil), count] confirm:nil cancel:nil];
        [alert showInWindow:window];
    }];
}

@end