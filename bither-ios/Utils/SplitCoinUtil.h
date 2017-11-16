//
//  SplitCoinUtil.h
//  bither-ios
//
//  Created by 韩珍 on 2017/11/15.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SplitBCC, SplitBTG
} SplitCoin;

@interface SplitCoinUtil : NSObject

+ (NSString *)getSplitCoinName:(SplitCoin)splitCoin;

@end
