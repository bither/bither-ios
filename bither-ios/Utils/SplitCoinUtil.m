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
        default:
            name = @"BCH";
            break;
    }
    return name;
}

@end
