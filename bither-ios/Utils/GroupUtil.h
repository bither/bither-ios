//
//  GroupUtil.h
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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

typedef enum {
    BITSTAMP, BTCCHINA, OKCOIN, HUOBI, CHBTC, BTCTRADE, BITFINEX,
    COINBASE, MARKET796
} MarketType;


@interface GroupUtil : NSObject


+ (NSString *)getMarketName:(MarketType)marketType;

+ (NSString *)getMarketDomain:(MarketType)marketType;

+ (UIColor *)getMarketColor:(MarketType)marketType;

+ (int)getMarketValue:(MarketType)marketType;

+ (MarketType)getMarketType:(NSInteger)value;

@end
