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

+(NSString *)getMarketName:(MarketType )marketType{
    NSString * name;
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
        default:
            name = NSLocalizedString(@"HUOBI", nil);
            break;
    }
    return name;
    
}
+(NSString *)getMarketDomain:(MarketType )marketType{
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
        default:
            return nil;
    }
}
+(NSString *)getExchangeSymbol:(ExchangeType)exchangeType{
    if (exchangeType==USD) {
        return @"$";
    }else {
        return @"¥";
    }
}

+(NSString *)getExchangeName:(ExchangeType)exchangeType{
    if (exchangeType==USD) {
        return @"USD";
    }else {
        return @"CNY";
    }
}
+(NSString *)getTransactionFeeMode:(TransactionFeeMode)transactionFee{
    if (transactionFee==Normal) {
        return NSLocalizedString(@"Normal", nil);
    }else{
        return NSLocalizedString(@"Low", nil);
    }
}
+(UIColor *)getMarketColor:(MarketType)marketType{
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
        default:
            return nil;
    }
}


@end
