//
//  BackgroundTransitionView.m
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
//
#import "BackgroundTransitionView.h"

#define kBackgroundTransitionDuration (0.4f)
#define InterporateFloat(begin, end, progress) (begin + (end - begin) * progress)

@interface BackgroundTransitionView () {
    NSTimeInterval startTime;
    UIColor *startBackgroundColor;
    UIColor *endBackgroundColor;
}
@property(strong) CADisplayLink *displayLink;
@end

@implementation BackgroundTransitionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplay:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    self.displayLink.paused = YES;
}

- (void)handleDisplay:(CADisplayLink *)displayLink {
    NSTimeInterval currentTime = displayLink.timestamp + displayLink.duration * displayLink.frameInterval;
    if (startTime <= 0) {
        startTime = displayLink.timestamp;
    }
    NSTimeInterval duration = currentTime - startTime;
    if (duration >= 0 && duration < kBackgroundTransitionDuration) {
        [super setBackgroundColor:[self interporateColorWithBegin:startBackgroundColor end:endBackgroundColor progress:duration / kBackgroundTransitionDuration]];
    } else {
        self.displayLink.paused = YES;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    startBackgroundColor = self.backgroundColor;
    endBackgroundColor = backgroundColor;
    startTime = 0;
    self.displayLink.paused = NO;
}

- (void)setBackgroundColorWithoutTransition:(UIColor *)backgroundColor {
    startBackgroundColor = backgroundColor;
    endBackgroundColor = backgroundColor;
    [super setBackgroundColor:backgroundColor];
    self.displayLink.paused = YES;
}

- (UIColor *)interporateColorWithBegin:(UIColor *)beginColor end:(UIColor *)endColor progress:(CGFloat)progress {
    progress = MIN(MAX(progress, 0), 1);
    CGFloat beginR, beginG, beginB, beginA, endR, endG, endB, endA;
    [beginColor getRed:&beginR green:&beginG blue:&beginB alpha:&beginA];
    [endColor getRed:&endR green:&endG blue:&endB alpha:&endA];
    CGFloat r = InterporateFloat(beginR, endR, progress);
    CGFloat g = InterporateFloat(beginG, endG, progress);
    CGFloat b = InterporateFloat(beginB, endB, progress);
    CGFloat a = InterporateFloat(beginA, endA, progress);
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}


@end
