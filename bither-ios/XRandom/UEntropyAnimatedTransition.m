//
//  UEntropyAnimatedTransition.m
//  bither-ios
//
//  Created by noname on 14-9-29.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "UEntropyAnimatedTransition.h"

@implementation UEntropyAnimatedTransition

-(instancetype)initWithPresenting:(BOOL)presenting{
    self = [super init];
    if(self){
        self.presenting = presenting;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.3;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    fromViewController.view.userInteractionEnabled = NO;
    toViewController.view.userInteractionEnabled = NO;
    
    
    if(self.presenting){
        toViewController.view.alpha = 0;
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.alpha = 1;
        } completion:^(BOOL finished) {
            fromViewController.view.userInteractionEnabled = YES;
            toViewController.view.userInteractionEnabled = YES;
            [transitionContext completeTransition:YES];
        }];
    }else{
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.alpha = 0;
        } completion:^(BOOL finished) {
            fromViewController.view.userInteractionEnabled = YES;
            toViewController.view.userInteractionEnabled = YES;
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
