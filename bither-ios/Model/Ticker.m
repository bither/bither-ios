//
//  Ticker.m
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

#import "Ticker.h"
#import "ExchangeUtil.h"
#import "NSDictionary+Fromat.h"

// key of
#define VOLUME @"volume"
#define LAST @"last"
#define HIGH @"high"
#define LOW @"low"
#define ASK @"ask"
#define BID @"bid"


@implementation Ticker
- (double)getDefaultExchangeBuy {
    return self.buy * [ExchangeUtil getRateForMarket:self.marketType];
}

- (double)getDefaultExchangeHigh {
    return self.high * [ExchangeUtil getRateForMarket:self.marketType];
}

- (double)getDefaultExchangeLow {
    return self.low * [ExchangeUtil getRateForMarket:self.marketType];
}

- (double)getDefaultExchangePrice {
    return self.pNew * [ExchangeUtil getRateForMarket:self.marketType];
}

- (double)getDefaultExchangeSell {
    return self.sell * [ExchangeUtil getRateForMarket:self.marketType];
}

+ (Ticker *)formatTicker:(NSDictionary *)dict market:(MarketType)marketType {
    Ticker *ticker = [[Ticker alloc] init];
    [ticker setAmount:[dict getDoubleFromDict:VOLUME] / pow(10, 8)];
    [ticker setHigh:[dict getDoubleFromDict:HIGH] / 100];
    [ticker setLow:[dict getDoubleFromDict:LOW] / 100];
    [ticker setPNew:[dict getDoubleFromDict:LAST] / 100];
    [ticker setBuy:[dict getDoubleFromDict:BID] / 100];
    [ticker setSell:[dict getDoubleFromDict:ASK] / 100];
    [ticker setAmp:-1];
    [ticker setTotal:-1];
    [ticker setLevel:-1];
    [ticker setOpen:-1];
    [ticker setMarketType:marketType];
    return ticker;
}

+ (NSArray *)formatList:(NSDictionary *)dict {
    NSMutableArray *array = [NSMutableArray new];
    for (MarketType marketType = BITSTAMP; marketType <= MARKET796; marketType++) {
        NSString *key = [NSString stringWithFormat:@"%d", [GroupUtil getMarketValue:marketType]];
        if ([[dict allKeys] containsObject:key]) {
            NSDictionary *tickerDict = [dict objectForKey:key];
            if(tickerDict && ![tickerDict isKindOfClass:[NSNull class]]){
                Ticker *ticker = [self formatTicker:tickerDict market:marketType];
                [array addObject:ticker];
            }
        }
    }
    return array;
}

@end


















