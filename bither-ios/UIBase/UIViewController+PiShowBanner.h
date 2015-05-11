//
//  UIViewController+PiShowBanner.h
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

#import <UIKit/UIKit.h>

@protocol ShowBannerDelegete <NSObject>
- (void)showBannerWithMessage:(NSString *)msg;
@end

@interface UIViewController (PiShowBanner)
- (void)showBannerWithMessage:(NSString *)msg belowView:(UIView *)topView;

- (void)showBannerWithMessage:(NSString *)msg belowView:(UIView *)topView withCompletion:(void (^)())completion;

- (void)showBannerWithMessage:(NSString *)msg belowView:(UIView *)topView autoHideIn:(NSTimeInterval)secs;

- (void)showBannerWithMessage:(NSString *)msg belowView:(UIView *)topView autoHideIn:(NSTimeInterval)secs withCompletion:(void (^)())completion;

- (void)showBannerWithMessage:(NSString *)msg belowView:(UIView *)topView belowTop:(CGFloat)top autoHideIn:(NSTimeInterval)secs withCompletion:(void (^)())completion;
@end
