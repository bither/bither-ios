//
//  HotAddressAddHDMViewController.m
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
//  Created by songchenwen on 15/2/2.
//

#import "HotAddressAddHDMViewController.h"
#import "UIViewController+PiShowBanner.h"
#import "HDMHotAddUtil.h"
#import "HDMTriangleBgView.h"
#import "DialogHDMInfo.h"
#import "DialogHDMSingularColdSeed.h"
#import "DialogHDMSingularModeInfo.h"

@interface HotAddressAddHDMViewController () <HDMHotAddUtilDelegate> {
    UIImageView *flashingIv;
    CGFloat containerFullWidth;
    CGFloat containerFullTop;
    BOOL shouldGoSingular;
}
@property(weak, nonatomic) IBOutlet UIView *vContainer;
@property(weak, nonatomic) IBOutlet HDMTriangleBgView *vBg;
@property(weak, nonatomic) IBOutlet UIImageView *ivHotLight;
@property(weak, nonatomic) IBOutlet UIImageView *ivColdLight;
@property(weak, nonatomic) IBOutlet UIImageView *ivServerLight;
@property(weak, nonatomic) IBOutlet UIButton *btnHot;
@property(weak, nonatomic) IBOutlet UIButton *btnCold;
@property(weak, nonatomic) IBOutlet UIButton *btnServer;
@property(weak, nonatomic) IBOutlet UILabel *lblHot;
@property(weak, nonatomic) IBOutlet UILabel *lblCold;
@property(weak, nonatomic) IBOutlet UILabel *lblServer;
@property(weak, nonatomic) IBOutlet UIView *vSingularModeContainer;
@property(weak, nonatomic) IBOutlet UIView *vSingularModeRunning;
@property(weak, nonatomic) IBOutlet UIView *vSingularModeChecking;
@property(weak, nonatomic) IBOutlet UIButton *btnSingularModeCheck;
@property(weak, nonatomic) IBOutlet UIView *vTopbar;

@property HDMHotAddUtil *util;
@end

@implementation HotAddressAddHDMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    containerFullTop = self.vContainer.frame.origin.y;
    containerFullWidth = self.vContainer.frame.size.width;
    shouldGoSingular = NO;
    [self configureHDMSingularView];
    [self configureContainerFull];
    if (!self.util) {
        self.util = [[HDMHotAddUtil alloc] initWithViewContoller:self];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showFlash:flashingIv];
}

- (void)moveToHot:(BOOL)anim andCompletion:(void (^)())completion {
    self.btnHot.enabled = YES;
    self.btnHot.selected = NO;
    self.btnCold.enabled = NO;
    self.btnCold.selected = NO;
    self.btnServer.enabled = NO;
    self.btnServer.selected = NO;
    [self showFlash:self.ivHotLight];
    if (completion) {
        completion();
    }
}

- (void)moveToCold:(BOOL)anim andCompletion:(void (^)())completion {
    self.btnHot.enabled = NO;
    self.btnHot.selected = YES;
    self.btnServer.enabled = NO;
    self.btnServer.selected = NO;
    self.btnCold.selected = NO;
    if (!anim) {
        [self.vBg addLineFromView:self.btnHot toView:self.btnCold];
        self.btnCold.enabled = YES;
        [self showFlash:self.ivColdLight];
        if (completion) {
            completion();
        }
    } else {
        [self stopAllFlash];
        [self.vBg addLineAnimatedFromView:self.btnHot toView:self.btnCold completion:^{
            [self showFlash:self.ivColdLight];
            self.btnCold.enabled = YES;
            if (completion) {
                completion();
            }
        }];
    }
}

- (void)moveToServer:(BOOL)anim andCompletion:(void (^)())completion {
    if (self.btnServer.enabled) {
        return;
    }
    self.btnHot.enabled = NO;
    self.btnHot.selected = YES;
    self.btnCold.enabled = NO;
    self.btnCold.selected = YES;
    self.btnServer.selected = NO;
    if (!anim) {
        [self.vBg addLineFromView:self.btnCold toView:self.btnServer];
        self.btnServer.enabled = YES;
        [self showFlash:self.ivServerLight];
        if (completion) {
            completion();
        }
    } else {
        [self stopAllFlash];
        [self.vBg addLineAnimatedFromView:self.btnCold toView:self.btnServer completion:^{
            [self showFlash:self.ivServerLight];
            self.btnServer.enabled = YES;
            if (completion) {
                completion();
            }
        }];
    }
}

- (void)moveToFinal:(BOOL)animToFinish andCompletion:(void (^)())completion {
    [self.util refreshHDMLimit];
    self.btnHot.enabled = NO;
    self.btnHot.selected = YES;
    self.btnCold.enabled = NO;
    self.btnCold.selected = YES;
    self.btnServer.enabled = NO;
    self.btnServer.selected = YES;
    [self stopAllFlash];
    if (!animToFinish) {
        [self.vBg addLineFromView:self.btnServer toView:self.btnHot];
        if (self.util.isHDMKeychainLimited) {
            self.btnHot.enabled = YES;
            self.btnCold.enabled = YES;
            self.btnServer.enabled = YES;
        }
        if (completion) {
            completion();
        }
    } else {
        [self.vBg addLineAnimatedFromView:self.btnServer toView:self.btnHot completion:^{
            if (completion) {
                completion();
            } else {
                [self finalAnimation];
            }
        }];
    }
}

- (void)finalAnimation {
    NSTimeInterval fadeDuration = 0.4;
    NSTimeInterval zoomDuration = 0.5;
    NSTimeInterval spinDuration = 2;
    NSTimeInterval fadeOutOffset = 0.3;
    [UIView animateWithDuration:fadeDuration animations:^{
        self.vBg.alpha = 0;
        self.lblHot.alpha = 0;
        self.lblCold.alpha = 0;
        self.lblServer.alpha = 0;
        self.vSingularModeContainer.alpha = 0;
    }                completion:^(BOOL finished) {
        [UIView animateWithDuration:zoomDuration animations:^{
            [self configureContainerCompact];
        }                completion:^(BOOL finished) {
            self.vContainer.layer.anchorPoint = CGPointMake(0.5, 0.5);
            CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotate.removedOnCompletion = FALSE;
            rotate.fillMode = kCAFillModeForwards;
            [rotate setToValue:[NSNumber numberWithFloat:-M_PI / 2]];
            rotate.repeatCount = 80;
            rotate.duration = spinDuration / rotate.repeatCount;
            rotate.cumulative = TRUE;
            rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            [self.vContainer.layer addAnimation:rotate forKey:@"ROTATE"];
            if ([[UIDevice currentDevice].systemVersion floatValue] < 8) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) ((spinDuration - fadeOutOffset) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.parentViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
                        [self.vContainer.layer removeAllAnimations];
                    }];
                });
                return;
            }
            [UIView animateWithDuration:spinDuration - fadeOutOffset * 2 delay:fadeOutOffset options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.vContainer.alpha = 0.1;
                self.vContainer.transform = CGAffineTransformMakeScale(2, 2);
            }                completion:^(BOOL finished) {
                [self.parentViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
                    [self.vContainer.layer removeAllAnimations];
                }];
            }];
        }];
    }];
}

- (void)setSingularModeAvailable:(BOOL)available {
    self.vSingularModeContainer.hidden = !available;
}

- (void)onSingularModeBegin {
    self.vSingularModeChecking.hidden = YES;
    self.vSingularModeRunning.hidden = NO;
}

- (BOOL)shouldGoSingularMode {
    return shouldGoSingular;
}

- (void)singularShowNetworkFailure {
    [self showMsg:NSLocalizedString(@"Network failure.", nil)];
    self.vSingularModeRunning.hidden = YES;
    self.vSingularModeChecking.hidden = NO;
    [self.vBg removeAllLines];
    self.util = [[HDMHotAddUtil alloc] initWithViewContoller:self];
}

- (IBAction)singularModeInfoPressed:(id)sender {
    [[[DialogHDMSingularModeInfo alloc] init] showFromView:sender];
}

- (void)singularServerFinishWithWords:(NSArray *)words andColdQr:(NSString *)qr {
    __block HotAddressAddHDMViewController *s = self;
    [[[DialogHDMSingularColdSeed alloc] initWithWords:words qr:qr parent:self andDismissAction:^{
        [s finalAnimation];
    }] show];
}

- (void)configureContainerFull {
    CGFloat height = [self containerHeightForWidth:containerFullWidth];
    self.vContainer.frame = CGRectMake((self.view.frame.size.width - containerFullWidth) / 2, containerFullTop, containerFullWidth, height);
}

- (void)configureContainerCompact {
    CGFloat btnWidth = self.btnHot.frame.size.width;
    CGFloat fullHeight = [self containerHeightForWidth:containerFullWidth];
    CGFloat width = btnWidth * 2;
    CGFloat height = [self containerHeightForWidth:width];
    self.vContainer.frame = CGRectMake((self.view.frame.size.width - width) / 2, containerFullTop + (fullHeight - height) / 2, width, height);
}

- (CGFloat)containerHeightForWidth:(CGFloat)width {
    CGFloat btnWidth = self.btnHot.frame.size.width;
    return (width - btnWidth) / 2 * tan(M_PI / 3) + btnWidth + self.lblServer.frame.size.height;
}

- (void)stopAllFlash {
    [self showFlash:nil];
}

- (void)showFlash:(UIImageView *)iv {
    flashingIv = iv;
    NSArray *ivs = @[self.ivHotLight, self.ivColdLight, self.ivServerLight];
    for (UIImageView *v in ivs) {
        if (v != iv) {
            [v.layer removeAllAnimations];
            v.hidden = YES;
        }
    }
    if (iv) {
        iv.alpha = 0;
        iv.hidden = NO;
        [UIView animateWithDuration:0.8 delay:0.2 options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
            iv.alpha = 1;
        }                completion:nil];
    }
}

- (IBAction)singularModeCheckPressed:(id)sender {
    shouldGoSingular = !shouldGoSingular;
    if (shouldGoSingular) {
        [self.btnSingularModeCheck setImage:[UIImage imageNamed:@"btn_check_on_holo_light"] forState:UIControlStateNormal];
    } else {
        [self.btnSingularModeCheck setImage:[UIImage imageNamed:@"btn_check_off_holo_light"] forState:UIControlStateNormal];
    }
}

- (void)configureHDMSingularView {
    CGFloat oriWidth = self.btnSingularModeCheck.frame.size.width;
    [self.btnSingularModeCheck sizeToFit];
    CGFloat deltaWidth = self.btnSingularModeCheck.frame.size.width - oriWidth;
    CGRect frame = self.vSingularModeChecking.frame;
    frame.size.width += deltaWidth;
    frame.origin.x -= deltaWidth / 2;
    self.vSingularModeChecking.frame = frame;
    self.vSingularModeRunning.frame = frame;
}

- (IBAction)hotPressed:(id)sender {
    [self.util hot];
}

- (IBAction)coldPressed:(id)sender {
    [self.util cold];
}

- (IBAction)serverPressed:(id)sender {
    [self.util server];
}

- (IBAction)hdmInfoPressed:(id)sender {
    [[[DialogHDMInfo alloc] init] showInWindow:self.view.window];
}

- (IBAction)cancelPressed:(id)sender {
    if (!self.util.canCancel) {
        [self showBannerWithMessage:NSLocalizedString(@"hdm_singular_mode_cancel_warn", nil) belowView:self.vTopbar];
        return;
    }
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showMsg:(NSString *)msg {
    [self showBannerWithMessage:msg belowView:self.vTopbar];
}
@end
