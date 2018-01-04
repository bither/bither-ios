//
//  SplitCoinUtil.m
//  bither-ios
//
//  Created by 韩珍 on 2017/11/15.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "SplitCoinUtil.h"

@implementation SplitCoinUtil

+ (NSString *)getSplitCoinName:(SplitCoin)splitCoin {
    NSString *name;
    switch (splitCoin) {
        case SplitBCC:
            name = @"BCH";
            break;
        case SplitBTG:
            name = @"BTG";
            break;
        case SplitSBTC:
            name = @"SBTC";
            break;
        case SplitBTW:
            name = @"BTW";
            break;
        case SplitBCD:
            name = @"BCD";
            break;
        default:
            name = @"BCH";
            break;
    }
    return name;
}
+ (BitcoinUnit)getBitcoinUnit:(SplitCoin)splitCoin {
    BitcoinUnit unit = UnitBTC;
    switch (splitCoin) {
        case SplitBTW:
            unit = UnitBTW;
            break;
        case SplitBCD:
            unit = UnitBCD;
            break;
        default:
            unit = UnitBCD;
            break;
    }
    return unit;
}
@end
