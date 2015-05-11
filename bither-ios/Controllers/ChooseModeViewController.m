//
//  ChooseModeViewController.m
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

#import "ChooseModeViewController.h"
#import "UIColor+Util.h"
#import "BlockUtil.h"
#import "UserDefaultsUtil.h"
#import "IOS7ContainerViewController.h"
#import "ColdModeCheckConnectionView.h"
#import "PeerUtil.h"
#import "BitherTime.h"
#import "DialogAlert.h"

#define kChooseModeGradientCenterColor (0x8881a2)
#define kChooseModeGradientColdColor (0x10a0df)
#define kChooseModeGradientHotColor (0xfc6463)
#define kChooseModeStateTransactionDuration (0.6)

@interface ChooseModeViewController () {
    void(^coldNetCheckCompletion)(BOOL);
}
@property(weak, nonatomic) IBOutlet UIView *vColdContainer;
@property(weak, nonatomic) IBOutlet UIView *vHotContainer;
@property(weak, nonatomic) IBOutlet UIView *vColdIcon;
@property(weak, nonatomic) IBOutlet UIView *vHotIcon;
@property(weak, nonatomic) IBOutlet UIView *vColdCheck;
@property(weak, nonatomic) IBOutlet UIView *vHotWait;
@property(weak, nonatomic) IBOutlet UIView *vHotProgress;
@property(weak, nonatomic) IBOutlet UIView *vHotRetry;
@property(weak, nonatomic) IBOutlet UIButton *btnSwitchToCold;
@property(weak, nonatomic) IBOutlet UIButton *btnRetry;
@property(weak, nonatomic) IBOutlet UIButton *btnHot;
@property(weak, nonatomic) IBOutlet UIButton *btnCold;
@property(weak, nonatomic) IBOutlet ColdModeCheckConnectionView *vColdNetCheck;

@end

@interface ChooseModeViewController (States)
- (void)showColdCheckWithCompletion:(void (^)())completion;

- (void)showColdCheck;

- (void)showColdIconWithCompletion:(void (^)())completion;

- (void)showColdIcon;

- (void)showHotWaitWithCompletion:(void (^)())completion;

- (void)showHotWait;

- (void)showHotIconWithCompletion:(void (^)())completion;

- (void)showHotIcon;
@end

@interface ChooseModeViewController (ConfigureView)
- (void)configureView;
@end

@interface ChooseModeViewController (DowloadSpvDelegate) <DowloadSpvDelegate>
@end

@interface ChooseModeViewController (AfterChoose)
- (void)toHotView;

- (void)toColdView;
@end

@implementation ChooseModeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    [[BlockUtil instance] syncSpvBlock];
    if (![[BTSettings instance] needChooseMode]) {
        if ([[BTSettings instance] getAppMode] == HOT && ![[BlockUtil instance] syncSpvFinish]) {
            [BlockUtil instance].delegate = self;
            [[BlockUtil instance] syncSpvBlock];
            self.vHotProgress.hidden = NO;
            self.vHotRetry.hidden = YES;
            [self showHotWait];

        }
        if ([[BTSettings instance] getAppMode] == COLD) {
            [self showColdCheckWithCompletion:^{
                [self.vColdNetCheck beginCheck:coldNetCheckCompletion];
            }];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)coldCheckWithoutAnimationAgain {
    [self.vColdNetCheck beginCheck:coldNetCheckCompletion];
}

- (IBAction)coldButtonPressed:(id)sender {
    if (![BTSettings instance].needChooseMode) {
        return;
    }
    [[[DialogAlert alloc] initWithAttributedMessage:[self getAttributedWarningMessage:NSLocalizedString(@"choose_mode_cold_confirm", nil)] confirm:^{
        [[BTSettings instance] setAppMode:COLD];
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
        [self showColdCheckWithCompletion:^{
            [self.vColdNetCheck beginCheck:coldNetCheckCompletion];
        }];
    }                                        cancel:nil] showInWindow:self.view.window];
}

- (IBAction)hotButtonPressed:(id)sender {
    if (![BTSettings instance].needChooseMode) {
        return;
    }
    [[[DialogAlert alloc] initWithAttributedMessage:[self getAttributedWarningMessage:NSLocalizedString(@"choose_mode_warm_confirm", nil)] confirm:^{
        [[BTSettings instance] setAppMode:HOT];
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
        [[BitherTime instance] start];
        self.vHotProgress.hidden = NO;
        self.vHotRetry.hidden = YES;
        if (![[BlockUtil instance] syncSpvFinish]) {
            [self showHotWaitWithCompletion:^{
                self.vHotProgress.hidden = NO;
                self.vHotRetry.hidden = YES;
                if (![[BlockUtil instance] syncSpvFinish]) {
                    [BlockUtil instance].delegate = self;
                    [[BlockUtil instance] syncSpvBlock];
                } else {
                    [self showHotIconWithCompletion:^{
                        [self toHotView];
                    }];
                }
            }];
        } else {
            [self showHotWaitWithCompletion:^{
                self.vHotProgress.hidden = NO;
                self.vHotRetry.hidden = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self showHotIconWithCompletion:^{
                        [self toHotView];
                    }];
                });
            }];
        }
    }                                        cancel:nil] showInWindow:self.view.window];
}

- (IBAction)hotRetryPressed:(id)sender {
    [BlockUtil instance].delegate = self;
    [[BlockUtil instance] syncSpvBlock];
    self.vHotRetry.hidden = YES;
    self.vHotProgress.hidden = NO;
}

- (IBAction)switchToColdPressed:(id)sender {
    [[[DialogAlert alloc] initWithAttributedMessage:[self getAttributedWarningMessage:NSLocalizedString(@"launch_sequence_switch_to_cold_warn", nil)] confirm:^{
        [[BTSettings instance] setAppMode:COLD];
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
        [self showColdCheckWithCompletion:^{
            [self.vColdNetCheck beginCheck:coldNetCheckCompletion];
        }];
    }                                        cancel:nil] showInWindow:self.view.window];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (NSAttributedString *)getAttributedWarningMessage:(NSString *)str {
    NSUInteger firstLineBreak = [str rangeOfString:@"\n"].location;
    if ([str characterAtIndex:firstLineBreak + 1] == '\n') {
        str = [[str substringToIndex:firstLineBreak + 1] stringByAppendingString:[str substringFromIndex:firstLineBreak + 2]];
    }
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacing = 5;
    [attr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kDialogAlertLabelFontSize], NSForegroundColorAttributeName : [UIColor whiteColor], NSParagraphStyleAttributeName : paragraphStyle} range:NSMakeRange(0, str.length)];
    [attr addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:kDialogAlertLabelFontSize * 1.2], NSForegroundColorAttributeName : [UIColor redColor]} range:NSMakeRange(0, firstLineBreak)];
    return attr;
}

@end

@implementation ChooseModeViewController (States)

- (void)showColdCheckWithCompletion:(void (^)())completion {
    [self.view bringSubviewToFront:self.vHotContainer];
    self.vColdCheck.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.vColdIcon.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [UIView animateWithDuration:kChooseModeStateTransactionDuration animations:^{
        [self showColdCheck];
    }                completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)showColdCheck {
    self.vColdCheck.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.vColdIcon.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self showCold];
}

- (void)showColdIconWithCompletion:(void (^)())completion {
    [self.view bringSubviewToFront:self.vHotContainer];
    self.vColdCheck.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.vColdIcon.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [UIView animateWithDuration:kChooseModeStateTransactionDuration animations:^{
        [self showColdIcon];
    }                completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)showColdIcon {
    self.vColdCheck.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.vColdIcon.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [self showCold];
    [self setView:self.vColdIcon height:CGRectGetHeight(self.vColdIcon.frame) y:(CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.vColdIcon.frame)) / 2];
    [self setView:self.vColdCheck height:0 y:CGRectGetHeight(self.view.frame)];
}

- (void)showHotWaitWithCompletion:(void (^)())completion {
    [self.view bringSubviewToFront:self.vColdContainer];
    self.vHotIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.vHotWait.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [UIView animateWithDuration:kChooseModeStateTransactionDuration animations:^{
        [self showHotWait];
    }                completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)showHotWait {
    self.vHotIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.vHotWait.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self showHot];
}

- (void)showHotIconWithCompletion:(void (^)())completion {
    [self.view bringSubviewToFront:self.vColdContainer];
    self.vHotIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.vHotWait.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [UIView animateWithDuration:kChooseModeStateTransactionDuration animations:^{
        [self showHotIcon];
    }                completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)showHotIcon {
    self.vHotIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.vHotWait.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self showHot];
    [self setView:self.vHotIcon height:CGRectGetHeight(self.vHotIcon.frame) y:(CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.vHotIcon.frame)) / 2];
    [self setView:self.vHotWait height:0 y:0];
}

- (void)showCold {
    [self setView:self.vColdContainer height:CGRectGetHeight(self.view.frame) y:0];
    [self setView:self.vHotContainer height:CGRectGetHeight(self.vHotContainer.frame) y:CGRectGetHeight(self.view.frame)];
}

- (void)showHot {
    [self setView:self.vHotContainer height:CGRectGetHeight(self.view.frame) y:0];
    [self setView:self.vColdContainer height:CGRectGetHeight(self.vColdContainer.frame) y:0 - CGRectGetHeight(self.vColdContainer.frame)];
}

- (void)setView:(UIView *)view height:(CGFloat)height y:(CGFloat)y {
    CGRect frame = view.frame;
    frame.size.height = height;
    frame.origin.y = y;
    view.frame = frame;
}
@end

@implementation ChooseModeViewController (DowloadSpvDelegate)

- (void)success {
    [BlockUtil instance].delegate = nil;
    self.vHotRetry.hidden = YES;
    self.vHotProgress.hidden = NO;
    [self showHotIconWithCompletion:^{
        [self toHotView];
    }];
    [[PeerUtil instance] startPeer];

}

- (void)error {
    self.vHotRetry.hidden = NO;
    self.vHotProgress.hidden = YES;
}

@end

@implementation ChooseModeViewController (AfterChoose)

- (void)toHotView {
    [self toViewWithIdentifier:@"BitherHot" zoomView:self.btnHot];
}

- (void)toColdView {
    [self toViewWithIdentifier:@"BitherCold" zoomView:self.btnCold];
}

- (void)toViewWithIdentifier:(NSString *)identifier zoomView:(UIView *)zoom {
    IOS7ContainerViewController *container = [[IOS7ContainerViewController alloc] init];
    container.controller = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    [[UIApplication sharedApplication].keyWindow insertSubview:container.view atIndex:0];
    [UIView animateWithDuration:kChooseModeStateTransactionDuration animations:^{
        zoom.transform = CGAffineTransformMakeScale(2, 2);
        self.view.alpha = 0;
    }                completion:^(BOOL finished) {
        [container.view removeFromSuperview];
        [UIApplication sharedApplication].keyWindow.rootViewController = container;
    }];
}

@end

@implementation ChooseModeViewController (ConfigureView)

- (void)configureView {
    [self.view setBackgroundColor:[UIColor parseColor:kChooseModeGradientCenterColor]];
    CGRect frame = self.vColdCheck.frame;
    frame.size.width = self.view.frame.size.width;
    frame.origin.y = self.vColdContainer.frame.size.height;
    self.vColdCheck.frame = frame;

    frame = self.vHotWait.frame;
    frame.size.width = self.view.frame.size.width;
    frame.origin.y = 0;
    self.vHotWait.frame = frame;

    self.vHotIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.vHotWait.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    self.vColdCheck.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.vColdIcon.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    self.vColdNetCheck.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height / 2);
    self.vHotProgress.hidden = YES;
    CGFloat width = [self.btnSwitchToCold sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width + 20;
    self.btnSwitchToCold.frame = CGRectMake(self.btnSwitchToCold.frame.origin.x - (width - self.btnSwitchToCold.frame.size.width) / 2, self.btnSwitchToCold.frame.origin.y, width, self.btnSwitchToCold.frame.size.height);
    [self gradientViewWithStart:[UIColor parseColor:kChooseModeGradientColdColor] end:[UIColor parseColor:kChooseModeGradientCenterColor] view:self.vColdContainer];
    [self gradientViewWithStart:[UIColor parseColor:kChooseModeGradientCenterColor] end:[UIColor parseColor:kChooseModeGradientHotColor] view:self.vHotContainer];
    __weak ChooseModeViewController *c = self;
    coldNetCheckCompletion = ^(BOOL passed) {
        if (passed) {
            [c showColdIconWithCompletion:^{
                [c toColdView];
            }];
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [c coldCheckWithoutAnimationAgain];
            });
        }
    };
}

- (void)gradientViewWithStart:(UIColor *)start end:(UIColor *)end view:(UIView *)view {
    UIImage *image = [UIColor gradientFromColor:start toColor:end withHeight:self.view.frame.size.height];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    iv.image = image;
    iv.contentMode = UIViewContentModeScaleToFill;
    iv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [view insertSubview:iv atIndex:0];
}
@end
