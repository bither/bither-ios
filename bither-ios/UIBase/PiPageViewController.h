//
//  PiPageViewController.h
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
#import "UIViewController+SwipeRightToPop.h"

@protocol PiPageViewControllerDelegate <NSObject>

- (void)pageIndexChanged:(int)index;

@optional
- (UIViewController *)loadViewControllerAtIndex:(int)index;

- (void)onViewController:(UIViewController *)viewController loadedAtIndex:(int)index;

- (void)onViewController:(UIViewController *)viewController visitedAtIndex:(int)index;
@end


@interface PiPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, SwipeRightToPopScrollable> {
    int _index;
}

@property(nonatomic) int index;
@property(weak, nonatomic) id <PiPageViewControllerDelegate> pageDelegate;
@property BOOL pageEnabled;

- (void)setIndex:(int)index animated:(BOOL)animated;

- (UIViewController *)currentViewController;

- (UIViewController *)viewControllerAtIndex:(int)index;

- (id)initWithStoryboard:(UIStoryboard *)storyboard andViewControllerIdentifiers:(NSArray *)identifiers;

- (id)initWithStoryboard:(UIStoryboard *)storyboard viewControllerIdentifiers:(NSArray *)identifiers andPageDelegate:(NSObject <PiPageViewControllerDelegate> *)pageDelegate;

@end
