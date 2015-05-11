//  UIBaseUtil.m
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

#import "UIBaseUtil.h"

@implementation UIView (FindUIViewController)
- (UIViewController *)getUIViewController {
    // convenience function for casting and to "mask" the recursive function
    return (UIViewController *) [self traverseResponderChainForUIViewController];
}

- (id)traverseResponderChainForUIViewController {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}

@end

@implementation UIView (GenerateImage)

- (UIImage *)generateImage {
    CGSize pageSize = self.frame.size;
    UIGraphicsBeginImageContextWithOptions(pageSize, self.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;

}

@end

@implementation UIView (Shake)

- (void)shakeTime:(NSInteger)time interval:(double)interval length:(CGFloat)length {
    [self shakeTime:time interval:interval length:length completion:nil];
}

- (void)shakeTime:(NSInteger)time interval:(double)interval length:(CGFloat)length completion:(void (^)())completion {
    [self shakeIndex:0 total:time interval:interval length:length completion:completion];
}

- (void)shakeIndex:(NSInteger)index total:(NSInteger)total interval:(double)interval length:(CGFloat)length completion:(void (^)())completion {
    if (index < total) {
        double duration = interval;
        if (index == 0 || index == total - 1) {
            duration = duration / 2;
        }
        [UIView animateWithDuration:duration animations:^{
            if (index == total - 1) {
                self.transform = CGAffineTransformIdentity;
            } else {
                if (index % 2 == 0) {
                    self.transform = CGAffineTransformMakeTranslation(-length, 0);
                } else {
                    self.transform = CGAffineTransformMakeTranslation(length, 0);
                }
            }
        }                completion:^(BOOL finished) {
            [self shakeIndex:index + 1 total:total interval:interval length:length completion:completion];
        }];
    } else {
        if (completion) {
            completion();
        }
    }
}

@end

@implementation UIWindow (TopViewController)


- (UIViewController *)topViewController {
    return [self topPresentedViewController:self.rootViewController];
}

- (UIViewController *)topPresentedViewController:(UIViewController *)root {
    if (root.presentedViewController) {
        return [self topPresentedViewController:root.presentedViewController];
    } else {
        return root;
    }
}

@end

@implementation UIBaseUtil
+ (void)makeButtonBgResizable:(UIButton *)button {
    UIImage *normalBg = [button backgroundImageForState:UIControlStateNormal];
    UIImage *highlightedBg = [button backgroundImageForState:UIControlStateHighlighted];
    normalBg = [normalBg resizableImageWithCapInsets:UIEdgeInsetsMake(normalBg.size.height / 2, normalBg.size.width / 2, normalBg.size.height / 2, normalBg.size.width / 2)];
    highlightedBg = [highlightedBg resizableImageWithCapInsets:UIEdgeInsetsMake(highlightedBg.size.height / 2, highlightedBg.size.width / 2, highlightedBg.size.height / 2, highlightedBg.size.width / 2)];
    [button setBackgroundImage:normalBg forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedBg forState:UIControlStateHighlighted];
}
@end
