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
        case BITSTAMP:
            name = NSLocalizedString(@"Bitstamp", nil);
            break;
        case BITFINEX:
            name = NSLocalizedString(@"Bitfinex", nil);
            break;
        case COINBASE:
            name = NSLocalizedString(@"Coinbase", nil);
            break;
    }
    return name;

}

+ (NSString *)getMarketDomain:(MarketType)marketType {
    switch (marketType) {
        case BITSTAMP:
            return @"bitstamp.net";
        case BITFINEX:
            return @"bitfinex.com";
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
        case BITFINEX:
            return 6;
        case COINBASE:
            return 8;
    }
    return 1;

}

+ (MarketType)getMarketType:(NSInteger)value {
    switch (value) {
        case 6:
            return BITFINEX;
        case 8:
            return COINBASE;
    }
    return BITSTAMP;

}

+ (UIColor *)getMarketColor:(MarketType)marketType {
    switch (marketType) {
            //ff3bbf59
        case BITSTAMP:
            return RGBA(59, 191, 89, 1);
            //ffa3bd0b
        case BITFINEX:
            return RGBA(163, 189, 11, 1);
        case COINBASE:
            return RGBA(21, 103, 177, 1);
        default:
            return nil;
    }
}


@end
