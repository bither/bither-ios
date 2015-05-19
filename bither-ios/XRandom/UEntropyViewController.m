//
//  UEntropyViewController.m
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

#import "UEntropyViewController.h"
#import "UEntropyCamera.h"
#import "UEntropyMic.h"
#import "UEntropySensor.h"
#import "DialogAlert.h"
#import "DialogProgress.h"
#import "UEntropyAnimatedTransition.h"
#import "UIColor+Util.h"
#import "KeyUtil.h"
#import "PlaySoundUtil.h"

#define kMicViewHeight (100)

@interface UEntropyViewController () <UEntropyCollectorDelegate, UIViewControllerTransitioningDelegate> {
    NSString *password;
    BOOL isFinishing;

    void(^cancelBlock)();

    DialogProgress *dpStopping;
    UIProgressView *pv;
    UIView *vOverlayTop;
    UIView *vOverlayBottom;
    UIImageView *ivOverlayTop;
    UIImageView *ivOverlayBottom;
}
@property UEntropyCollector *collector;
@property(weak) NSObject <UEntropyViewControllerDelegate> *delegate;
@end

@implementation UEntropyViewController

- (instancetype)initWithPassword:(NSString *)inPassword andDelegate:(NSObject <UEntropyViewControllerDelegate> *)delegate {
    self = [super init];
    if (self) {
        password = inPassword;
        self.delegate = delegate;
        self.transitioningDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *dimmer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    dimmer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    dimmer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:dimmer];

    SensorVisualizerView *vSensor = [[SensorVisualizerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - kSensorVisualizerViewItemSize - 10, self.view.frame.size.width, kSensorVisualizerViewItemSize)];
    vSensor.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    vSensor.showMic = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] == AVAuthorizationStatusAuthorized;
    [self.view addSubview:vSensor];

    self.collector = [[UEntropyCollector alloc] initWithDelegate:self];
    [self.collector addSource:[[UEntropyCamera alloc] initWithViewController:self.view andCollector:self.collector],
                              [[UEntropyMic alloc] initWithView:nil andCollector:self.collector],
                              [[UEntropySensor alloc] initWithView:vSensor andCollecor:self.collector],
                    nil];
    dpStopping = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"xrandom_stopping", nil)];
    dpStopping.touchOutSideToDismiss = NO;
    [self configureOverlay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.collector onPause];
    [self.collector stop];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startAnimation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)startAnimation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ivOverlayTop.hidden = NO;
        ivOverlayBottom.hidden = NO;
        [UIView animateWithDuration:0.6 animations:^{
            vOverlayTop.frame = CGRectMake(0, -vOverlayTop.frame.size.height, vOverlayTop.frame.size.width, vOverlayTop.frame.size.height);
            vOverlayBottom.frame = CGRectMake(0, self.view.frame.size.height, vOverlayBottom.frame.size.width, vOverlayBottom.frame.size.height);
        }                completion:nil];
        [PlaySoundUtil playSound:@"xrandom_open_sound" callback:^{
            [self startGenerate];
        }];
    });
}

- (void)stopAnimationWithCompletion:(void (^)())completion {
    [UIView animateWithDuration:0.4 animations:^{
        vOverlayTop.frame = CGRectMake(0, 0, vOverlayTop.frame.size.width, vOverlayTop.frame.size.height);
        vOverlayBottom.frame = CGRectMake(0, self.view.frame.size.height - vOverlayBottom.frame.size.height, vOverlayBottom.frame.size.width, vOverlayBottom.frame.size.height);
    }                completion:^(BOOL finished) {
        ivOverlayTop.hidden = YES;
        ivOverlayBottom.hidden = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), completion);
    }];
    [PlaySoundUtil playSound:@"xrandom_close_sound" callback:nil];
}

- (void)close:(id)sender {
    if (isFinishing) {
        return;
    }
    __block __weak UEntropyViewController *c = self;
    __block __weak DialogProgress *dp = dpStopping;
    [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"xrandom_cancel_confirm", nil) confirm:^{
        isFinishing = YES;
        [dp showInWindow:self.view.window completion:^{
            cancelBlock = ^{
                [dp dismissWithCompletion:^{
                    [c stopAnimationWithCompletion:^{
                        [c dismissViewControllerAnimated:YES completion:nil];
                    }];
                }];
            };
        }];
    }                              cancel:nil] showInWindow:self.view.window];
}

- (void)onNoSourceAvailable {
    [self.collector onPause];
    NSLog(@"no source available");
}

- (void)onProgress:(float)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [pv setProgress:progress animated:YES];
    });
}

- (void)onSuccess {
    [self.collector stop];
    [self.collector onPause];
    [self onProgress:1];
    dispatch_async(dispatch_get_main_queue(), ^{
        isFinishing = YES;
        __weak __block UEntropyViewController *c = self;
        void(^block)() = ^{
            [c stopAnimationWithCompletion:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(successFinish:)]) {
                    [self.delegate successFinish:self];
                } else {
                    [c dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        };
        if (dpStopping.shown) {
            [dpStopping dismissWithCompletion:block];
        } else {
            block();
        }
    });
}

- (void)onFailed {
    [self.collector stop];
    [self.collector onPause];
    dispatch_async(dispatch_get_main_queue(), ^{
        isFinishing = YES;
        __weak __block UEntropyViewController *c = self;
        __weak __block DialogProgress *dp = dpStopping;
        void(^block)() = ^{
            if (dp.shown) {
                [dp dismissWithCompletion:^{
                    [c stopAnimationWithCompletion:^{
                        [c dismissViewControllerAnimated:YES completion:nil];
                    }];
                }];
            } else {
                [c stopAnimationWithCompletion:^{
                    [c dismissViewControllerAnimated:YES completion:nil];
                }];
            }
        };
        NSString *msg;
        if (self.collector.sources.count == 0) {
            msg = NSLocalizedString(@"xrandom_no_source", nil);
        } else {
            msg = NSLocalizedString(@"xrandom_generating_failed", nil);
        }
        [[[DialogAlert alloc] initWithMessage:msg confirm:block cancel:block] showInWindow:self.view.window];
    });
}


- (BOOL)testShouldCancel {
    if (cancelBlock) {
        [self.collector stop];
        [self.collector onPause];
        dispatch_async(dispatch_get_main_queue(), cancelBlock);
        return YES;
    }
    return NO;
}

- (void)startGenerate {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onUEntropyGeneratingWithController:collector:andPassword:)]) {
            [self.delegate onUEntropyGeneratingWithController:self collector:self.collector andPassword:password];
        } else {
            [self onFailed];
        }
    });
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)configureOverlay {
    pv = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    pv.progressTintColor = [[UIColor parseColor:0x7ce24d] colorWithAlphaComponent:0.8];
    pv.trackTintColor = [UIColor clearColor];
    pv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    pv.progress = 0;
    [self.view addSubview:pv];

    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose setImage:[UIImage imageNamed:@"scan_cancel"] forState:UIControlStateNormal];
    [btnClose setImage:[UIImage imageNamed:@"scan_cancel_pressed"] forState:UIControlStateHighlighted];
    [btnClose addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [btnClose sizeToFit];
    btnClose.frame = CGRectMake(10, 10, btnClose.frame.size.width, btnClose.frame.size.height);
    [self.view addSubview:btnClose];

    vOverlayTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height / 2)];
    vOverlayTop.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [vOverlayTop setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"xrandom_overlay_tile"]]];
    vOverlayBottom = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height / 2, self.view.frame.size.width, self.view.frame.size.height / 2)];
    vOverlayBottom.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [vOverlayBottom setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"xrandom_overlay_tile"]]];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xrandom_overlay_logo_top"]];
    iv.frame = CGRectMake((vOverlayTop.frame.size.width - iv.frame.size.width) / 2, vOverlayTop.frame.size.height - iv.frame.size.height, iv.frame.size.width, iv.frame.size.height);
    [vOverlayTop addSubview:iv];
    iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xrandom_overlay_logo_bottom"]];
    iv.frame = CGRectMake((vOverlayBottom.frame.size.width - iv.frame.size.width) / 2, 0, iv.frame.size.width, iv.frame.size.height);
    [vOverlayBottom addSubview:iv];
    ivOverlayTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xrandom_overlay_line_down"]];
    ivOverlayTop.image = [ivOverlayTop.image resizableImageWithCapInsets:UIEdgeInsetsMake(0, ivOverlayTop.image.size.width / 2, ivOverlayTop.image.size.height - 1, ivOverlayTop.image.size.width / 2)];
    ivOverlayBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xrandom_overlay_line_up"]];
    ivOverlayBottom.image = [ivOverlayBottom.image resizableImageWithCapInsets:UIEdgeInsetsMake(ivOverlayBottom.image.size.height - 1, ivOverlayBottom.image.size.width / 2, 0, ivOverlayBottom.image.size.width / 2)];
    ivOverlayTop.frame = CGRectMake(0, vOverlayTop.frame.size.height - ivOverlayTop.frame.size.height, vOverlayTop.frame.size.width, ivOverlayTop.frame.size.height);
    ivOverlayBottom.frame = CGRectMake(0, 0, vOverlayBottom.frame.size.width, ivOverlayBottom.frame.size.height);
    ivOverlayTop.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    ivOverlayBottom.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [vOverlayTop addSubview:ivOverlayTop];
    [vOverlayBottom addSubview:ivOverlayBottom];
    ivOverlayTop.hidden = YES;
    ivOverlayBottom.hidden = YES;
    [self.view addSubview:vOverlayTop];
    [self.view addSubview:vOverlayBottom];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[UEntropyAnimatedTransition alloc] initWithPresenting:YES];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if (dismissed == self) {
        return [[UEntropyAnimatedTransition alloc] initWithPresenting:NO];
    }
    return nil;
}

@end
