//
//  GroupUtil.m
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


#import "GroupUtil.h"


@implementation GroupUtil {

}


+ (NSString *)getMarketName:(MarketType)marketType {
    NSString *name;
    switch (marketType) {
        case HUOBI:
            name = NSLocalizedString(@"HUOBI", nil);
            break;
        case BITSTAMP:
            name = NSLocalizedString(@"Bitstamp", nil);
            break;
        case BTCE:
            name = NSLocalizedString(@"BTC-E", nil);
            break;
        case OKCOIN:
            name = NSLocalizedString(@"OKCoin.CN", nil);
            break;
        case CHBTC:
            name = NSLocalizedString(@"CHBTC", nil);
            break;
        case BTCCHINA:
            name = NSLocalizedString(@"BTCChina", nil);
            break;
        case BITFINEX:
            name = NSLocalizedString(@"Bitfinex", nil);
            break;
        case MARKET796:
            name = NSLocalizedString(@"796", nil);
            break;
        case BTCTRADE:
            name = NSLocalizedString(@"BtcTrade", nil);
            break;
        case COINBASE:
            name = NSLocalizedString(@"Coinbase", nil);
            break;
        default:
            name = NSLocalizedString(@"HUOBI", nil);
            break;
    }
    return name;

}

+ (NSString *)getMarketDomain:(MarketType)marketType {
    switch (marketType) {
        case HUOBI:
            return @"huobi.com";
        case BITSTAMP:
            return @"bitstamp.net";
        case BTCE:
            return @"btc-e.com";
        case OKCOIN:
            return @"okcoin.cn";
        case CHBTC:
            return @"chbtc.com";
        case BTCCHINA:
            return @"btcchina.com";
        case BITFINEX:
            return @"bitfinex.com";
        case MARKET796:
            return @"796.com";
        case BTCTRADE:
            return @"btctrade.com";
        case COINBASE:
            return @"coinbase.com";
        default:
            return nil;
    }
}


+ (int)getMarketValue:(MarketType)marketType {

    switch (marketType) {
        case BITSTAMP:
            return 1;
        case BTCE:
            return 2;
        case HUOBI:
            return 3;
        case OKCOIN:
            return 4;
        case BTCCHINA:
            return 5;
        case CHBTC:
            return 6;
        case BITFINEX:
            return 7;
        case MARKET796:
            return 8;
        case COINBASE:
            return 9;
        case BTCTRADE:
            return 10;


    }
    return 1;

}

+ (MarketType)getMarketType:(int)value {

    switch (value) {
        case 2:
            return BTCE;
        case 3:
            return HUOBI;
        case 4:
            return OKCOIN;
        case 5:
            return BTCCHINA;
        case 6:
            return CHBTC;
        case 7:
            return BITFINEX;
        case 8:
            return MARKET796;
        case 9:
            return COINBASE;
        case 10:
            return BTCTRADE;
    }
    return BITSTAMP;

}

+ (UIColor *)getMarketColor:(MarketType)marketType {
    switch (marketType) {
        //ffff9329
        case HUOBI:
            return RGBA(255, 147, 41, 1);
            //ff3bbf59
        case BITSTAMP:
            return RGBA(59, 191, 89, 1);
            //ff25bebc
        case BTCE:
            return RGBA(37, 190, 188, 1);
            //ff1587c6
        case OKCOIN:
            return RGBA(21, 135, 198, 1);
            //ff5b469d
        case CHBTC:
            return RGBA(91, 70, 157, 1);
            //fff93c25
        case BTCCHINA:
            return RGBA(249, 60, 37, 1);
            //ffa3bd0b
        case BITFINEX:
            return RGBA(163, 189, 11, 1);
            //ffe31f21
        case MARKET796:
            return RGBA(227, 31, 33, 1);
        case BTCTRADE:
            return RGBA(168, 88, 0, 1);
        case COINBASE:
            return RGBA(21, 103, 177, 1);
        default:
            return nil;
    }
}


@end