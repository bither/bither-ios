//
//  WatchMarketBgDrawer.m
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
//  Created by songchenwen on 2015/3/10.
//

#import "WatchMarketBgDrawer.h"
#define InterporateFloat(begin,end,progress) (begin + (end - begin) * progress)

@interface WatchMarketBgDrawer(){
    UIColor* from;
    UIColor* to;
}
@end

@implementation WatchMarketBgDrawer

-(instancetype)initWithFrom:(UIColor*)f to:(UIColor*)t{
    self = [super init];
    if(self){
        from = f;
        to = t;
    }
    return self;
}

-(NSArray*)images{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    NSMutableArray* array = [NSMutableArray new];
    CGFloat progress = 0;
    for(NSUInteger i = 0; i < kWatchMarketBgAnimationFrameCount; i++){
        progress = (CGFloat)(i + 1)/(CGFloat)kWatchMarketBgAnimationFrameCount;
        [array addObject:[self imageBy:[self interporateColorWithBegin:from end:to progress:progress]]];
    }
    UIGraphicsEndImageContext();
    return array;
}

-(UIImage*)imageBy:(UIColor*)color{
    [color setFill];
    UIRectFill(CGRectMake(0, 0, 1, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];;
}

-(UIColor*)interporateColorWithBegin:(UIColor*)beginColor end:(UIColor*)endColor progress:(CGFloat)progress{
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
