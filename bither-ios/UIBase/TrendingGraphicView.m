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

#import "TrendingGraphicView.h"

#define kTransformDuration (0.3)
#define kHorizontalPadding (2)
#define kVerticalPadding (2)

@interface RateAnimation : NSObject {
    NSTimeInterval startTime;
    NSArray *startRates;
    NSArray *endRates;
    CADisplayLink *displayLink;
}

- (instancetype)initWithStartRates:(NSArray *)startRates endRates:(NSArray *)endRates;

@property(readonly) NSArray *currentRates;

- (void)invalidate;

@end

@protocol RateAnimationDelegate <NSObject>
- (void)drawCurrent:(RateAnimation *)anim;
@end

@interface RateAnimation ()
@property(weak) NSObject <RateAnimationDelegate> *delegate;
@end

@interface TrendingGraphicView () <RateAnimationDelegate> {
    MarketType _marketType;
}
@property(nonatomic, strong) CAShapeLayer *shapeLayer;
@property(nonatomic, strong) RateAnimation *animation;
@end

@implementation TrendingGraphicView

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
    self.shapeLayer = [CAShapeLayer layer];
    [self.layer addSublayer:self.shapeLayer];
    self.shapeLayer.lineWidth = 2;
    self.shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.shapeLayer.fillColor = nil;
    self.shapeLayer.lineCap = @"round";
    self.shapeLayer.lineJoin = @"round";
}

- (void)setMarketType:(MarketType)marketType {
    if (_marketType != marketType) {
        [self setData:nil];
    }
    _marketType = marketType;
    [self getTrendingGraphicData];
}

- (void)getTrendingGraphicData {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getTrendingGraphicData) object:nil];
    [TrendingGraphicData getTrendingGraphicData:self.marketType callback:^(id response) {
        if ([response isKindOfClass:[TrendingGraphicData class]]) {
            TrendingGraphicData *data = response;
            if (data.marketType == self.marketType) {
                [self setData:data];
            }
        }
    }                          andErrorCallback:^(NSError *error) {
        [self performSelector:@selector(getTrendingGraphicData) withObject:nil afterDelay:30];
    }];
}

- (void)setData:(TrendingGraphicData *)data {
    if (!self.animation && !data) {
        data = [TrendingGraphicData getEmptyData];
        [self drawCurrent:[[RateAnimation alloc] initWithStartRates:data.rates endRates:data.rates]];
        return;
    }
    if (!data) {
        data = [TrendingGraphicData getEmptyData];
    }
    if (self.animation) {
        RateAnimation *oldOne = self.animation;
        self.animation = [[RateAnimation alloc] initWithStartRates:self.animation.currentRates endRates:data.rates];
        [oldOne invalidate];
    } else {
        self.animation = [[RateAnimation alloc] initWithStartRates:[TrendingGraphicData getEmptyData].rates endRates:data.rates];
    }
    self.animation.delegate = self;
}

- (void)drawCurrent:(RateAnimation *)anim {
    NSArray *rates = anim.currentRates;
    NSUInteger length = rates.count;
    NSUInteger step = [self getPointStepBy:length];
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint prePoint = [self pointOfIndex:0 andStep:step inRates:rates];
    [path moveToPoint:prePoint];
    for (NSUInteger i = 0 + step; i < length; i += step) {
        CGPoint point = [self pointOfIndex:i andStep:step inRates:rates];
        CGPoint midPoint = CGPointMake((point.x + prePoint.x) / 2.0f, (point.y + prePoint.y) / 2.0f);
        if (i == step) {
            [path addLineToPoint:midPoint];
        } else {
            [path addQuadCurveToPoint:midPoint controlPoint:prePoint];
        }
        prePoint = point;
    }
    [path addLineToPoint:prePoint];
    self.shapeLayer.path = path.CGPath;
}


- (NSUInteger)getPointStepBy:(NSUInteger)count {
    int step = 1;
    if (count > (self.frame.size.width - kHorizontalPadding * 2)) {
        step = (int) (count / (self.frame.size.width - kHorizontalPadding * 2));
    }
    return step;
}

- (CGPoint)pointOfIndex:(NSUInteger)index andStep:(NSUInteger)step inRates:(NSArray *)rates {
    return CGPointMake([self getPointXByIndex:index step:step andDataLength:rates.count], [self getPointYByRate:((NSNumber *) rates[index]).doubleValue]);
}

- (CGFloat)getPointYByRate:(double)rate {
    return (CGFloat) ((self.frame.size.height - kVerticalPadding * 2) * (1.0 - rate) + kVerticalPadding);
}

- (CGFloat)getPointXByIndex:(NSUInteger)index step:(NSUInteger)step andDataLength:(NSUInteger)dataLength {
    NSUInteger pointCount = dataLength / step;
    NSUInteger pointIndex = index / step;
    float pointRate = (float) pointIndex / (float) (pointCount - 1);
    return (self.frame.size.width - kHorizontalPadding * 2) * pointRate + kHorizontalPadding;
}

- (MarketType)marketType {
    return _marketType;
}

@end

@implementation RateAnimation

- (instancetype)initWithStartRates:(NSArray *)startRs endRates:(NSArray *)endRs {
    self = [super init];
    if (self) {
        startTime = 0;
        startRates = startRs;
        if (startRates == nil || startRates.count == 0) {
            startRates = [TrendingGraphicData getEmptyData].rates;
        }
        endRates = endRs;
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplay:)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (NSArray *)currentRates {
    if ([startRates isEqualToArray:endRates]) {
        if (displayLink) {
            [displayLink invalidate];
            displayLink = nil;
        }
        return endRates;
    }
    double progress = [self getProgress];
    NSMutableArray *rates = [[NSMutableArray alloc] init];
    for (int i = 0; i < startRates.count; i++) {
        double start = ((NSNumber *) startRates[i]).doubleValue;
        double end = ((NSNumber *) endRates[i]).doubleValue;
        [rates addObject:@(progress * (end - start) + start)];
    }
    return rates;
}

- (void)handleDisplay:(CADisplayLink *)display {
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawCurrent:)]) {
        [self.delegate drawCurrent:self];
    }
    double progress = [self getProgress];
    if (progress >= 1 && displayLink) {
        [self invalidate];
    }
}

- (double)getProgress {
    if (displayLink) {
        NSTimeInterval currentTime = displayLink.timestamp + displayLink.duration * displayLink.frameInterval;
        if (startTime <= 0) {
            startTime = currentTime;
            return 0;
        }
        return MIN(MAX(0, (currentTime - startTime) / kTransformDuration), 1);
    } else {
        return 1;
    }
}

- (void)invalidate {
    if (displayLink) {
        [displayLink invalidate];
        displayLink = nil;
    }
}

@end