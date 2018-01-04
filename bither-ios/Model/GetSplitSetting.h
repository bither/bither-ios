//
//  GetSplitSetting.h
//  bither-ios
//
//  Created by 张陆军 on 2018/1/18.
//  Copyright © 2018年 Bither. All rights reserved.
//

#import "Setting.h"
#import "SplitCoinUtil.h"

@interface GetSplitSetting : Setting
@property(nonatomic) SplitCoin splitCoin;

+ (GetSplitSetting *)getSplitSetting:(SplitCoin)splitCoin;

@end
