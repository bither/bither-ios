//
//  WatchTrendingGraphicData.h
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

#import <Foundation/Foundation.h>
#import "GroupFileUtil.h"
#import "GroupUserDefaultUtil.h"

#define TRENDING_GRAPIC_COUNT  25
#define EXPORED_TIME  1 * 60 * 60

@interface WatchTrendingGraphicData : NSObject

@property (readwrite,nonatomic) double high;
@property (readwrite,nonatomic) double low;
@property (strong,nonatomic) NSArray * prices;
@property (strong,nonatomic) NSMutableArray * rates;
@property MarketType marketType;
@property (readonly) BOOL isEmpty;

+(void)getTrendingGraphicData:(MarketType) marketType callback:(void (^)(WatchTrendingGraphicData *data))callback andErrorCallback:(void (^)(NSError *error))errorCallback;

+(instancetype)getEmptyData;
+(void)clearCache;
@end
