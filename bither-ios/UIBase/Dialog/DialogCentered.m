//
//  DialogCentered.m
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

#import "DialogCentered.h"
#import "UIBaseUtil.h"

#define kDefaultInsets UIEdgeInsetsMake(16,16,16,16)
#define kShowAnimDuration 0.1
#define kDismissAnimDuration 0.1
#define kDimAmount 0.5
#define kAnimScale 0.9

@interface DialogCentered () {
    CGRect windowFrame;
    BOOL _touchOutsideNotToDismiss;
    CGFloat _dimAmount;
}
@property(nonatomic, weak) UIViewController *topVC;
@property(nonatomic, strong) UIViewController *vc;
@property(nonatomic, strong) UIImageView *ivBg;
@property(nonatomic, strong) UIButton *btnModal;
@end

@implementation DialogCentered

- (void)showInWindow:(UIWindow *)window completion:(void (^)())completion {
    if (self.shown) {
        if (completion) {
            completion();
        }
        return;
    }
    self.shown = YES;
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    self.topVC = [window topViewController];
    windowFrame = self.topVC.view.frame;
    windowFrame.size.height = windowFrame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
    [self resize];
    [self initModal];
    self.btnModal.alpha = 0;
    self.alpha = 0;
    [self dialogWillShow];
    self.transform = CGAffineTransformMakeScale(kAnimScale, kAnimScale);

    if (self.vc == nil) {
        self.vc = [[UIViewController alloc] init];
    }
    self.vc.view.backgroundColor = [UIColor clearColor];
    if (self.btnModal.superview == nil) {
        [self.vc.view addSubview:self.btnModal];
    }
    if (self.superview == nil) {
        [self.vc.view addSubview:self];
    }
    [self.topVC addChildViewController:self.vc];
    [self.topVC.view addSubview:self.vc.view];
    [UIView animateWithDuration:kShowAnimDuration delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^() {
        self.btnModal.alpha = self.dimAmount;
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    }                completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
        [self dialogDidShow];
    }];
}

- (void)resize {
    [self adjustSize];
    [self adjustOriPoint];
    [self initBg];
}

- (void)showInWindow:(UIWindow *)window {
    [self showInWindow:window completion:nil];
}

- (void)dismissWithCompletion:(void (^)())completion {
    if (!self.shown) {
        if (completion) {
            completion();
        }
        return;
    }
    [self dialogWillDismiss];
    [self.btnModal removeTarget:self action:@selector(modalTouch:) forControlEvents:UIControlEventTouchUpInside];
    [UIView animateWithDuration:kDismissAnimDuration delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.btnModal.alpha = 0;
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(kAnimScale, kAnimScale);
    }                completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
        // must remove these views in this sequence
        [self removeFromSuperview];
        [self.btnModal removeFromSuperview];
        [self.vc.view removeFromSuperview];
        [self.vc removeFromParentViewController];
        self.vc = nil;
        self.transform = CGAffineTransformIdentity;
        self.shown = NO;
        [self dialogDidDismiss];
    }];
}

- (void)dismiss {
    [self dismissWithCompletion:nil];
}

- (void)modalTouch:(id)sender {
    if (self.touchOutSideToDismiss) {
        [self dismiss];
    }
}

- (void)initModal {
    if (!self.btnModal) {
        self.btnModal = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, windowFrame.size.width, windowFrame.size.height)];
        self.btnModal.backgroundColor = [UIColor blackColor];
        self.btnModal.alpha = self.dimAmount;
    }
    self.btnModal.frame = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, windowFrame.size.width, windowFrame.size.height);
    [self.btnModal addTarget:self action:@selector(modalTouch:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initBg {
    if (!self.backgroundImage) {
        self.backgroundImage = [UIImage imageNamed:@"center_dialog_background"];
    }
    self.ivBg.image = self.backgroundImage;
    self.ivBg.frame = CGRectMake(-self.bgInsets.left, -self.bgInsets.top, self.frame.size.width + self.bgInsets.left + self.bgInsets.right, self.frame.size.height + self.bgInsets.top + self.bgInsets.bottom);
}

- (void)adjustOriPoint {
    float x = (windowFrame.size.width - self.frame.size.width) / 2;
    float y = (windowFrame.size.height - self.frame.size.height) / 2 + [UIApplication sharedApplication].statusBarFrame.size.height;
    CGRect frame = self.frame;
    frame.origin = CGPointMake(x, y);
    self.frame = frame;
}

- (UIImageView *)ivBg {
    if (!_ivBg) {
        _ivBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self insertSubview:_ivBg atIndex:0];
    }
    return _ivBg;
}

- (UIEdgeInsets)bgInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(_bgInsets, UIEdgeInsetsZero)) {
        _bgInsets = kDefaultInsets;
    }
    return _bgInsets;
}

- (void)adjustSize {
    if (self.frame.size.width > windowFrame.size.width - self.bgInsets.left - self.bgInsets.right || self.frame.size.height > windowFrame.size.height - self.bgInsets.top - self.bgInsets.bottom) {
        CGRect frame = self.frame;
        frame.size.width = fminf(frame.size.width, windowFrame.size.width - self.bgInsets.left - self.bgInsets.right);
        frame.size.height = fminf(frame.size.height, windowFrame.size.height - self.bgInsets.top - self.bgInsets.bottom);
        self.frame = frame;
    }
}

- (void)setDimAmount:(CGFloat)dimAmount {
    _dimAmount = dimAmount;
}

- (CGFloat)dimAmount {
    if (_dimAmount == 0) {
        _dimAmount = kDimAmount;
    }
    return _dimAmount;
}

- (void)setTouchOutSideToDismiss:(BOOL)touchOutSideToDismiss {
    _touchOutsideNotToDismiss = !touchOutSideToDismiss;
}

- (BOOL)touchOutSideToDismiss {
    return !_touchOutsideNotToDismiss;
}

- (void)dialogWillShow {

}

- (void)dialogDidShow {

}

- (void)dialogWillDismiss {

}

- (void)dialogDidDismiss {

}

@end
