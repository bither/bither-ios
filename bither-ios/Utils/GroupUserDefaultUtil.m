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

NSUserDefaults *userDefaults;
static GroupUserDefaultUtil *userDefaultsUtil;

@implementation GroupUserDefaultUtil

+ (GroupUserDefaultUtil *)instance {
    @synchronized(self) {
        if (userDefaultsUtil == nil) {
            userDefaultsUtil = [[self alloc] init];
            if([GroupFileUtil supported]){
                userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kBitherGroupName];
            } else {
                userDefaults = nil;
            }
        }
    }
    return userDefaultsUtil;
}

-(GroupMarketType)defaultMarket{
    if(userDefaults){
        NSInteger market=[userDefaults integerForKey:DEFAULT_MARKET];
        return (GroupMarketType)market;
    }
    return BITSTAMPG;
}

-(void)setDefaultMarket:(GroupMarketType)market{
    if(userDefaults){
        [userDefaults setInteger:market forKey:DEFAULT_MARKET];
        [userDefaults synchronize];
    }
}

-(GroupCurrency)defaultCurrency{
    if(userDefaults){
        if ([userDefaults objectForKey:DEFAULT_EXCHANGE_RATE]){
            return (GroupCurrency)[userDefaults integerForKey:DEFAULT_EXCHANGE_RATE];
        }else{
            return USDG;
        }
    }
    return USDG;
}

-(void)setDefaultCurrency:(GroupCurrency)currency{
    if(userDefaults){
        [userDefaults setInteger:currency forKey:DEFAULT_EXCHANGE_RATE];
        [userDefaults synchronize];
    }
}

-(GroupBitcoinUnit)defaultBitcoinUnit{
    if(userDefaults && [userDefaults objectForKey:BITCOIN_UNIT]){
        return (GroupBitcoinUnit)[userDefaults integerForKey:BITCOIN_UNIT];
    }
    return UnitBTCG;
}

-(void)setDefaultBitcoinUnit:(GroupBitcoinUnit)unit{
    if(userDefaults){
        [userDefaults setInteger:unit forKey:BITCOIN_UNIT];
        [userDefaults synchronize];
    }
}
@end
