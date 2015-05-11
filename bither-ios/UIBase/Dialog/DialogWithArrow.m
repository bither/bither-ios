//
//  DialogWithArrow.m
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

#import "DialogWithArrow.h"
#import "UIBaseUtil.h"

#define kArrowWidth (19)
#define kArrowHeight (9)

#define kMinHorizontalMargin (10)

@interface DialogWithArrow ()
@property(weak) UIView *fromView;
@property UIImageView *ivArrow;
@end

@implementation DialogWithArrow

- (void)showFromView:(UIView *)view {
    [self showFromView:view completion:nil];
}

- (void)showFromView:(UIView *)view completion:(void (^)())completion {
    self.fromView = view;
    self.ivArrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kArrowWidth, kArrowHeight)];
    [self addSubview:self.ivArrow];
    [self showInWindow:view.window completion:completion];
}

- (void)dialogWillShow {
    [super dialogWillShow];
    CGRect fromViewInWindowFrame = [self.fromView.window.topViewController.view convertRect:CGRectMake(0, 0, self.fromView.frame.size.width, self.fromView.frame.size.height) fromView:self.fromView];
    CGFloat x = CGRectGetMidX(fromViewInWindowFrame) - self.frame.size.width / 2;
    x = MIN(MAX(x, self.bgInsets.left + kMinHorizontalMargin), self.fromView.window.topViewController.view.frame.size.width - self.bgInsets.right - self.frame.size.width - kMinHorizontalMargin);
    CGFloat y = 0;
    CGFloat arrowY = 0;
    BOOL isArrowOnTop = [self isArrowOnTop];
    if (isArrowOnTop) {
        self.ivArrow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.ivArrow.contentMode = UIViewContentModeBottom;
        self.ivArrow.image = [UIImage imageNamed:@"dialog_arrow_top"];
        arrowY = -self.bgInsets.top - kArrowHeight;
        y = CGRectGetMaxY(fromViewInWindowFrame) + kArrowHeight + self.bgInsets.top;
    } else {
        self.ivArrow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.ivArrow.contentMode = UIViewContentModeTop;
        self.ivArrow.image = [UIImage imageNamed:@"dialog_arrow_bottom"];
        arrowY = self.frame.size.height + self.bgInsets.bottom;
        y = fromViewInWindowFrame.origin.y - kArrowHeight - self.bgInsets.bottom - self.frame.size.height;
    }
    CGFloat arrowX = CGRectGetMidX(fromViewInWindowFrame) - x - kArrowWidth / 2;
    arrowX = MIN(MAX(0, arrowX), self.frame.size.width - kArrowWidth);
    self.frame = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
    self.ivArrow.frame = CGRectMake(arrowX, arrowY, kArrowWidth, kArrowHeight);
}

- (BOOL)arrowAlwaysOnTop {
    return NO;
}

- (BOOL)isArrowOnTop {
    if (self.arrowAlwaysOnTop) {
        return YES;
    }
    CGFloat dialogHeight = self.frame.size.height + self.bgInsets.bottom + self.bgInsets.top;
    CGFloat windowHeight = self.fromView.window.topViewController.view.frame.size.height;
    CGFloat fromViewTop = [self.fromView.window.topViewController.view convertPoint:CGPointMake(0, 0) fromView:self.fromView].y;
    CGFloat fromViewBottom = [self.fromView.window.topViewController.view convertPoint:CGPointMake(0, self.fromView.frame.size.height) fromView:self.fromView].y;
    if (fromViewBottom + dialogHeight + kArrowHeight > windowHeight) {
        return NO;
    }
    return YES;
}

@end
