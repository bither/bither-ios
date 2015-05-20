//
//  WatchMarket.m
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
//
//  Created by songchenwen on 2015/2/27.
//

#import "WatchMarket.h"
#import "NSDictionary+Fromat.h"

#define VOLUME @"volume"
#define LAST @"last"
#define HIGH @"high"
#define LOW @"low"
#define ASK @"ask"
#define BID @"bid"

@implementation Ticker

- (double)getDefaultExchangeBuy {
    return self.buy * [WatchMarket getRateForMarket:self.marketType];
}

- (double)getDefaultExchangeHigh {
    return self.high * [WatchMarket getRateForMarket:self.marketType];
}

- (double)getDefaultExchangeLow {
    return self.low * [WatchMarket getRateForMarket:self.marketType];
}

- (double)getDefaultExchangePrice {
    return self.pNew * [WatchMarket getRateForMarket:self.marketType];
}

- (double)getDefaultExchangeSell {
    return self.sell * [WatchMarket getRateForMarket:self.marketType];
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
            Ticker *ticker = [self formatTicker:tickerDict market:marketType];
            [array addObject:ticker];
        }
    }
    return array;
}

@end


@interface WatchMarket () {
    Ticker *_ticker;
}

@end


static NSDictionary *_currenciesRate = nil;

@implementation WatchMarket

- (instancetype)initWithMarketType:(MarketType)marketType {
    self = [super init];
    if (self) {
        _marketType = marketType;
    }
    return self;
}


- (instancetype)initWithMarketType:(MarketType)marketType andTicker:(Ticker *)ticker {
    self = [super init];
    if (self) {
        _marketType = marketType;
        _ticker = ticker;
    }
    return self;
}

- (NSString *)getName {
    return [WatchMarket getMarketName:self.marketType];
}

- (Ticker *)ticker {
    if (!_ticker) {
        NSArray *tickers = [WatchMarket readTickers];
        for (Ticker *ti in tickers) {
            if (ti.marketType == self.marketType) {
                _ticker = ti;
                break;
            }
        }
    }
    return _ticker;
}


- (UIColor *)color {
    return [GroupUtil getMarketColor:_marketType];
}


- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[WatchMarket class]]) {
        if (((WatchMarket *) object).marketType == self.marketType) {
            return YES;
        }
    }
    return NO;
}

static NSMutableArray *markets;

+ (NSArray *)getMarkets {
    if (markets && markets.count > 0) {
        return markets;
    }
    markets = [NSMutableArray new];
    NSArray *tickers = [WatchMarket readTickers];
    for (MarketType marketType = BITSTAMP; marketType <= MARKET796; marketType++) {
        Ticker *t = nil;
        for (Ticker *ti in tickers) {
            if (ti.marketType == marketType) {
                t = ti;
                break;
            }
        }
        [markets addObject:[[WatchMarket alloc] initWithMarketType:marketType andTicker:t]];
    }
    return markets;
}

+ (NSArray *)readTickers {
    NSArray *tickers = nil;
    NSString *s = [GroupFileUtil getTicker];
    if (s) {
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[s dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if (dict) {
            tickers = [Ticker formatList:dict];
        }
    }
    return tickers;
}

+ (WatchMarket *)getDefaultMarket {
    for (WatchMarket *w in [WatchMarket getMarkets]) {
        if (w.marketType == [[GroupUserDefaultUtil instance] defaultMarket]) {
            return w;
        }
    }
    return [[WatchMarket alloc] initWithMarketType:[[GroupUserDefaultUtil instance] defaultMarket]];
}

+ (double)getRateForMarket:(MarketType)marketType {
    GroupCurrency defaultCurrency = [[GroupUserDefaultUtil instance] defaultCurrency];
    double rate = 1;
    GroupCurrency currency = [self getCurrencyForMarket:marketType];
    if (currency != defaultCurrency && [self getCurrenciesRate] != nil) {
        double preRate = [[self getCurrenciesRate][[WatchMarket getCurrencyName:currency]] doubleValue];
        double defaultRate = [[self getCurrenciesRate][[WatchMarket getCurrencyName:defaultCurrency]] doubleValue];
        rate = defaultRate / preRate;
    }
    return rate;
}

+ (GroupCurrency)getCurrencyForMarket:(MarketType)marketType {
    switch (marketType) {
        case HUOBI:
        case OKCOIN:
        case BTCCHINA:
        case CHBTC:
        case BTCTRADE:
            return CNYG;
        case BTCE:
        case BITSTAMP:
        case MARKET796:
        case BITFINEX:
        case COINBASE:
            return USDG;
        default:
            return CNYG;
    }
}

+ (NSDictionary *)getCurrenciesRate {
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

+ (NSString *)getCurrencySymbol:(GroupCurrency)currency; {
    switch (currency) {
        case USDG:
            return @"$";
        case CNYG:
            return @"¥";
        case EURG:
            return @"€";
        case GBPG:
            return @"£";
        case JPYG:
            return @"¥";
        case KRWG:
            return @"₩";
        case CADG:
            return @"C$";
        case AUDG:
            return @"A$";
        default:
            return @"$";
    }
}

+ (NSString *)getCurrencyName:(GroupCurrency)currency; {
    switch (currency) {
        case USDG:
            return @"USD";
        case CNYG:
            return @"CNY";
        case EURG:
            return @"EUR";
        case GBPG:
            return @"GBP";
        case JPYG:
            return @"JPY";
        case KRWG:
            return @"KRW";
        case CADG:
            return @"CAD";
        case AUDG:
            return @"AUD";
        default:
            return @"USD";
    }
}

+ (NSString *)getMarketName:(MarketType)marketType {
    NSString *name = [GroupUtil getMarketName:marketType];
    return name;
}

+ (NSDictionary *)parseCurrenciesRate:(NSDictionary *)dict {
    NSMutableDictionary *currenciesRate = [NSMutableDictionary dictionaryWithDictionary:dict];
    currenciesRate[@"USD"] = @1;
    return currenciesRate;
}
@end
