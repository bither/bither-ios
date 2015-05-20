//
//  AudioVisualizerView.m
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

#import "AudioVisualizerView.h"

#define kHorizontalStraightLineLength (20)
#define kMinAmptitude (0.1f)
#define kWaveCount (1)
#define kWaveDuration (0.5)
#define kSubLineCount (5)


@interface AudioVisualizerView () {
    float amptitude;
    CADisplayLink *displayLink;
    CAShapeLayer *mainLine;
    NSMutableArray *subLines;
    NSTimeInterval beginTime;
    UIBezierPath *mainPath;
    NSMutableArray *subPaths;
}
@end

@implementation AudioVisualizerView

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
    self.backgroundColor = [UIColor clearColor];
    amptitude = kMinAmptitude;
    mainLine = [CAShapeLayer layer];
    mainLine.lineWidth = 2;
    mainLine.strokeColor = [UIColor whiteColor].CGColor;
    mainLine.fillColor = nil;
    mainLine.lineCap = @"round";
    mainLine.lineJoin = @"round";
    subLines = [[NSMutableArray alloc] init];
    [self.layer addSublayer:mainLine];
    mainPath = [UIBezierPath bezierPath];
    subPaths = [[NSMutableArray alloc] init];
    for (int i = 0; i < kSubLineCount; i++) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.lineWidth = 0.5f;
        layer.strokeColor = [UIColor colorWithWhite:1 alpha:0.4].CGColor;
        layer.fillColor = nil;
        layer.lineCap = @"round";
        layer.lineJoin = @"round";
        [subLines addObject:layer];
        [self.layer insertSublayer:layer atIndex:0];
        [subPaths addObject:[UIBezierPath bezierPath]];
    }
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplay:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)handleDisplay:(CADisplayLink *)display {
    NSTimeInterval currentTime = display.timestamp + display.duration * display.frameInterval;
    if (beginTime <= 0 || currentTime - beginTime > kWaveDuration) {
        beginTime = currentTime;
    }
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;

    CGFloat xOffset = (width - kHorizontalStraightLineLength * 2) / kWaveCount / kWaveDuration * (currentTime - beginTime);

    [mainPath removeAllPoints];
    [mainPath moveToPoint:CGPointMake(0, height / 2)];
    CGFloat controlY = [self yForX:kHorizontalStraightLineLength * 3 offset:xOffset];
    CGFloat connectionY = [self yForX:kHorizontalStraightLineLength * 4 offset:xOffset];
    [mainPath addQuadCurveToPoint:CGPointMake(kHorizontalStraightLineLength * 2, (height / 2 + controlY) / 2) controlPoint:CGPointMake(kHorizontalStraightLineLength, height / 2)];
    [mainPath addQuadCurveToPoint:CGPointMake(kHorizontalStraightLineLength * 4, connectionY) controlPoint:CGPointMake(kHorizontalStraightLineLength * 3, controlY)];

    for (int i = 0; i < subPaths.count; i++) {
        CGFloat rate = [self rateForSublineIndex:i];
        UIBezierPath *path = subPaths[i];
        [path removeAllPoints];
        [path moveToPoint:CGPointMake(0, height / 2)];
        CGFloat subControlY = (controlY - height / 2) * rate + height / 2;
        CGFloat subConnectionY = (connectionY - height / 2) * rate + height / 2;

        [path addQuadCurveToPoint:CGPointMake(kHorizontalStraightLineLength * 2, (height / 2 + subControlY) / 2) controlPoint:CGPointMake(kHorizontalStraightLineLength, height / 2)];
        [path addQuadCurveToPoint:CGPointMake(kHorizontalStraightLineLength * 4, subConnectionY) controlPoint:CGPointMake(kHorizontalStraightLineLength * 3, subControlY)];
    }

    //TODO optimize this loop for 4s or lower devices
    for (float x = kHorizontalStraightLineLength * 4;
         x < width - kHorizontalStraightLineLength * 4;
         x += 0.5f) {
        CGFloat y = [self yForX:x offset:xOffset];
        [mainPath addLineToPoint:CGPointMake(x, y)];
        for (int i = 0; i < subPaths.count; i++) {
            CGFloat rate = [self rateForSublineIndex:i];
            UIBezierPath *path = subPaths[i];
            [path addLineToPoint:CGPointMake(x, (y - height / 2) * rate + height / 2)];
        }
    }

    controlY = [self yForX:width - kHorizontalStraightLineLength * 3 offset:xOffset];
    [mainPath addQuadCurveToPoint:CGPointMake(width - kHorizontalStraightLineLength * 2, (height / 2 + controlY) / 2) controlPoint:CGPointMake(width - kHorizontalStraightLineLength * 3, controlY)];
    [mainPath addQuadCurveToPoint:CGPointMake(width, height / 2) controlPoint:CGPointMake(width - kHorizontalStraightLineLength, height / 2)];
    mainLine.path = mainPath.CGPath;

    for (int i = 0; i < subPaths.count; i++) {
        CGFloat rate = [self rateForSublineIndex:i];
        UIBezierPath *path = subPaths[i];
        CGFloat subControlY = (controlY - height / 2) * rate + height / 2;
        [path addQuadCurveToPoint:CGPointMake(width - kHorizontalStraightLineLength * 2, (height / 2 + subControlY) / 2) controlPoint:CGPointMake(width - kHorizontalStraightLineLength * 3, subControlY)];
        [path addQuadCurveToPoint:CGPointMake(width, height / 2) controlPoint:CGPointMake(width - kHorizontalStraightLineLength, height / 2)];
        ((CAShapeLayer *) subLines[i]).path = path.CGPath;
    }
}

- (CGFloat)yForX:(CGFloat)x offset:(CGFloat)xOffset {
    return (amptitude * (self.frame.size.height - 2 * mainLine.lineWidth) / 2.0f * sin(2 * M_PI * ((x - xOffset) / (self.frame.size.width - kHorizontalStraightLineLength * 2)) * kWaveCount) + self.frame.size.height / 2);
}

- (CGFloat)rateForSublineIndex:(NSUInteger)index {
    return (index + 1.0f) / (CGFloat) (subLines.count + 1);
}

- (void)showConnectionData:(AVCaptureConnection *)connection {
    if (connection.audioChannels.count > 0) {
        AVCaptureAudioChannel *channel = connection.audioChannels[0];
        double PeakPowerForChannel = pow(10, (0.05 * channel.peakHoldLevel));
        double averagePowerForChannel = pow(10, (0.05 * channel.averagePowerLevel));
        amptitude = 0.8 * PeakPowerForChannel + (1.0 - 0.8) * averagePowerForChannel;
    } else {
        amptitude = kMinAmptitude;
    }
    amptitude = MIN(MAX(amptitude, kMinAmptitude), 1);
}

- (void)dealloc {
    if (displayLink) {
        [displayLink invalidate];
        displayLink = nil;
    }
}

@end
