//
//  PiPageViewController.m
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

#import "PiPageViewController.h"

#define kPiPageViewControllerResetTransitionFlagDelay (1)

@interface PiPageViewController () {
    UIStoryboard *_storyboardPassedIn;
    NSArray *_identifiers;
    NSMutableDictionary *_viewControllers;
    BOOL _inTransation;
    int _futureIndex;
    BOOL _pageEnabled;
}

@end

@implementation PiPageViewController

- (id)initWithStoryboard:(UIStoryboard *)storyboard andViewControllerIdentifiers:(NSArray *)identifiers {
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    if (self) {
        _pageEnabled = YES;
        _storyboardPassedIn = storyboard;
        _identifiers = identifiers;
        _viewControllers = [[NSMutableDictionary alloc] init];
        _inTransation = NO;
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}


- (id)initWithStoryboard:(UIStoryboard *)storyboard viewControllerIdentifiers:(NSArray *)identifiers andPageDelegate:(NSObject <PiPageViewControllerDelegate> *)pageDelegate {
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    if (self) {
        self.pageDelegate = pageDelegate;
        _pageEnabled = YES;
        _storyboardPassedIn = storyboard;
        _identifiers = identifiers;
        _viewControllers = [[NSMutableDictionary alloc] init];
        _inTransation = NO;
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (void)viewDidLoad {
    if (_index == 0) {
        _index = -1;
        self.index = 0;
    }
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            UIScrollView *s = v;
            s.delaysContentTouches = NO;
            s.canCancelContentTouches = YES;
        }
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    _futureIndex = [self indexOfViewController:[pendingViewControllers objectAtIndex:pendingViewControllers.count - 1]];
    [self onVisitedViewControllerAtIndex:_futureIndex];
    _inTransation = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetInTransationFlag) object:nil];
    [self performSelector:@selector(resetInTransationFlag) withObject:nil afterDelay:kPiPageViewControllerResetTransitionFlagDelay];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    _inTransation = NO;
    if (!completed) {
        return;
    }
    [self onIndexSet:_futureIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    int index = [self indexOfViewController:viewController];
    return [self loadViewControllerAtIndex:index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    int index = [self indexOfViewController:viewController];
    return [self loadViewControllerAtIndex:index + 1];
}

- (int)index {
    return _index;
}

- (void)setIndex:(int)index {
    [self setIndex:index animated:NO];
}

- (void)setIndex:(int)index animated:(BOOL)animated {
    if (index == _index || _inTransation) {
        return;
    }
    if (!_pageEnabled) {
        return;
    }
    _inTransation = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetInTransationFlag) object:nil];
    [self performSelector:@selector(resetInTransationFlag) withObject:nil afterDelay:kPiPageViewControllerResetTransitionFlagDelay];
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    if (index < _index) {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }

    int step = direction == UIPageViewControllerNavigationDirectionForward ? 1 : -1;
    for (int i = _index + step; (index - i) * step > 0; i += step) {
        NSArray *vcs = [[NSArray alloc] initWithObjects:[self loadViewControllerAtIndex:i], nil];
        [self onVisitedViewControllerAtIndex:i];
        [self setViewControllers:vcs direction:direction animated:animated completion:nil];
    }

    NSArray *vcs = [[NSArray alloc] initWithObjects:[self loadViewControllerAtIndex:index], nil];
    __weak PiPageViewController *vc = self;
    [self onVisitedViewControllerAtIndex:index];
    [self setViewControllers:vcs direction:direction animated:animated completion:^(BOOL finished) {
        [vc onIndexSet:index];
    }];
    if (!animated) {
        [self onIndexSet:index];
    }
}

- (void)resetInTransationFlag {
    _inTransation = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)onIndexSet:(int)index {
    _index = index;
    _inTransation = NO;
    [self sendPageIndexChangedMessage];
}

- (UIViewController *)currentViewController {
    return [self viewControllerAtIndex:self.index];
}

- (UIViewController *)viewControllerAtIndex:(int)index {
    return [self loadViewControllerAtIndex:index];
}

- (UIViewController *)loadViewControllerAtIndex:(int)index {
    if (![self shouldUseDelegateViewControllers]) {
        if (index < 0 || index >= _identifiers.count) {
            return nil;
        }
    }
    UIViewController *vc = [_viewControllers objectForKey:[NSNumber numberWithInt:index]];
    if (!vc) {
        if ([self shouldUseDelegateViewControllers]) {
            vc = [self.pageDelegate loadViewControllerAtIndex:index];
        } else {
            vc = [_storyboardPassedIn instantiateViewControllerWithIdentifier:[_identifiers objectAtIndex:index]];
        }
        if (vc) {
            if (self.pageDelegate && [self.pageDelegate respondsToSelector:@selector(onViewController:loadedAtIndex:)]) {
                [self.pageDelegate onViewController:vc loadedAtIndex:index];
            }
            [_viewControllers setObject:vc forKey:[NSNumber numberWithInt:index]];
        }
    }
    return vc;
}

- (void)sendPageIndexChangedMessage {
    if (self.pageDelegate && [self.pageDelegate respondsToSelector:@selector(pageIndexChanged:)]) {
        [self.pageDelegate pageIndexChanged:_index];
    }
}


- (NSUInteger)indexOfViewController:(UIViewController *)viewController {
    __block NSUInteger index = NSNotFound;
    [_viewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj == viewController) {
            index = [key integerValue];
        }
    }];
    return index;
}

- (BOOL)shouldUseDelegateViewControllers {
    return self.pageDelegate && [self.pageDelegate respondsToSelector:@selector(loadViewControllerAtIndex:)];
}

- (NSUInteger)pageViewControllerSupportedInterfaceOrientations:(UIPageViewController *)pageViewController {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)onVisitedViewControllerAtIndex:(int)index {
    if (self.pageDelegate && [self.pageDelegate respondsToSelector:@selector(onViewController:visitedAtIndex:)]) {
        [self.pageDelegate onViewController:[self loadViewControllerAtIndex:index] visitedAtIndex:index];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *) gestureRecognizer;
        if ([pan translationInView:self.view].x <= 0) {
            return NO;
        }
        return ![self pageViewController:self viewControllerBeforeViewController:[self currentViewController]];
    }
    return YES;
}

- (NSArray *)viewsToHandle {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [array addObject:view];
        }
    }
    return array;
}

- (void)setPageEnabled:(BOOL)pageEnabled {
    _pageEnabled = pageEnabled;
    self.view.userInteractionEnabled = pageEnabled;
}

- (BOOL)pageEnabled {
    return _pageEnabled;
}

@end
