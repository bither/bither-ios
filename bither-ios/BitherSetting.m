//
//  BitherSetting.m
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

#define DEV_DEBUG TRUE

#import "BitherSetting.h"

@implementation BitherSetting

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
        default:
            return nil;
    }
}

+ (NSString *)getCurrencySymbol:(Currency)currency; {
    switch (currency) {
        case USD:
            return @"$";
        case CNY:
            return @"¥";
        case EUR:
            return @"€";
        case GBP:
            return @"£";
        case JPY:
            return @"¥";
        case KRW:
            return @"₩";
        case CAD:
            return @"C$";
        case AUD:
            return @"A$";
        default:
            return @"$";
    }
}

+ (NSString *)getCurrencyName:(Currency)currency; {
    switch (currency) {
        case USD:
            return @"USD";
        case CNY:
            return @"CNY";
        case EUR:
            return @"EUR";
        case GBP:
            return @"GBP";
        case JPY:
            return @"JPY";
        case KRW:
            return @"KRW";
        case CAD:
            return @"CAD";
        case AUD:
            return @"AUD";
        default:
            return @"USD";
    }
}

+ (Currency)getCurrencyFromName:(NSString *)currencyName; {
    if (currencyName == nil || currencyName.length == 0){
        return USD;
    }
    if ([currencyName isEqualToString:@"USD"]) {
        return USD;
    }
    if ([currencyName isEqualToString:@"CNY"]) {
        return CNY;
    }
    if ([currencyName isEqualToString:@"EUR"]) {
        return EUR;
    }
    if ([currencyName isEqualToString:@"GBP"]) {
        return GBP;
    }
    if ([currencyName isEqualToString:@"JPY"]) {
        return JPY;
    }
    if ([currencyName isEqualToString:@"KRW"]) {
        return KRW;
    }
    if ([currencyName isEqualToString:@"CAD"]) {
        return CAD;
    }
    if ([currencyName isEqualToString:@"AUD"]) {
        return AUD;
    }
    return USD;
}

+ (NSString *)getTransactionFeeMode:(TransactionFeeMode)transactionFee {
    if (transactionFee == Normal) {
        return NSLocalizedString(@"Normal", nil);
    } else {
        return NSLocalizedString(@"Low", nil);
    }
}

+ (NSString *)getKeychainMode:(KeychainMode) keychainMode {
    if (keychainMode == Off) {
        return NSLocalizedString(@"Off", nil);
    } else {
        return NSLocalizedString(@"On", nil);
    }
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
        default:
            return nil;
    }
}


@end
