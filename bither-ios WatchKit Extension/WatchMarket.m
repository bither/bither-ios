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

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define VOLUME @"volume"
#define LAST @"last"
#define HIGH @"high"
#define LOW @"low"
#define ASK @"ask"
#define BID @"bid"

@implementation Ticker

-(double)getDefaultExchangeBuy{
    return self.buy* [WatchMarket getRateForMarket:self.marketType];
}
-(double)getDefaultExchangeHigh{
    return self.high* [WatchMarket getRateForMarket:self.marketType];
}
-(double) getDefaultExchangeLow{
    return self.low* [WatchMarket getRateForMarket:self.marketType];
}
-(double)getDefaultExchangePrice{
    return self.pNew* [WatchMarket getRateForMarket:self.marketType];
}
-(double)getDefaultExchangeSell{
    return self.sell* [WatchMarket getRateForMarket:self.marketType];
}

+(Ticker *)formatTicker:(NSDictionary *)dict market:(GroupMarketType) marketType{
    Ticker * ticker=[[Ticker alloc] init];
    [ticker setAmount:[dict getDoubleFromDict:VOLUME]/pow(10, 8)];
    [ticker setHigh:[dict getDoubleFromDict:HIGH]/100];
    [ticker setLow:[dict getDoubleFromDict:LOW]/100];
    [ticker setPNew:[dict getDoubleFromDict:LAST]/100];
    [ticker setBuy:[dict getDoubleFromDict:BID]/100];
    [ticker setSell:[dict getDoubleFromDict:ASK]/100];
    [ticker setAmp:-1];
    [ticker setTotal:-1];
    [ticker setLevel:-1];
    [ticker setOpen:-1];
    [ticker setMarketType:marketType];
    return ticker;
}

+(NSArray *)formatList:(NSDictionary *)dict{
    NSMutableArray * array=[NSMutableArray new];
    for(GroupMarketType marketType=BITSTAMPG;marketType<=MARKET796G;marketType++){
        NSString * key=[NSString stringWithFormat:@"%d",marketType];
        if ([[dict allKeys] containsObject:key]) {
            NSDictionary *tickerDict=[dict objectForKey:key];
            Ticker * ticker=[self formatTicker:tickerDict market:marketType];
            [array addObject:ticker];
        }
    }
    return array;
}

@end


@interface WatchMarket(){
    Ticker* _ticker;
}

@end


static NSDictionary *_currenciesRate = nil;
@implementation WatchMarket

-(instancetype)initWithMarketType:(GroupMarketType)marketType{
    self=[super init];
    if (self) {
        _marketType = marketType;
    }
    return self;
}

-(instancetype)initWithMarketType:(GroupMarketType)marketType andTicker:(Ticker*)ticker{
    self=[super init];
    if (self) {
        _marketType = marketType;
        _ticker = ticker;
    }
    return self;
}

-(NSString *)getName{
    return [WatchMarket getMarketName:self.marketType];
}

-(Ticker*)ticker{
    if(!_ticker){
        NSArray *tickers = [WatchMarket readTickers];
        for(Ticker* ti in tickers){
            if(ti.marketType == self.marketType){
                _ticker = ti;
                break;
            }
        }
    }
    return _ticker;
}

-(UIColor *)color{
    switch (self.marketType) {
            //ffff9329
        case HUOBIG:
            return RGBA(255, 147, 41, 1);
            //ff3bbf59
        case BITSTAMPG:
            return RGBA(59, 191, 89, 1);
            //ff25bebc
        case BTCEG:
            return RGBA(37, 190, 188, 1);
            //ff1587c6
        case OKCOING:
            return RGBA(21, 135, 198, 1);
            //ff5b469d
        case CHBTCG:
            return RGBA(91, 70, 157, 1);
            //fff93c25
        case BTCCHINAG:
            return RGBA(249, 60, 37, 1);
            //ffa3bd0b
        case BITFINEXG:
            return RGBA(163, 189, 11, 1);
            //ffe31f21
        case MARKET796G:
            return RGBA(227, 31, 33, 1);
        default:
            return nil;
    }
}

-(BOOL)isEqual:(id)object{
    if([object isKindOfClass:[WatchMarket class]]){
        if(((WatchMarket*) object).marketType == self.marketType){
            return YES;
        }
    }
    return NO;
}

static NSMutableArray* markets;

+(NSArray *)getMarkets{
    if(markets && markets.count > 0){
        return markets;
    }
    markets=[NSMutableArray new];
    NSArray *tickers = [WatchMarket readTickers];
    for(GroupMarketType marketType=BITSTAMPG; marketType<=MARKET796G; marketType++){
        Ticker* t = nil;
        for(Ticker* ti in tickers){
            if(ti.marketType == marketType){
                t = ti;
                break;
            }
        }
        [markets addObject:[[WatchMarket alloc]initWithMarketType:marketType andTicker:t]];
    }
    return markets;
}

+(NSArray*)readTickers{
    NSArray *tickers = nil;
    NSString* s = [GroupFileUtil getTicker];
    if(s){
        NSError *error = nil;
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:[s dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if(dict){
            tickers = [Ticker formatList:dict];
        }
    }
    return tickers;
}

+(WatchMarket *)getDefaultMarket{
    for(WatchMarket* w in [WatchMarket getMarkets]){
        if(w.marketType == [[GroupUserDefaultUtil instance] defaultMarket]){
            return w;
        }
    }
    return [[WatchMarket alloc] initWithMarketType:[[GroupUserDefaultUtil instance] defaultMarket]];
}

+ (double)getRateForMarket:(GroupMarketType)marketType {
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

+ (GroupCurrency)getCurrencyForMarket:(GroupMarketType)marketType {
    switch (marketType) {
        case HUOBIG:
        case OKCOING:
        case BTCCHINAG:
        case CHBTCG:
            return CNYG;
        case BTCEG:
        case BITSTAMPG:
        case MARKET796G:
        case BITFINEXG:
            return USDG;
        default:
            return CNYG;
    }
}

+ (NSDictionary *)getCurrenciesRate{
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

+ (NSString *)getMarketName:(GroupMarketType)marketType {
    NSString *name;
    switch (marketType) {
        case HUOBIG:
            name = NSLocalizedString(@"HUOBI", nil);
            break;
        case BITSTAMPG:
            name = NSLocalizedString(@"Bitstamp", nil);
            break;
        case BTCEG:
            name = NSLocalizedString(@"BTC-E", nil);
            break;
        case OKCOING:
            name = NSLocalizedString(@"OKCoin.CN", nil);
            break;
        case CHBTCG:
            name = NSLocalizedString(@"CHBTC", nil);
            break;
        case BTCCHINAG:
            name = NSLocalizedString(@"BTCChina", nil);
            break;
        case BITFINEXG:
            name = NSLocalizedString(@"Bitfinex", nil);
            break;
        case MARKET796G:
            name = NSLocalizedString(@"796", nil);
            break;
        default:
            name = NSLocalizedString(@"HUOBI", nil);
            break;
    }
    return name;
}

+ (NSDictionary *)parseCurrenciesRate:(NSDictionary *)dict; {
    NSMutableDictionary *currenciesRate = [NSMutableDictionary dictionaryWithDictionary:dict];
    currenciesRate[@"USD"] = @1;
    return currenciesRate;
}
@end
