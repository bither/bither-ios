//
//  UIViewController+SwipeRightToPop.h
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

@protocol SwipeRightToPopScrollable <NSObject, UIGestureRecognizerDelegate>
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;

- (NSArray *)viewsToHandle;
@end

@interface UIViewController (SwipeRightToPop)
@property BOOL shouldSwipeRightToPop;   // should be set before viewDidAppear
@property BOOL inSwipeRightToPop;
@property BOOL shown;

- (void)handleScrollViewForSwipeRightToPop:(UIScrollView *)sv;

- (void)handleScrollableForSwipeRightToPop:(id <SwipeRightToPopScrollable>)scrollable;

- (void)willAnimToPopForSwipeRight;

- (void)didAnimToResetForSwipeRightToPop;

- (void)reload;
@end
