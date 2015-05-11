//
//  CheckScoreAndBgAnimatableView.m
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

#import "CheckScoreAndBgAnimatableView.h"
#import "UIColor+Util.h"

@interface CheckScoreAndBgAnimatableView () {
    NSInteger currentAnimationId;
    NSTimeInterval animDuration;
    NSTimeInterval beginTime;
    NSUInteger beginScore;

    CGFloat beginR, beginG, beginB, middleR, middleG, middleB, endR, endG, endB;
}
@property CADisplayLink *displayLink;
@end

@implementation CheckScoreAndBgAnimatableView

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
    [self firstConfigureBgColors];
    currentAnimationId = -1;
    self.score = 100;
}

- (void)animateToScore:(NSUInteger)score withAnimationId:(NSUInteger)animationId {
    [self animateToScore:score withAnimationId:animationId andDuration:kCheckScoreAndBgAnimatableViewDefaultAnimationDuration];
}

- (void)animateToScore:(NSUInteger)score withAnimationId:(NSUInteger)animationId andDuration:(NSTimeInterval)duration {
    [self animationBegin];
    score = MIN(MAX(score, 0), 100);
    self.targetScore = score;
    currentAnimationId = animationId;
    beginScore = _score;
    beginTime = -1;
    animDuration = duration;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplay:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)handleDisplay:(CADisplayLink *)displayLink {
    NSTimeInterval currentTime = displayLink.timestamp + displayLink.duration * displayLink.frameInterval;
    if (beginTime <= 0) {
        beginTime = currentTime;
    }
    if (currentTime >= beginTime + animDuration) {
        self.score = self.targetScore;
        [self animationFinish];
    } else {
        double rate = (currentTime - beginTime) / animDuration;
        NSInteger scoreDelta = (((NSInteger) self.targetScore - (NSInteger) beginScore) * rate);
        self.score = scoreDelta + beginScore;
    }
}

- (void)setScore:(NSUInteger)score {
    score = MIN(MAX(score, 0), 100);
    _score = score;
    if (self.delegate && [self.delegate respondsToSelector:@selector(displayScore:)]) {
        [self.delegate displayScore:score];
    }
    [self configureBg];
    [self setNeedsDisplay];
}

- (void)animationFinish {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    beginTime = -1;
    if (currentAnimationId > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onAnimation:endWithScore:)]) {
            [self.delegate onAnimation:currentAnimationId endWithScore:_score];
        }
        currentAnimationId = -1;
    }
}

- (void)animationBegin {
    [self animationFinish];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onAnimation:beginWithScore:)]) {
        [self.delegate onAnimation:currentAnimationId beginWithScore:_score];
    }
}

- (NSUInteger)score {
    return _score;
}

- (void)dealloc {
    if (self.displayLink) {
        [self.displayLink invalidate];
    }
}

- (void)setBeginColor:(UIColor *)color {
    [color getRed:&beginR green:&beginG blue:&beginB alpha:nil];
}

- (void)setMiddleColor:(UIColor *)color {
    [color getRed:&middleR green:&middleG blue:&middleB alpha:nil];
}

- (void)setEndColor:(UIColor *)color {
    [color getRed:&endR green:&endG blue:&endB alpha:nil];
}

- (void)firstConfigureBgColors {
    [self setBeginColor:[UIColor parseColor:0xea1010]];
    [self setMiddleColor:[UIColor parseColor:0xfdd201]];
    [self setEndColor:[UIColor parseColor:0x3bbf59]];
}

- (void)configureBg {
    if (self.score < 50) {
        self.backgroundColor = [UIColor colorWithRed:(middleR - beginR) / 50.0f * (float) self.score + beginR green:(middleG - beginG) / 50.0f * (float) self.score + beginG blue:(middleB - beginB) / 50.0f * (float) self.score + beginB alpha:1];
    } else {
        self.backgroundColor = [UIColor colorWithRed:(endR - middleR) / 50.0f * ((float) self.score - 50.0f) + middleR green:(endG - middleG) / 50.0f * ((float) self.score - 50.0f) + middleG blue:(endB - middleB) / 50.0f * ((float) self.score - 50.0f) + middleB alpha:1];
    }
}

@end
