//
//  TotalBalanceDrawer.m
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
//  Created by songchenwen on 2015/2/27.
//

#import "TotalBalanceDrawer.h"
#import "TotalBalance.h"
#import "WatchUnitUtil.h"

#define kTotalBalanceCacheImage (@"TotalBalance")

#define kStrokeWidth (20.0f)
#define kImageSize (340)
#define kCircleGapRate (0.03f)
#define kCircleMinRate (0.12f)
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kHDColor (RGBA(194, 253, 70, 1))
#define kHdMonitoredColor (RGBA(100, 114, 253, 1))
#define kHDMColor (RGBA(38, 230, 91, 1))
#define kHotColor (RGBA(254, 39, 93, 1))
#define kColdColor (RGBA(36, 182, 212, 1))

@implementation TotalBalanceDrawer

+ (void)showTotalBalanceOn:(WKInterfaceGroup *)group label:(WKInterfaceLabel *)label andImage:(WKInterfaceImage *)iv {
    WKInterfaceDevice *device = [WKInterfaceDevice currentDevice];
    if ([device.cachedImages.allKeys containsObject:kTotalBalanceCacheImage]) {
        [group setBackgroundImageNamed:kTotalBalanceCacheImage];
        TotalBalance *t = [[TotalBalance alloc] init];
        [label setText:[WatchUnitUtil stringForAmount:t.total]];
        [iv setImageNamed:[WatchUnitUtil imageNameOfSymbol]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [TotalBalanceDrawer refreshTotalBalanceOn:group label:label andImage:iv];
        });
        return;
    }
    [TotalBalanceDrawer refreshTotalBalanceOn:group label:label andImage:iv];
}

+ (void)refreshTotalBalanceOn:(WKInterfaceGroup *)group label:(WKInterfaceLabel *)label andImage:(WKInterfaceImage *)iv {
    TotalBalance *t = [[TotalBalance alloc] init];
    UIImage *image = [TotalBalanceDrawer imageForTotalBalance:t];
    WKInterfaceDevice *device = [WKInterfaceDevice currentDevice];
    [device addCachedImage:image name:kTotalBalanceCacheImage];
    dispatch_async(dispatch_get_main_queue(), ^{
        [label setText:[WatchUnitUtil stringForAmount:t.total]];
        [iv setImageNamed:[WatchUnitUtil imageNameOfSymbol]];
        [group setBackgroundImageNamed:kTotalBalanceCacheImage];
    });
}

+ (UIImage *)imageForTotalBalance:(TotalBalance *)t {
    NSUInteger parts = 0;
    if (t.hd > 0) {
        parts++;
    }
    if (t.hdMonitored > 0) {
        parts++;
    }
    if (t.hdm > 0) {
        parts++;
    }
    if (t.hot > 0) {
        parts++;
    }
    if (t.cold > 0) {
        parts++;
    }

    CGSize size = CGSizeMake(kImageSize, kImageSize);
    CGRect circleRect = CGRectMake(kStrokeWidth / 2, kStrokeWidth / 2, size.width - kStrokeWidth, size.height - kStrokeWidth);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0 alpha:0].CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, kStrokeWidth);


    // bg
    UIColor *bgColor = [UIColor colorWithWhite:1 alpha:0.1];
    if (parts == 1) {
        if (t.hd > 0) {
            bgColor = kHDColor;
        } else if (t.hdMonitored > 0) {
            bgColor = kHdMonitoredColor;
        } else if (t.hdm > 0) {
            bgColor = kHDMColor;
        } else if (t.hot > 0) {
            bgColor = kHotColor;
        } else if (t.cold > 0) {
            bgColor = kColdColor;
        }
    }
    CGContextSetStrokeColorWithColor(context, [bgColor CGColor]);
    CGContextAddEllipseInRect(context, circleRect);
    CGContextStrokePath(context);


    if (parts > 1) {
        double total = (double) t.total;
        double hdAmount = (double) t.hd;
        double hdMonitoredAmount = (double) t.hdMonitored;
        double hdmAmount = (double) t.hdm;
        double hotAmount = (double) t.hot;
        double coldAmount = (double) t.cold;

        double hd = 0;
        double hdMonitored = 0;
        double hdm = 0;
        double hot = 0;
        double cold = 0;

        if (hdAmount > 0 && hdAmount < total * kCircleMinRate) {
            double delta = total * kCircleMinRate - hdAmount;
            total += delta;
            hdAmount += delta;
        }

        if (hdMonitoredAmount > 0 && hdMonitoredAmount < total * kCircleMinRate) {
            double delta = total * kCircleMinRate - hdMonitoredAmount;
            total += delta;
            hdMonitoredAmount += delta;
        }

        if (hdmAmount > 0 && hdmAmount < total * kCircleMinRate) {
            double delta = total * kCircleMinRate - hdmAmount;
            total += delta;
            hdmAmount += delta;
        }

        if (hotAmount > 0 && hotAmount < total * kCircleMinRate) {
            double delta = total * kCircleMinRate - hotAmount;
            total += delta;
            hotAmount += delta;
        }
        if (coldAmount > 0 && coldAmount < total * kCircleMinRate) {
            double delta = total * kCircleMinRate - coldAmount;
            total += delta;
            coldAmount += delta;
        }

        if (hdAmount > 0) {
            hd = hdAmount / total;
        }
        if (hdMonitoredAmount > 0){
            hdMonitored = hdMonitoredAmount / total;
        }
        if (hdmAmount > 0) {
            hdm = hdmAmount / total;
        }
        if (hotAmount > 0) {
            hot = hotAmount / total;
        }
        if (coldAmount > 0) {
            cold = coldAmount / total;
        }

        CGFloat start = CGFLOAT_MIN;
        if (hd > 0) {
            CGContextSetStrokeColorWithColor(context, [kHDColor CGColor]);
            start = [TotalBalanceDrawer drawArc:context rate:hd andStart:start];
        }
        if (hdMonitored > 0){
            CGContextSetStrokeColorWithColor(context, [kHdMonitoredColor CGColor]);
            start = [TotalBalanceDrawer drawArc:context rate:hdMonitored andStart:start];
        }
        if (hdm > 0) {
            CGContextSetStrokeColorWithColor(context, [kHDMColor CGColor]);
            start = [TotalBalanceDrawer drawArc:context rate:hdm andStart:start];
        }
        if (hot > 0) {
            CGContextSetStrokeColorWithColor(context, [kHotColor CGColor]);
            start = [TotalBalanceDrawer drawArc:context rate:hot andStart:start];
        }
        if (cold > 0) {
            CGContextSetStrokeColorWithColor(context, [kColdColor CGColor]);
            start = [TotalBalanceDrawer drawArc:context rate:cold andStart:start];
        }
    }

    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

+ (CGFloat)drawArc:(CGContextRef)context rate:(double)rate andStart:(CGFloat)start {
    CGFloat total = M_PI * 2.0;
    CGFloat delta = total * rate;
    if (start == CGFLOAT_MIN) {
        start = 0.0 - total / 4.0 - delta / 2.0;
    }
    CGFloat end = start + delta;
    CGContextAddArc(context, kImageSize / 2, kImageSize / 2, kImageSize / 2 - kStrokeWidth / 2, start + kCircleGapRate * total / 2.0, end - kCircleGapRate * total / 2.0, 0);
    CGContextStrokePath(context);
    return end;
}

@end
