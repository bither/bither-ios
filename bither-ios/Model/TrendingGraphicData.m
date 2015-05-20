//
//  TrendingGraphicData.m
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

#import "TrendingGraphicData.h"
#import "BitherApi.h"

static TrendingGraphicData *_emptyData;
static NSMutableDictionary *tgds;

@interface TrendingGraphicData () {
    NSTimeInterval _createTime;

}

@end

@implementation TrendingGraphicData

- (instancetype)init {
    self = [super init];
    if (self) {
        _createTime = -1;
    }
    return self;
}

- (BOOL)isExpired {
    return _createTime == -1 || _createTime + EXPORED_TIME < [[NSDate new] timeIntervalSince1970];
}

- (void)setCreateTime:(NSTimeInterval)time {
    _createTime = time;

}

- (void)caculateRate {
    self.rates = [NSMutableArray new];
    double interval = self.high - self.low;
    for (int i = 0; i < self.prices.count; i++) {
        double price = [[self.prices objectAtIndex:i] doubleValue];
        if (interval == 0) {
            [self.rates addObject:@(0.5)];
        } else {
            [self.rates addObject:@(MAX(0, price - self.low) / interval)];
        }
    }

}

+ (TrendingGraphicData *)format:(NSArray *)array {
    TrendingGraphicData *tgd = [[TrendingGraphicData alloc] init];
    double high = 0;
    double low = UINT32_MAX;
//    double rate=[ExchangeUtil getExchangeRate];
    NSMutableArray *prices = [NSMutableArray new];
    for (int i = 0; i < array.count; i++) {
        double price = [[array objectAtIndex:i] doubleValue];
        [prices addObject:@(price)];
        if (high < price) {
            high = price;
        }
        if (low > price) {
            low = price;
        }

    }
    tgd.prices = prices;
    tgd.high = high;
    tgd.low = low;
    [tgd caculateRate];
    [tgd setCreateTime:[[NSDate new] timeIntervalSince1970]];
    return tgd;
}

+ (instancetype)getEmptyData {

    if (_emptyData == nil) {
        _emptyData = [[TrendingGraphicData alloc] init];
        NSMutableArray *prices = [NSMutableArray new];
        for (int i = 0; i < TRENDING_GRAPIC_COUNT; i++) {
            [prices addObject:@(0.5)];
        }
        _emptyData.high = 1;
        _emptyData.low = 0;
        _emptyData.prices = prices;
        [_emptyData caculateRate];
    }

    return _emptyData;
}

+ (void)getTrendingGraphicData:(MarketType)marketType callback:(IdResponseBlock)callback andErrorCallback:(ErrorBlock)errorCallback {
    if (tgds == nil) {
        tgds = [NSMutableDictionary new];
    }

    TrendingGraphicData *tgd = [tgds objectForKey:@(marketType)];
    if (tgd && ![tgd isExpired]) {
        tgd.marketType = marketType;
        if (callback) {
            callback(tgd);
            return;
        }
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[BitherApi instance] getExchangeTrend:marketType callback:^(NSArray *array) {
            TrendingGraphicData *tgd = [TrendingGraphicData format:array];
            [tgds setObject:tgd forKey:@(marketType)];
            dispatch_async(dispatch_get_main_queue(), ^{
                tgd.marketType = marketType;
                if (callback) {
                    callback(tgd);
                }
            });

        }                     andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (errorCallback) {
                    errorCallback(error);
                }
            });
        }];


    });

}

+ (void)clearCache {
    NSEnumerator *enumeratorValue = [tgds objectEnumerator];
    for (TrendingGraphicData *trending in enumeratorValue) {
        [trending setCreateTime:-1];

    }

}

@end
