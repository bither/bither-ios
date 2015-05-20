//
//  WatchUnitUtil.m
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
//  Created by songchenwen on 2015/2/25.
//

#import "WatchUnitUtil.h"
#import "GroupUserDefaultUtil.h"

@implementation WatchUnitUtil

+ (NSString *)stringForAmount:(int64_t)amount{
    GroupBitcoinUnit unit = [[GroupUserDefaultUtil instance] defaultBitcoinUnit];
    NSString *sign = amount >= 0 ? @"" : @"-";
    uint64_t absValue = amount >= 0 ? amount : 0 - amount;
    NSUInteger unitSatoshis = [WatchUnitUtil satoshisForUnit:unit];
    uint64_t coins = absValue / unitSatoshis;
    uint64_t satoshis = absValue % unitSatoshis;
    
    NSString* strSatoshis = [[NSString stringWithFormat:@"%llu", satoshis + unitSatoshis] substringFromIndex:1];
    
    if (unitSatoshis > pow(10, 2)) {
        while (strSatoshis.length > 2 && [strSatoshis characterAtIndex:strSatoshis.length - 1] == '0') {
            strSatoshis = [strSatoshis substringToIndex:strSatoshis.length - 1];
        }
    }
    
    NSString* point = strSatoshis.length > 0 ? @"." : @"";
    
    return [NSString stringWithFormat:@"%@%llu%@%@", sign, coins, point, strSatoshis];
}

+ (NSString *)imageNameOfSymbol{
    switch ([[GroupUserDefaultUtil instance] defaultBitcoinUnit]) {
        case UnitbitsG:
            return @"symbol_bits_slim";
        case UnitBTCG:
        default:
            return @"symbol_btc_slim";
    }
}


+ (NSString *)imageNameOfGreenSymbol{
    switch ([[GroupUserDefaultUtil instance] defaultBitcoinUnit]) {
        case UnitbitsG:
            return @"symbol_bits_green_slim";
        case UnitBTCG:
        default:
            return @"symbol_btc_green_slim";
    }
}

+ (NSString *)imageNameOfRedSymbol{
    switch ([[GroupUserDefaultUtil instance] defaultBitcoinUnit]) {
        case UnitbitsG:
            return @"symbol_bits_red_slim";
        case UnitBTCG:
        default:
            return @"symbol_btc_red_slim";
    }
}

+(NSString*)unitName:(GroupBitcoinUnit)unit{
    switch (unit) {
        case UnitbitsG:
            return @"bits";
        case UnitBTCG:
        default:
            return @"BTC";
    }
}

+(NSUInteger)satoshisForUnit:(GroupBitcoinUnit)unit{
    switch (unit) {
        case UnitbitsG:
            return 100;
        case UnitBTCG:
        default:
            return 100000000;
    }
}

@end
