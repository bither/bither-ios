//
//  WatchTrendingGraphicDrawer.m
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

#import "WatchTrendingGraphicDrawer.h"

#define kHorizontalPadding (2)
#define kVerticalPadding (2)
#define kTrendingGraphicEmptyImageCache (@"TrendingGraphicEmptyImage")

@interface WatchTrendingGraphicDrawer(){
    CGSize size;
}
@end

@implementation WatchTrendingGraphicDrawer

-(instancetype)init{
    self = [super init];
    if(self){
        size = CGSizeMake(200, 100);
    }
    return self;
}

-(void)setEmptyImage:(WKInterfaceImage*)iv{
    WKInterfaceDevice *device = [WKInterfaceDevice currentDevice];
    if([device.cachedImages.allKeys containsObject:kTrendingGraphicEmptyImageCache]){
        [iv setImageNamed:kTrendingGraphicEmptyImageCache];
        return;
    }
    UIImage* image = [self imageForData:[WatchTrendingGraphicData getEmptyData]];
    [device addCachedImage:image name:kTrendingGraphicEmptyImageCache];
    [iv setImageNamed:kTrendingGraphicEmptyImageCache];
}

-(UIImage*)imageForData:(WatchTrendingGraphicData*)data{
    CGContextRef context = [self beginDrawing];
    [self drawRates:data.rates in: context];
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    [self endDrawing];
    return result;
}

-(UIImage*)animatingImageFromData:(WatchTrendingGraphicData*)from toData:(WatchTrendingGraphicData*)to{
    NSMutableArray* images = [NSMutableArray new];
    CGContextRef context = [self beginDrawing];
    
    for(NSUInteger i = 0; i < kTrendingAnimationFrameCount; i++){
        double progress = (double)(i + 1) / (double)kTrendingAnimationFrameCount;
        [self drawRates:[self rateFrom:from.rates to:to.rates progress:progress] in: context];
        [images addObject:UIGraphicsGetImageFromCurrentImageContext()];
        [self clearContext:context];
    }
    
    [self endDrawing];
    
    return [UIImage animatedImageWithImages:images duration:kTrendingAnimationDuration];
}

-(NSArray*)rateFrom:(NSArray*)from to:(NSArray*)to progress:(double)progress{
    NSUInteger count = MIN(from.count, to.count);
    NSMutableArray* r = [NSMutableArray new];
    for(NSUInteger i = 0; i < count; i++){
        double start = ((NSNumber*)from[i]).doubleValue;
        double end = ((NSNumber*)to[i]).doubleValue;
        [r addObject:@(progress * (end - start) + start)];
    }
    return r;
}

-(void)drawRates:(NSArray*)rates in:(CGContextRef) context{
    NSUInteger length = rates.count;
    NSUInteger step = [self getPointStepBy:length];
    CGPoint prePoint = [self pointOfIndex:0 andStep:step inRates:rates];
    CGContextMoveToPoint(context, prePoint.x, prePoint.y);
    for(NSUInteger i = 0 + step; i < length; i += step){
        CGPoint point = [self pointOfIndex:i andStep:step inRates:rates];
        CGPoint midPoint = CGPointMake((point.x + prePoint.x)/2.0f, (point.y + prePoint.y)/2.0f);
        if(i == step){
            CGContextAddLineToPoint(context, midPoint.x, midPoint.y);
        }else{
            CGContextAddQuadCurveToPoint(context, prePoint.x, prePoint.y, midPoint.x, midPoint.y);
        }
        prePoint = point;
    }
    CGContextAddLineToPoint(context, prePoint.x, prePoint.y);
    CGContextStrokePath(context);
}

-(NSUInteger)getPointStepBy:(NSUInteger)count{
    int step = 1;
    if (count > (size.width - kHorizontalPadding * 2)) {
        step = (int) (count / (size.width - kHorizontalPadding * 2));
    }
    return step;
}

-(CGPoint)pointOfIndex:(NSUInteger)index andStep:(NSUInteger)step inRates:(NSArray*)rates{
    return CGPointMake([self getPointXByIndex:index step:step andDataLength:rates.count], [self getPointYByRate:((NSNumber*)rates[index]).doubleValue]);
}

-(CGFloat)getPointYByRate:(double)rate{
    return (CGFloat)((size.height - kVerticalPadding * 2) * (1.0 - rate) + kVerticalPadding);
}

-(CGFloat)getPointXByIndex:(NSUInteger)index step:(NSUInteger) step andDataLength:(NSUInteger)dataLength{
    NSUInteger pointCount = dataLength / step;
    NSUInteger pointIndex = index / step;
    float pointRate = (float) pointIndex / (float) (pointCount - 1);
    return (size.width - kHorizontalPadding * 2) * pointRate + kHorizontalPadding;
}

-(void)clearContext:(CGContextRef)context{
   CGContextClearRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, size.width, size.height));
}

-(CGContextRef)beginDrawing{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0 alpha:0].CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, 2.0f);
    return context;
}

-(void)endDrawing{
    UIGraphicsEndImageContext();
}
@end
