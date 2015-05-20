//
//  Ticker.h
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
#import "BitherSetting.h"

@interface Ticker : NSObject

@property(nonatomic, readwrite) double amount;
@property(nonatomic, readwrite) double level;
@property(nonatomic, readwrite) double high;
@property(nonatomic, readwrite) double low;
@property(nonatomic, readwrite) double pNew;
@property(nonatomic, readwrite) double amp;
@property(nonatomic, readwrite) double open;
@property(nonatomic, readwrite) double sell;
@property(nonatomic, readwrite) double buy;
@property(nonatomic, readwrite) double total;
@property(nonatomic, strong) NSDate *date;
@property(nonatomic, readwrite) MarketType marketType;

- (double)getDefaultExchangeHigh;

- (double)getDefaultExchangeLow;

- (double)getDefaultExchangePrice;

- (double)getDefaultExchangeSell;

- (double)getDefaultExchangeBuy;

+ (Ticker *)formatTicker:(NSDictionary *)dict market:(MarketType)marketType;

+ (NSArray *)formatList:(NSDictionary *)dict;


@end
