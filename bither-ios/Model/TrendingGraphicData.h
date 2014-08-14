//
//  TrendingGraphicData.h
//  bither-ios
//
//  Created by noname on 14-8-13.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BitherSetting.h"

#define TRENDING_GRAPIC_COUNT  25
#define EXPORED_TIME  1 * 60 * 60 

@interface TrendingGraphicData : NSObject

@property (readwrite,nonatomic) double high;
@property (readwrite,nonatomic) double low;
@property (strong,nonatomic) NSArray * prices;
@property (strong,nonatomic) NSMutableArray * rates;


+(void)getTrendingGraphicData:(MarketType ) marketType callback:(IdResponseBlock)callback andErrorCallback:(ErrorBlock)errorCallback;

@end
