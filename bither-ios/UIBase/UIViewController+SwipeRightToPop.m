//
//  UIViewController+SwipeRightToPop.m
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

#import "UIViewController+SwipeRightToPop.h"
#import "JRSwizzle.h"
#import <objc/runtime.h>

static float AnimDuration = 0.25;
static float PreVCScaleMin = 0.92;
static float PreVCMaskAlphaMax = 0.4;

@interface PiSwipeRightToPopKeyboardHandler : NSObject {
    UIResponder *_inputView;
    BOOL _inputViewObserverAdded;
}
- (void)hideKeyboard;
@end

@implementation PiSwipeRightToPopKeyboardHandler


- (id)init {
    self = [super init];
    if (self) {
        [self addInputViewObserverForSwipeRightToPop];
    }
    return self;
}

- (void)hideKeyboard {
    if (_inputView && [_inputView isFirstResponder]) {
        [_inputView resignFirstResponder];
    }
    _inputView = nil;
}

- (void)dealloc {
    [self removeInputViewObserverForSwipeRightToPop];
}

- (void)addInputViewObserverForSwipeRightToPop {
    if (!_inputViewObserverAdded) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responderDidBecomeActiveForSwipeRightToPop:) name:UITextFieldTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responderDidBecomeActiveForSwipeRightToPop:) name:UITextViewTextDidBeginEditingNotification object:nil];
        _inputViewObserverAdded = YES;
    }
}

- (void)removeInputViewObserverForSwipeRightToPop {
    if (_inputViewObserverAdded) {
        _inputView = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
        _inputViewObserverAdded = NO;
    }
}

- (void)responderDidBecomeActiveForSwipeRightToPop:(NSNotification *)notification {
    _inputView = notification.object;
}

@end


@interface PiSwipeRightToPopScrollViewGestureDelegate : NSObject <UIGestureRecognizerDelegate>
@end

@implementation PiSwipeRightToPopScrollViewGestureDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *sv = (UIScrollView *) gestureRecognizer.view;
        if (sv.contentOffset.x > 0) {
            return NO;
        } else {
            if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *) gestureRecognizer;
                if ([pan translationInView:sv].x > 0) {
                    return YES;
                }
            }
        }
        return NO;
    } else {
        return YES;
    }
}

@end


@interface SwipeRightToPopVars : NSObject
+ (SwipeRightToPopVars *)fetch:(id)targetInstance;

@property(nonatomic) BOOL shouldPreventSwipeRightToPop;
@property(nonatomic) BOOL inAnimation;
@property(nonatomic) BOOL inSwipeRightToPop;
@property(nonatomic) BOOL shown;
@property(nonatomic) BOOL inputViewObserverAdded;
@property(nonatomic, strong) PiSwipeRightToPopKeyboardHandler *keyboardHandler;
@property(nonatomic, strong) UIView *mask;
@property(nonatomic, strong) UIImageView *ivShadow;
@property(nonatomic, strong) PiSwipeRightToPopScrollViewGestureDelegate *scrollViewGestureDelegate;
@end

@implementation SwipeRightToPopVars
+ (SwipeRightToPopVars *)fetch:(id)targetInstance {
    static void *compactFetchIVarKey = &compactFetchIVarKey;
    SwipeRightToPopVars *ivars = objc_getAssociatedObject(targetInstance, &compactFetchIVarKey);
    if (ivars == nil) {
        ivars = [[SwipeRightToPopVars alloc] init];
        ivars.shouldPreventSwipeRightToPop = NO;
        ivars.inAnimation = NO;
        ivars.shown = NO;
        ivars.inSwipeRightToPop = NO;
        ivars.inputViewObserverAdded = NO;
        objc_setAssociatedObject(targetInstance, &compactFetchIVarKey, ivars, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ivars;
}
@end


@implementation UIViewController (SwipeRightToPop)

+ (void)load {
    [UIViewController jr_swizzleMethod:@selector(viewDidAppear:) withMethod:@selector(pi_swipe_right_to_pop_swizzled_viewDidAppear:) error:nil];
    [UIViewController jr_swizzleMethod:@selector(viewWillDisappear:) withMethod:@selector(pi_swipe_right_to_pop_swizzled_viewWillDisappear:) error:nil];
}

- (BOOL)shouldPop:(UIPanGestureRecognizer *)gesture {
    return [gesture translationInView:self.view].x > self.view.frame.size.width / 5;
}

- (void)pi_swipe_right_to_pop_swizzled_viewDidAppear:(BOOL)animated {
    [self pi_swipe_right_to_pop_swizzled_viewDidAppear:animated];
    self.shown = YES;
    self.inSwipeRightToPop = NO;
    [self swipeRightToPopVars].inAnimation = NO;
    if ([self canPerformSwipeRightToPop]) {
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureForSwipeRightToPop:)];
        [self.view addGestureRecognizer:panGestureRecognizer];
        panGestureRecognizer = nil;
        [self swipeRightToPopVars].keyboardHandler = [[PiSwipeRightToPopKeyboardHandler alloc] init];
    }
}

- (void)pi_swipe_right_to_pop_swizzled_viewWillDisappear:(BOOL)animated {
    self.shown = NO;
    self.inSwipeRightToPop = NO;
    if ([self swipeRightToPopVars].mask && [self swipeRightToPopVars].mask.superview) {
        [[self swipeRightToPopVars].mask removeFromSuperview];
    }
    [self swipeRightToPopVars].mask = nil;
    if ([self swipeRightToPopVars].ivShadow && [self swipeRightToPopVars].ivShadow.superview) {
        [[self swipeRightToPopVars].ivShadow removeFromSuperview];
    }
    [self swipeRightToPopVars].ivShadow = nil;
    [self swipeRightToPopVars].keyboardHandler = nil;
    [self pi_swipe_right_to_pop_swizzled_viewWillDisappear:animated];
}

- (void)handlePanGestureForSwipeRightToPop:(UIPanGestureRecognizer *)gesture {
    UIViewController *preVc = [self getPreVC];
    if (!preVc || [self swipeRightToPopVars].inAnimation) {
        return;
    }
    CGPoint translation = [gesture translationInView:self.view];

    if (translation.x >= 0) {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            [self addParentVCAsBg];
        }
        self.inSwipeRightToPop = YES;
        self.view.transform = CGAffineTransformMakeTranslation(translation.x, 0);
        CGFloat preVCScale = [self caculatePreVCScaleFromTranslationX:translation.x];
        preVc.view.transform = CGAffineTransformMakeScale(preVCScale, preVCScale);
        if ([self swipeRightToPopVars].mask) {
            [self swipeRightToPopVars].mask.alpha = [self caculatePreVCMaskAlpha:translation.x];
        }
        if ([self swipeRightToPopVars].ivShadow) {
            [self swipeRightToPopVars].ivShadow.frame = [self getShadowFrame:translation.x];
        }
        if (gesture.state == UIGestureRecognizerStateEnded) {
            if ([self shouldPop:gesture]) {
                [self animToPopForSwipeRightToPop];
            } else {
                [self animToResetForSwipeRightToPop];
            }
        }
    } else {
        if (gesture.state == UIGestureRecognizerStateEnded) {
            if ([self swipeRightToPopVars].mask) {
                [self animToResetForSwipeRightToPop];
            }
        }
    }
}

- (void)handleScrollViewForSwipeRightToPop:(UIScrollView *)sv {
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureForSwipeRightToPop:)];
    if (![self swipeRightToPopVars].scrollViewGestureDelegate) {
        [self swipeRightToPopVars].scrollViewGestureDelegate = [[PiSwipeRightToPopScrollViewGestureDelegate alloc] init];
    }
    panGestureRecognizer.delegate = [self swipeRightToPopVars].scrollViewGestureDelegate;
    [sv addGestureRecognizer:panGestureRecognizer];
}

- (void)handleScrollableForSwipeRightToPop:(id <SwipeRightToPopScrollable>)scrollable {
    if (scrollable) {
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureForSwipeRightToPop:)];
        panGestureRecognizer.delegate = scrollable;
        if ([scrollable respondsToSelector:@selector(viewsToHandle)]) {
            NSArray *views = [scrollable viewsToHandle];
            for (UIView *view in views) {
                [view addGestureRecognizer:panGestureRecognizer];
            }
        }
    }
}

- (CGFloat)caculatePreVCScaleFromTranslationX:(CGFloat)x {
    if (x <= 0) {
        return PreVCScaleMin;
    }
    if (x >= self.view.frame.size.width) {
        return 1;
    }
    return (1 - PreVCScaleMin) * (x / self.view.frame.size.width) + PreVCScaleMin;
}

- (CGFloat)caculatePreVCMaskAlpha:(CGFloat)x {
    if (x <= 0) {
        return PreVCMaskAlphaMax;
    }
    if (x >= self.view.frame.size.width) {
        return 0;
    }
    return PreVCMaskAlphaMax - PreVCMaskAlphaMax * (x / self.view.frame.size.width);
}

- (CGRect)getShadowFrame:(CGFloat)x {
    return CGRectMake(x - [self swipeRightToPopVars].ivShadow.frame.size.width + 1, [UIApplication sharedApplication].statusBarFrame.size.height, [self swipeRightToPopVars].ivShadow.frame.size.width, self.view.frame.size.height);
}

- (void)animToResetForSwipeRightToPop {
    UIViewController *preVc = [self getPreVC];
    if (!preVc) {
        return;
    }
    self.inSwipeRightToPop = YES;
    [self swipeRightToPopVars].inAnimation = YES;
    [UIView animateWithDuration:AnimDuration animations:^() {
        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
        preVc.view.transform = CGAffineTransformMakeScale(PreVCScaleMin, PreVCScaleMin);
        if ([self swipeRightToPopVars].mask) {
            [self swipeRightToPopVars].mask.alpha = PreVCMaskAlphaMax;
        }
        if ([self swipeRightToPopVars].ivShadow) {
            [self swipeRightToPopVars].ivShadow.frame = [self getShadowFrame:0];
        }
    }                completion:^(BOOL finished) {
        [self removeParentVCAsBg];
        [self swipeRightToPopVars].inAnimation = NO;
        self.inSwipeRightToPop = NO;
        [self didAnimToResetForSwipeRightToPop];
    }];
}

- (void)willAnimToPopForSwipeRight {
    self.shown = NO;
}

- (void)animToPopForSwipeRightToPop {
    UIViewController *preVc = [self getPreVC];
    if (!preVc) {
        return;
    }
    self.inSwipeRightToPop = YES;
    [self willAnimToPopForSwipeRight];
    [self swipeRightToPopVars].inAnimation = YES;
    [UIView animateWithDuration:AnimDuration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
        preVc.view.transform = CGAffineTransformIdentity;
        if ([self swipeRightToPopVars].mask) {
            [self swipeRightToPopVars].mask.alpha = 0;
        }
        if ([self swipeRightToPopVars].ivShadow) {
            [self swipeRightToPopVars].ivShadow.frame = [self getShadowFrame:self.view.frame.size.width];
        }
    }                completion:^(BOOL finished) {
        [self removeParentVCAsBg];
        [self.navigationController popViewControllerAnimated:NO];
        [self swipeRightToPopVars].inAnimation = NO;
    }];
}

- (void)addParentVCAsBg {
    UIViewController *preVc = [self getPreVC];
    if (!preVc) {
        return;
    }
    [self hideKeyboardForSwipeRightToPop];
    CGRect preVCFrame = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [self swipeRightToPopVars].mask = [[UIView alloc] initWithFrame:preVCFrame];
    [self swipeRightToPopVars].mask.backgroundColor = [UIColor blackColor];
    [self swipeRightToPopVars].mask.alpha = PreVCMaskAlphaMax;
    UIImage *imgShadow = [UIImage imageNamed:@"picommon.bundle/swipe_right_to_pop_shadow"];
    CGFloat width = imgShadow.size.width;
    imgShadow = [imgShadow resizableImageWithCapInsets:UIEdgeInsetsMake(imgShadow.size.height / 2, 0, imgShadow.size.height / 2, imgShadow.size.width)];
    [self swipeRightToPopVars].ivShadow = [[UIImageView alloc] initWithFrame:CGRectMake(0 - width + 1, [UIApplication sharedApplication].statusBarFrame.size.height, width, self.view.frame.size.height)];
    [self swipeRightToPopVars].ivShadow.image = imgShadow;
    preVc.view.frame = preVCFrame;
    preVc.view.transform = CGAffineTransformIdentity;
    [self.view.window insertSubview:preVc.view atIndex:0];
    [self.view.window insertSubview:[self swipeRightToPopVars].mask atIndex:1];
    [self.view.window addSubview:[self swipeRightToPopVars].ivShadow];
}

- (void)hideKeyboardForSwipeRightToPop {
    if ([self swipeRightToPopVars].keyboardHandler) {
        [[self swipeRightToPopVars].keyboardHandler hideKeyboard];
    }
}


- (void)removeParentVCAsBg {
    UIViewController *preVc = [self getPreVC];
    if (!preVc) {
        return;
    }
    if ([self swipeRightToPopVars].mask) {
        [[self swipeRightToPopVars].mask removeFromSuperview];
    }
    [self swipeRightToPopVars].mask = nil;

    if ([self swipeRightToPopVars].ivShadow) {
        [[self swipeRightToPopVars].ivShadow removeFromSuperview];
    }
    [self swipeRightToPopVars].ivShadow = nil;

    preVc.view.transform = CGAffineTransformIdentity;
    [preVc.view setNeedsLayout];
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    if (![viewControllers containsObject:preVc]) {
        [viewControllers insertObject:preVc atIndex:viewControllers.count - 1];
    }
    self.navigationController.viewControllers = viewControllers;
    [preVc.view removeFromSuperview];
}

- (UIViewController *)getPreVC {
    if (self.navigationController && self.navigationController.viewControllers.count > 1) {
        return [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    } else {
        return nil;
    }
}

- (BOOL)canPerformSwipeRightToPop {
    if (![self shouldSwipeRightToPop]) {
        return NO;
    }
    if (self.parentViewController && ![self.parentViewController isKindOfClass:[UINavigationController class]]) {
        return NO;
    }
    if (self.parentViewController && [self.parentViewController isKindOfClass:[UINavigationController class]]) {
        if ([self.parentViewController respondsToSelector:@selector(shouldSwipeRightToPop)]) {
            if (![self.parentViewController shouldSwipeRightToPop]) {
                return NO;
            }
        }
    }
    return self.navigationController && self.navigationController.viewControllers.count > 1 && (self.parentViewController == nil || [self.parentViewController isKindOfClass:[UINavigationController class]]);
}

- (void)setShouldSwipeRightToPop:(BOOL)shouldSwipeRightToPop {
    [self swipeRightToPopVars].shouldPreventSwipeRightToPop = !shouldSwipeRightToPop;
}

- (BOOL)shouldSwipeRightToPop {
    return ![self swipeRightToPopVars].shouldPreventSwipeRightToPop;
}

- (SwipeRightToPopVars *)swipeRightToPopVars {
    return [SwipeRightToPopVars fetch:self];
}

- (BOOL)inSwipeRightToPop {
    return [self swipeRightToPopVars].inSwipeRightToPop;
}

- (void)setInSwipeRightToPop:(BOOL)inSwipeRightToPop {
    [self swipeRightToPopVars].inSwipeRightToPop = inSwipeRightToPop;
}

- (BOOL)shown {
    return [self swipeRightToPopVars].shown;
}

- (void)setShown:(BOOL)shown {
    [self swipeRightToPopVars].shown = shown;
}

- (void)didAnimToResetForSwipeRightToPop {
}

- (void)reload {
}

@end