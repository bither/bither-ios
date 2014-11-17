//
//  UnitUtil.m
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

#import "UnitUtil.h"
#import "UserDefaultsUtil.h"

@implementation UnitUtil

+(NSUInteger)satoshisForUnit:(BitcoinUnit)unit{
    switch (unit) {
        case bits:
            return 100;
        case BTC:
        default:
            return 100000000;
    }
}

+(NSUInteger)satoshis{
    return [UnitUtil satoshisForUnit:[UnitUtil unit]];
}

+(NSUInteger)boldAfterDot:(BitcoinUnit)unit{
    switch (unit) {
        case bits:
            return 0;
        case BTC:
        default:
            return 2;
    }
}

+(NSUInteger)boldAfterDot{
    return [UnitUtil boldAfterDot:[UnitUtil unit]];
}

+(BitcoinUnit)unit{
    return [[UserDefaultsUtil instance] getBitcoinUnit];
}

+(NSString*)imageName:(BitcoinUnit)unit{
    switch (unit) {
        case bits:
            return @"symbol_bits";
        case BTC:
        default:
            return @"symbol_btc";
    }
}

+(NSString*)imageName{
    return [UnitUtil imageName:[UnitUtil unit]];
}

+(NSString*)imageNameSlim:(BitcoinUnit)unit{
    switch (unit) {
        case bits:
            return @"symbol_bits_slim";
        case BTC:
        default:
            return @"symbol_btc_slim";
    }
}

+(NSString*)imageNameSlim{
    return [UnitUtil imageNameSlim:[UnitUtil unit]];
}

@end
