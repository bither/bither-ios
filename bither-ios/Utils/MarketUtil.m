//
//  MarketUtil.m
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

#import "MarketUtil.h"
#import "ExchangeUtil.h"

static NSMutableArray *markets;

@implementation MarketUtil
+ (NSArray *)getMarkets {
    if (markets && markets.count > 0) {
        return markets;
    }
    @synchronized (self) {
        if (markets.count == 0) {
            markets = [NSMutableArray new];
            for (MarketType marketType = BITSTAMP; marketType <= MARKET796; marketType++) {
                [markets addObject:[[Market alloc] initWithMarketType:marketType]];
            }
        }
        return markets;

    }
}

+ (Market *)getMarket:(MarketType)marketType {
    if (!markets || markets.count == 0) {
        [self getMarkets];
    }
    @synchronized (markets) {
        if (markets.count > 0) {
            for (Market *market in markets) {
                if (market.marketType == marketType) {
                    return market;
                }
            }
        }
    }
    return nil;
}

+ (Market *)getDefaultMarket {
    MarketType marketType = [[UserDefaultsUtil instance] getDefaultMarket];
    return [self getMarket:marketType];

}

+ (Ticker *)getTickerOfDefaultMarket {
    Market *market = [self getDefaultMarket];
    if (!market) {
        return market.ticker;
    }
    return nil;
}

+ (void)setTickerList:(NSArray *)array {
    if (array && array.count > 0) {
        @synchronized (markets) {
            for (Ticker *ticker in array) {
                Market *market = [self getMarket:ticker.marketType];
                if (market) {
                    [market setTicker:ticker];
                }
            }
        }
    }
}

+ (void)handlerResult:(NSDictionary *)dict {
//    double currentRate=[dict getDoubleFromDict:@"currency_rate"];
//    [ExchangeUtil setExchangeRate:currentRate];
    NSDictionary *currencies_rate_dict = dict[@"currencies_rate"];
    [ExchangeUtil setCurrenciesRate:currencies_rate_dict];
    NSArray *array = [Ticker formatList:dict];
    [self setTickerList:array];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:BitherMarketUpdateNotification object:nil];
    });
    NSLog(@"get ticker from network");

}

+ (double)getDefaultNewPrice {
    Market *market = [self getDefaultMarket];
    if (market.ticker) {
        return [market.ticker getDefaultExchangePrice];
    } else {
        return -1;
    }
}

@end






















