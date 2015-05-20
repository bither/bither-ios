//
//  PinCodeDotsView.m
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

#import "PinCodeDotsView.h"

#define kPadding (1)
#define kStrokeWidth (1.5f)

@interface PinCodeDotsView () {
    UIColor *_dotColor;
    NSUInteger _filledCount;
    NSUInteger _totalDotCount;
}

@end

@implementation PinCodeDotsView

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetLineWidth(context, kStrokeWidth);
    [self.dotColor setFill];
    [self.dotColor setStroke];
    CGFloat height = rect.size.height;
    CGFloat width = rect.size.width;
    if (height == 0 || width == 0) {
        return;
    }
    CGFloat size = height - kStrokeWidth * 2.0f;
    CGFloat distance = (width - kStrokeWidth * 2.0f - size * 4.0f) / 3.0f;
    CGRect dotRect = CGRectMake(kStrokeWidth, kStrokeWidth, size, size);
    for (NSUInteger i = 0;
         i < self.totalDotCount;
         i++) {
        dotRect.origin.x = i * (size + distance) + kStrokeWidth;
        if (i < self.filledCount) {
            CGContextFillEllipseInRect(context, dotRect);
        } else {
            CGContextStrokeEllipseInRect(context, dotRect);
        }
    }
}

- (UIColor *)dotColor {
    if (!_dotColor) {
        self.dotColor = [UIColor colorWithWhite:0.8f alpha:0.92f];
    }
    return _dotColor;
}

- (void)setDotColor:(UIColor *)dotColor {
    _dotColor = dotColor;
    [self setNeedsDisplay];
}

- (NSUInteger)filledCount {
    return _filledCount;
}

- (void)setFilledCount:(NSUInteger)filledCount {
    _filledCount = filledCount;
    [self setNeedsDisplay];
}

- (NSUInteger)totalDotCount {
    if (_totalDotCount == 0) {
        self.totalDotCount = 4;
    }
    return _totalDotCount;
}

- (void)setTotalDotCount:(NSUInteger)totalDotCount {
    _totalDotCount = totalDotCount;
    [self setNeedsDisplay];
}


@end
