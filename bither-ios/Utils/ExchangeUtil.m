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
#import "FileUtil.h"
#import "GroupFileUtil.h"

//static double rate = -1;
static NSDictionary *_currenciesRate = nil;

@implementation ExchangeUtil
//+ (void)setExchangeRate:(double)exchangeRate {
//    rate = exchangeRate;
//    NSString *rateString = [NSString stringWithFormat:@"%f", rate];
//    [BTUtils writeFile:[CacheUtil getExchangeFile] content:rateString];
//
//}
//
//+ (double)getExchangeRate {
//    if (rate == -1) {
//        NSString *rateString = [BTUtils readFile:[CacheUtil getExchangeFile]];
//        if (![StringUtil isEmpty:rateString] && [StringUtil isPureFloat:rateString]) {
//            rate = [rateString doubleValue];
//        } else {
//            rate = 1;
//        }
//
//    }
//    return rate;
//
//}

+ (void)setCurrenciesRate:(NSDictionary *)currenciesRate; {
    _currenciesRate = [self parseCurrenciesRate:currenciesRate];
    [GroupFileUtil setCurrencyRate:[currenciesRate jsonEncodedKeyValueString]];
}

+ (NSDictionary *)getCurrenciesRate; {
    if (_currenciesRate == nil) {
        NSString *currenciesRateStr = [GroupFileUtil getCurrencyRate];
        if (currenciesRateStr == nil || currenciesRateStr.length == 0) {
            _currenciesRate = nil;
        } else {
            NSError *error = nil;
            NSData *data = [currenciesRateStr dataUsingEncoding:NSUTF8StringEncoding];
            _currenciesRate = [self parseCurrenciesRate:[NSJSONSerialization JSONObjectWithData:data options:0 error:&error]];;
            if (error != nil) {
                _currenciesRate = nil;
            }
        }
    }
    return _currenciesRate;
}

+ (NSDictionary *)parseCurrenciesRate:(NSDictionary *)dict; {
    NSMutableDictionary *currenciesRate = [NSMutableDictionary dictionaryWithDictionary:dict];
    currenciesRate[@"USD"] = @1;
    return currenciesRate;
}

+ (double)getRate:(Currency)currency {
    Currency defaultCurrency = [[UserDefaultsUtil instance] getDefaultCurrency];
    double rate = 1;
    if (currency != defaultCurrency && [self getCurrenciesRate] != nil) {
        double preRate = [[self getCurrenciesRate][[BitherSetting getCurrencyName:currency]] doubleValue];
        double defaultRate = [[self getCurrenciesRate][[BitherSetting getCurrencyName:defaultCurrency]] doubleValue];
        rate = defaultRate / preRate;
    }
    return rate;
}

+ (double)getRateForMarket:(MarketType)marketType {
    Currency defaultCurrency = [[UserDefaultsUtil instance] getDefaultCurrency];
    double rate = 1;
    Currency currency = [self getCurrencyForMarket:marketType];
    if (currency != defaultCurrency && [self getCurrenciesRate] != nil) {
        double preRate = [[self getCurrenciesRate][[BitherSetting getCurrencyName:currency]] doubleValue];
        double defaultRate = [[self getCurrenciesRate][[BitherSetting getCurrencyName:defaultCurrency]] doubleValue];
        rate = defaultRate / preRate;
    }
    return rate;
}

+ (Currency)getCurrencyForMarket:(MarketType)marketType {
    switch (marketType) {
        case HUOBI:
        case OKCOIN:
        case BTCCHINA:
        case CHBTC:
        case BTCTRADE:
            return CNY;
        case BITSTAMP:
        case MARKET796:
        case BITFINEX:
        case COINBASE:
            return USD;
        default:
            return CNY;
    }
}
@end




















