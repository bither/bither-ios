//
//  HDMTriangleBgView.m
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
//
//  Created by songchenwen on 15/2/3.
//

#import "HDMTriangleBgView.h"

#define kAnimDuration (0.8)

@interface Line : NSObject {
    NSTimeInterval beginAnimTime;
    BOOL animating;
    CADisplayLink *displayLink;
}
@property CGPoint startPoint;
@property CGPoint endPoint;
@property CGFloat filledRate;
@property(strong) void(^animCompletion)();
@property(readonly) CGPoint drawEndPoint;
@property(strong) CAShapeLayer *shapeLayer;

- (instancetype)initWithStartPoint:(CGPoint)startPoint andEndPoint:(CGPoint)endPoint;

- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint andFilledRate:(CGFloat)filledRate;

- (void)beginAnim:(void (^)())completion;

@end

@implementation Line

- (instancetype)initWithStartPoint:(CGPoint)startPoint andEndPoint:(CGPoint)endPoint {
    self = [super init];
    if (self) {
        self.startPoint = startPoint;
        self.endPoint = endPoint;
        self.filledRate = 1;
        [self firstConfigure];
    }
    return self;
}

- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint andFilledRate:(CGFloat)filledRate {
    self = [super init];
    if (self) {
        self.startPoint = startPoint;
        self.endPoint = endPoint;
        self.filledRate = filledRate;
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.lineWidth = 2;
    self.shapeLayer.strokeColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
    self.shapeLayer.fillColor = nil;
    self.shapeLayer.lineCap = @"round";
    self.shapeLayer.lineJoin = @"round";
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
    displayLink.paused = YES;
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    if (self.rate == 1) {
        [self draw];
    }
}

- (void)beginAnim:(void (^)())completion {
    beginAnimTime = [[NSDate new] timeIntervalSince1970];
    animating = YES;
    self.animCompletion = completion;
    displayLink.paused = NO;
}

- (void)animCompleted {
    displayLink.paused = YES;
    animating = NO;
    beginAnimTime = -1;
    self.filledRate = 1;
    if (self.animCompletion) {
        dispatch_async(dispatch_get_main_queue(), self.animCompletion);
    }
}

- (void)handleDisplayLink:(CADisplayLink *)link {
    [self draw];
}

- (void)draw {
    if (animating) {
        self.filledRate = ([NSDate new].timeIntervalSince1970 - beginAnimTime) / kAnimDuration;
        if (self.filledRate >= 1) {
            [self animCompleted];
        }
    }
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:self.startPoint];
    [path addLineToPoint:self.drawEndPoint];
    self.shapeLayer.path = path.CGPath;
}

- (CGPoint)drawEndPoint {
    CGFloat rate = self.rate;
    return CGPointMake((self.endPoint.x - self.startPoint.x) * rate + self.startPoint.x, (self.endPoint.y - self.startPoint.y) * rate + self.startPoint.y);
}

- (CGFloat)rate {
    return MIN(MAX(0, self.filledRate), 1);
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[Line class]]) {
        Line *o = object;
        return CGPointEqualToPoint(self.startPoint, o.startPoint) && CGPointEqualToPoint(self.endPoint, o.endPoint);
    }
    return NO;
}

@end

@implementation HDMTriangleBgView {
    NSMutableArray *lines;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    lines = [NSMutableArray new];
}

- (void)addLineFromView:(UIView *)fromView toView:(UIView *)toView {
    [self addLineFromPoint:[self centerPointFor:fromView] toPoint:[self centerPointFor:toView]];
}

- (void)addLineAnimatedFromView:(UIView *)fromView toView:(UIView *)toView completion:(void (^)())completion {
    [self addLineAnimatedFromPoint:[self centerPointFor:fromView] toPoint:[self centerPointFor:toView] completion:completion];
}

- (CGPoint)centerPointFor:(UIView *)v {
    CGPoint center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2);
    return [self convertPoint:center fromView:v];
}

- (void)addLineFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
    Line *line = [[Line alloc] initWithStartPoint:fromPoint andEndPoint:toPoint];
    if (![lines containsObject:line]) {
        [lines addObject:line];
        [self.layer addSublayer:line.shapeLayer];
    }
}

- (void)addLineAnimatedFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint completion:(void (^)())completion {
    Line *line = [[Line alloc] initWithStartPoint:fromPoint endPoint:toPoint andFilledRate:0];
    if (![lines containsObject:line]) {
        [lines addObject:line];
        [self.layer addSublayer:line.shapeLayer];
        [line beginAnim:completion];
    }
}

- (void)removeAllLines {
    for (Line *l in lines) {
        [l.shapeLayer removeFromSuperlayer];
    }
    [lines removeAllObjects];
}
@end