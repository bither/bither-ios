//
//  UIViewController+PiShowBanner.m
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

#import "UIViewController+PiShowBanner.h"
#import "UIColor+Util.h"

#define kPiShowBannerTop (44)
#define kPiShowBannerHeight (44)
#define kPiShowBannerFontSize (14)
#define kPiShowBannerAlpha (0.98)
#define kPiShowBannerSlideDuration (0.2)
#define kPiShowBannerShowDuration (1)

@implementation UIViewController (PiShowBanner)

- (void)showBannerWithMessage:(NSString *)msg belowView:(UIView *)topView belowTop:(CGFloat)top autoHideIn:(NSTimeInterval)secs withCompletion:(void (^)())completion {
    UIView *banner = [self getBannerWithMessage:msg];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, top, self.view.frame.size.width, banner.frame.size.height)];
    container.backgroundColor = [UIColor clearColor];
    [container addSubview:banner];
    banner.transform = CGAffineTransformMakeTranslation(0, -container.frame.size.height);
    if (topView && topView.superview == self.view) {
        [self.view insertSubview:container belowSubview:topView];
    } else {
        [self.view addSubview:container];
    }
    [UIView animateWithDuration:kPiShowBannerSlideDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        banner.transform = CGAffineTransformIdentity;
    }                completion:^(BOOL finished) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (secs * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [UIView animateWithDuration:kPiShowBannerSlideDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                banner.transform = CGAffineTransformMakeTranslation(0, -container.frame.size.height);
            }                completion:^(BOOL finished) {
                [container removeFromSuperview];
                if (completion) {
                    completion();
                }
            }];
        });
    }];
}

- (void)showBannerWithMessage:(NSString *)msg belowView:(UIView *)topView autoHideIn:(NSTimeInterval)secs withCompletion:(void (^)())completion {
    [self showBannerWithMessage:msg belowView:topView belowTop:kPiShowBannerTop autoHideIn:secs withCompletion:completion];
}


- (void)showBannerWithMessage:(NSString *)msg belowView:(UIView *)topView autoHideIn:(NSTimeInterval)secs {
    [self showBannerWithMessage:msg belowView:topView belowTop:kPiShowBannerTop autoHideIn:secs withCompletion:nil];

}

- (void)showBannerWithMessage:(NSString *)msg belowView:(UIView *)topView withCompletion:(void (^)())completion {
    [self showBannerWithMessage:msg belowView:topView belowTop:kPiShowBannerTop autoHideIn:kPiShowBannerShowDuration withCompletion:completion];
}

- (void)showBannerWithMessage:(NSString *)msg belowView:(UIView *)topView {
    [self showBannerWithMessage:msg belowView:topView belowTop:kPiShowBannerTop autoHideIn:kPiShowBannerShowDuration withCompletion:nil];
}

- (UIView *)getBannerWithMessage:(NSString *)msg {
    UIView *bannerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kPiShowBannerHeight)];
    bannerContainer.backgroundColor = [[UIColor parseColor:0xffba26] colorWithAlphaComponent:0.95];
    bannerContainer.clipsToBounds = YES;
    UIImageView *ivBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bannerContainer.frame.size.width, bannerContainer.frame.size.height)];
    UIColor *textColor = [UIColor darkTextColor];
    ivBg.image = nil;

    UILabel *lbl = [[UILabel alloc] initWithFrame:ivBg.frame];
    lbl.font = [UIFont systemFontOfSize:kPiShowBannerFontSize];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.textColor = textColor;
    lbl.text = msg;

    [bannerContainer addSubview:ivBg];
    [bannerContainer addSubview:lbl];
    bannerContainer.alpha = kPiShowBannerAlpha;
    return bannerContainer;
}

@end
