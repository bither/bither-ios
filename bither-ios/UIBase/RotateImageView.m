//
//  RotateImageView.m
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

#import "RotateImageView.h"

#define kRotateImageViewDuration 1

@interface RotateImageView () {
    BOOL _animating;

    void(^_completion)();
}
@end

@implementation RotateImageView

- (void)rotate {
    _animating = YES;
    _completion = nil;
    [self addAnimation];
}

- (void)animationDidStart:(CAAnimation *)anim {

}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag && _animating) {
        [self performSelector:@selector(addAnimation) withObject:nil afterDelay:0];
    } else {
        if (_completion) {
            _completion();
        }
    }
}

- (void)addAnimation {
    CAKeyframeAnimation *rotationAnimation = [self getAnimation];
    [self.layer addAnimation:rotationAnimation forKey:@"360"];
}

- (void)reset {
    [self resetWithCompletion:nil];
}

- (void)resetWithCompletion:(void (^)())completion {
    _animating = NO;
    _completion = completion;
}

- (CAKeyframeAnimation *)getAnimation {
    CAKeyframeAnimation *rotationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    NSArray *rotationValues = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0], [NSNumber numberWithFloat:(2 * M_PI)], nil];
    [rotationAnimation setValues:rotationValues];
    NSArray *rotationTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:1.0f], nil];
    [rotationAnimation setKeyTimes:rotationTimes];
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = YES;
    rotationAnimation.delegate = self;
    rotationAnimation.duration = 1;
    return rotationAnimation;
}


@end
