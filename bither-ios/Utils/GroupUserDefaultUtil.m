//
//  GroupUserDefaultUtil.m
//  bither-ios
//
//  Copyright 2015 http://Bither.net
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
//  Created by songchenwen on 2015/3/5.
//

#import "GroupUserDefaultUtil.h"
#import "GroupFileUtil.h"
#define DEFAULT_MARKET @"default_market"
#define DEFAULT_EXCHANGE_RATE @"default_exchange_rate"
#define BITCOIN_UNIT @"bitcoin_unit"

NSUserDefaults *groupUserDefaults;
static GroupUserDefaultUtil *groupUserDefaultsUtil;

@implementation GroupUserDefaultUtil

+ (GroupUserDefaultUtil *)instance {
    @synchronized(self) {
        if (groupUserDefaultsUtil == nil) {
            groupUserDefaultsUtil = [[self alloc] init];
            if([GroupFileUtil supported]){
                groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:kBitherGroupName];
            } else {
                groupUserDefaults = nil;
            }
        }
    }
    return groupUserDefaultsUtil;
}

-(GroupMarketType)defaultMarket{
    if(groupUserDefaults){
        NSInteger market=[groupUserDefaults integerForKey:DEFAULT_MARKET];
        if(market > 0){
            return (GroupMarketType)market;
        }
    }
    if([self localeIsChina]){
        return HUOBIG;
    }
    return BITSTAMPG;
}

-(void)setDefaultMarket:(GroupMarketType)market{
    if(groupUserDefaults){
        [groupUserDefaults setInteger:market forKey:DEFAULT_MARKET];
        [groupUserDefaults synchronize];
    }
}

-(GroupCurrency)defaultCurrency{
    if(groupUserDefaults){
        if ([groupUserDefaults objectForKey:DEFAULT_EXCHANGE_RATE]){
            return (GroupCurrency)[groupUserDefaults integerForKey:DEFAULT_EXCHANGE_RATE];
        }
    }
    if([self localeIsChina]){
        return CNYG;
    }
    return USDG;
}

-(void)setDefaultCurrency:(GroupCurrency)currency{
    if(groupUserDefaults){
        [groupUserDefaults setInteger:currency forKey:DEFAULT_EXCHANGE_RATE];
        [groupUserDefaults synchronize];
    }
}

-(GroupBitcoinUnit)defaultBitcoinUnit{
    if(groupUserDefaults && [groupUserDefaults objectForKey:BITCOIN_UNIT]){
        return (GroupBitcoinUnit)[groupUserDefaults integerForKey:BITCOIN_UNIT];
    }
    return UnitBTCG;
}

-(void)setDefaultBitcoinUnit:(GroupBitcoinUnit)unit{
    if(groupUserDefaults){
        [groupUserDefaults setInteger:unit forKey:BITCOIN_UNIT];
        [groupUserDefaults synchronize];
    }
}

-(BOOL)localeIsChina{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    return  [language isEqualToString:@"zh-Hans"];
}
@end
