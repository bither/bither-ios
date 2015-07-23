///
//  PieChartView.m
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


#import "PieChartView.h"
#import "BitherSetting.h"

#define kDefaultStartAngle (-M_PI_2)
#define kTransformDuration (0.4f)
#define kMaxTotalAngle (M_PI * 2)
#define kMinRate (0.03f)
#define kLogoSizeRate (0.3f)
#define kSpeedCollectionDuration (0.06)
#define kInertiaResistance (0.1f)
#define kInertiaResistanceInterval (0.02f)

@interface PieChartView () {
    CGFloat _startAngle;
    NSArray *_amounts;
    CGFloat _totalAngle;
    UIImage *_centerImage;
    NSTimeInterval beginTime;
    CGFloat _rotation;
}

@property int64_t total;
@property CADisplayLink *displayLink;
@property CADisplayLink *inertiaDisplayLink;
@property CGFloat rotation;
@property NSMutableArray *rotations;
@property CGFloat inertiaSpeed;
@end

@interface TimeAndRotation : NSObject
@property NSTimeInterval time;
@property CGFloat rotation;

- (instancetype)initWithPieChartView:(PieChartView *)view;
@end

static NSArray *Colors;

@implementation PieChartView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    if (!Colors) {
        Colors = @[RGBA(194, 253, 70, 1), RGBA(100, 114, 253, 1), RGBA(38, 230, 91, 1),
                RGBA(254, 39, 93, 1), RGBA(36, 182, 212, 1), RGBA(237, 193, 155, 1),
                RGBA(117, 140, 129, 1), RGBA(200, 47, 217, 1), RGBA(239, 204, 41, 1),
                RGBA(253, 38, 38, 1), RGBA(253, 160, 38, 1), RGBA(144, 183, 177, 1)];
    }
    self.startAngle = kDefaultStartAngle;
    self.totalAngle = kMaxTotalAngle;
    self.rotation = 0;
    _centerImage = [UIImage imageNamed:@"dialog_total_btc_pie_chart_logo"];
    self.backgroundColor = [UIColor clearColor];
    self.rotations = [[NSMutableArray alloc] init];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    if (self.total <= 0 && self.amounts) {
        CGFloat angle = self.startAngle;
        float sweepAngle = self.totalAngle;
        sweepAngle = MAX(kMaxTotalAngle / 1000.0, sweepAngle);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, CGRectGetMidX(rect), CGRectGetMidY(rect));
        CGContextAddArc(context, CGRectGetMidX(rect), CGRectGetMidY(rect), MIN(rect.size.width, rect.size.height) / 2, angle, angle + sweepAngle, 0);
        [Colors[Colors.count - 1] setFill];
        CGContextClosePath(context);
        CGContextDrawPath(context, kCGPathFill);
        angle += sweepAngle;
    } else {
        if (self.amounts) {
            NSMutableArray *rates = [[NSMutableArray alloc] initWithCapacity:self.amounts.count];
            NSMutableIndexSet *minIndexes = [[NSMutableIndexSet alloc] init];
            for (int i = 0; i < self.amounts.count; i++) {
                NSNumber *amountNumber = self.amounts[i];
                double rate = (double) [amountNumber longLongValue] / (double) self.total;
                rates[i] = [NSNumber numberWithDouble:rate];
                if (rate < kMinRate && rate > 0) {
                    [minIndexes addIndex:i];
                    rates[i] = [NSNumber numberWithDouble:kMinRate];
                }
            }
            if (minIndexes.count > 0) {
                int64_t rest = 0;
                for (NSInteger i = 0; i < self.amounts.count; i++) {
                    if (![minIndexes containsIndex:i]) {
                        rest += [((NSNumber *) self.amounts[i]) longLongValue];
                    }
                }
                double restRate = 1.0f - minIndexes.count * kMinRate;
                for (NSInteger i = 0; i < self.amounts.count; i++) {
                    if (![minIndexes containsIndex:i]) {
                        double rate = (double) [self.amounts[i] longLongValue] / (double) rest * restRate;
                        rates[i] = [NSNumber numberWithDouble:rate];
                    }
                }
            }
            CGFloat angle = self.startAngle;
            for (NSUInteger i = 0; i < rates.count; i++) {
                if (i >= Colors.count) {
                    break;
                }
                float sweepAngle = [rates[i] doubleValue] * self.totalAngle;
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, CGRectGetMidX(rect), CGRectGetMidY(rect));
                CGContextAddArc(context, CGRectGetMidX(rect), CGRectGetMidY(rect), MIN(rect.size.width, rect.size.height) / 2, angle, angle + sweepAngle, 0);
                [Colors[i] setFill];
                CGContextClosePath(context);
                CGContextDrawPath(context, kCGPathFill);
                angle += sweepAngle;
            }
        }
    }
    CGFloat centerImageSize = MIN(rect.size.width, rect.size.height) * kLogoSizeRate;
    [_centerImage drawInRect:CGRectMake((rect.size.width - centerImageSize) / 2, (rect.size.height - centerImageSize) / 2, centerImageSize, centerImageSize)];
}

- (void)setAmounts:(NSArray *)amounts {
    _amounts = amounts;
    self.total = 0;
    if (_amounts && _amounts.count > 0) {
        for (NSNumber *number in _amounts) {
            self.total += [number longLongValue];
        }
    }
    if (!self.displayLink) {
        self.totalAngle = 0;
        beginTime = -1;
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplay:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)handleDisplay:(CADisplayLink *)displayLink {
    NSTimeInterval currentTime = displayLink.timestamp + displayLink.duration * displayLink.frameInterval;
    if (beginTime <= 0) {
        beginTime = currentTime;
    }
    if (currentTime >= beginTime + kTransformDuration) {
        self.totalAngle = kMaxTotalAngle;
        [self setNeedsDisplay];
        if (self.displayLink) {
            [self.displayLink invalidate];
            self.displayLink = nil;
        }
        beginTime = -1;
    } else {
        double rate = (currentTime - beginTime) / kTransformDuration;
        self.totalAngle = kMaxTotalAngle * rate;
        [self setNeedsDisplay];
    }
}

- (NSArray *)amounts {
    return _amounts;
}

- (void)setStartAngle:(CGFloat)startAngle {
    _startAngle = startAngle;
}

- (CGFloat)startAngle {
    return _startAngle;
}

- (void)setTotalAngle:(CGFloat)totalAngle {
    _totalAngle = totalAngle;
    [self resetRotations];
}

- (CGFloat)totalAngle {
    return _totalAngle;
}


- (UIColor *)colorForIndex:(NSInteger)index {
    return Colors[index];
}

- (void)setRotation:(CGFloat)rotation {
    _rotation = rotation;
}

- (CGFloat)rotation {
    return _rotation;
}

CGFloat fingerRotation;
CGFloat newFingerRotation;
CGFloat xc;
CGFloat yc;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [((UITouch *) touches.anyObject) locationInView:self];
    if (xc == 0 || yc == 0) {
        xc = self.frame.size.width / 2;
        yc = self.frame.size.height / 2;
    }

    if (!CGRectContainsPoint(self.frame, point)) {
        return;
    }
    fingerRotation = [self getRotationFrom:point];
    [self resetRotations];
    [self collectRotation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [((UITouch *) touches.anyObject) locationInView:self];
    if (!CGRectContainsPoint(self.bounds, point)) {
        return;
    }
    newFingerRotation = [self getRotationFrom:point];
    double rotationDelta = newFingerRotation - fingerRotation;
    if (rotationDelta > M_PI_2) {
        [self rotationRoundPi];
        return;
    }
    self.transform = CGAffineTransformRotate(self.transform, rotationDelta);
    self.rotation += rotationDelta;
    fingerRotation = newFingerRotation;
    [self collectRotation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    fingerRotation = newFingerRotation = 0.0f;
    [self performInertia];
    [self rotationRoundPi];

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    fingerRotation = newFingerRotation = 0.0f;
    [self performInertia];
    [self rotationRoundPi];
}

- (void)rotationRoundPi {
    if (self.rotation < 0) {
        self.rotation = self.rotation + ceil(self.rotation / (-M_PI * 2)) * M_PI * 2;
    } else if (self.rotation >= M_PI * 2) {
        self.rotation = self.rotation - floor(self.rotation / (M_PI * 2)) * M_PI * 2;
    }
}

- (CGFloat)getRotationFrom:(CGPoint)point {
    CGFloat rotation = atan2(point.x - xc, yc - point.y);
    if (rotation <= 0) {
        rotation += M_PI * 2;
    }
    return rotation;
}

- (void)resetRotations {
    [self.rotations removeAllObjects];
    if (self.inertiaDisplayLink) {
        [self.inertiaDisplayLink invalidate];
        self.inertiaDisplayLink = nil;
    }
    self.inertiaSpeed = 0;
}

- (void)performInertia {
    if (!self.rotations || self.rotations.count < 2 || self.displayLink) {
        return;
    }
    self.inertiaSpeed = (((TimeAndRotation *) self.rotations[self.rotations.count - 1]).rotation - ((TimeAndRotation *) self.rotations[self.rotations.count - 2]).rotation) / (((TimeAndRotation *) self.rotations[self.rotations.count - 1]).time - ((TimeAndRotation *) self.rotations[self.rotations.count - 2]).time);
    self.inertiaDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleInertiaDisplay:)];
    [self.inertiaDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)handleInertiaDisplay:(CADisplayLink *)displayLink {
    NSTimeInterval timePassed = displayLink.duration * displayLink.frameInterval;
    double inertialResistance = timePassed / kInertiaResistanceInterval * kInertiaResistance;
    if (ABS(self.inertiaSpeed) < inertialResistance) {
        [self resetRotations];
        return;
    }
    CGFloat deltaRotation = self.inertiaSpeed * timePassed;
    self.rotation += deltaRotation;
    self.transform = CGAffineTransformRotate(self.transform, deltaRotation);
    if (self.inertiaSpeed > 0) {
        self.inertiaSpeed -= inertialResistance;
    } else {
        self.inertiaSpeed += inertialResistance;
    }
}

- (void)collectRotation {
    TimeAndRotation *r = [[TimeAndRotation alloc] initWithPieChartView:self];
    TimeAndRotation *last = nil;
    if (self.rotations.count > 0) {
        last = self.rotations.lastObject;
    }
    if (!last || r.time - last.time > kSpeedCollectionDuration) {
        [self.rotations addObject:r];
    }
    if (self.rotations.count > 2) {
        [self.rotations removeObjectsInRange:NSMakeRange(0, self.rotations.count - 2)];
    }
}
@end

@implementation TimeAndRotation

- (instancetype)initWithPieChartView:(PieChartView *)view {
    self = [super init];
    if (self) {
        self.rotation = view.rotation;
        self.time = [[NSDate new] timeIntervalSince1970];
    }
    return self;
}

@end
