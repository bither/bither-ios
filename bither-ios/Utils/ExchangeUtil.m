//
//  ExchangeUtil.m
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

#import "ExchangeUtil.h"
#import "CacheUtil.h"
#import "FileUtil.h"
#import "BTUtils.h"
#import "StringUtil.h"
#import "UserDefaultsUtil.h"

static double rate=-1;

@implementation ExchangeUtil
+(void)setExchangeRate:(double) exchangeRate{
    rate=exchangeRate;
    NSString * rateString=[NSString stringWithFormat:@"%f",rate];
    [BTUtils writeFile:[CacheUtil getExchangeFile] content:rateString];
    
}
+(double) getExchangeRate{
    if (rate==-1) {
        NSString * rateString=[BTUtils readFile:[CacheUtil getExchangeFile]];
        if (![StringUtil isEmpty:rateString]&&[StringUtil isPureFloat:rateString]) {
            rate=[rateString doubleValue];
        }else{
            rate= 1;
        }
        
    }
    return rate;
    
}
+(double)getRate:(ExchangeType) exchangeType{
    ExchangeType defaultExchangeType=[[UserDefaultsUtil instance] getDefaultExchangeType];
    double rate=1;
    if (exchangeType!=defaultExchangeType) {
        double preRate=[self getExchangeRate];
        if (defaultExchangeType==CNY) {
            rate=rate*preRate;
        }else{
            rate=rate/preRate;
        }
    }
    return rate;
}

+(double)getRateOfMareket:(MarketType) marketType{
    ExchangeType exchangeType=[[UserDefaultsUtil instance] getDefaultExchangeType];
    double rate=1;
    double preRate=[self getExchangeRate];
    switch (marketType) {
        case HUOBI:
        case OKCOIN:
        case BTCCHINA:
        case CHBTC:
            if (exchangeType==USD) {
                rate=rate/preRate;
            }
            break;
        case BTCE:
        case BITSTAMP:
            if (exchangeType==CNY) {
                rate=rate*preRate;
            }
            break;
        default:
            break;
    }
    if (rate<0) {
        rate=1;
    }
    return rate;
}
+(ExchangeType) getExchangeType:(MarketType )marketType{
    switch (marketType) {
        case HUOBI:
        case OKCOIN:
        case BTCCHINA:
        case CHBTC:
            return CNY;
            break;
        case BTCE:
        case BITSTAMP:
            return USD;
        default:
            break;
    }
    return CNY;
}
@end




















