//
//  SplitCoinUtil.h
//  bither-ios
//
//  Created by 韩珍 on 2017/11/15.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BitherSetting.h"
#import "BTTx.h"

typedef enum {
    SplitBCC, SplitBTG, SplitSBTC,SplitBTW, SplitBCD, SplitBTF, SplitBTP, SplitBTN, None
} SplitCoin;

@interface SplitCoinUtil : NSObject

+ (NSString *)getSplitCoinName:(SplitCoin)splitCoin;

+ (NSString *)getPathCoinCodee:(SplitCoin)splitCoin;

+ (BitcoinUnit)getBitcoinUnit:(SplitCoin)splitCoin;

+ (BitcoinUnit)getUnit:(NSString *)unitName;

+ (Coin)getCoin:(SplitCoin)splitCoin;

+ (BOOL)validSplitCoinAddress:(SplitCoin)splitCoin address:(NSString *)addr;

+ (SplitCoin)getCoinByAddressFormat:(NSString *)addr;

@end
