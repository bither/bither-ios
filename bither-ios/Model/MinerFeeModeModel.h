//
//  MinerFeeModeModel.h
//  bither-ios
//
//  Created by 韩珍珍 on 2024/4/30.
//  Copyright © 2024 Bither. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BitherSetting.h"

NS_ASSUME_NONNULL_BEGIN

@interface MinerFeeModeModel : NSObject

@property(assign, nonatomic) MinerFeeMode minerFeeMode;

- (instancetype)initWithMinerFeeMode:(MinerFeeMode)minerFeeMode;

+ (NSArray *)getAllModes;

- (MinerFeeMode)getMinerFeeMode;

@end

NS_ASSUME_NONNULL_END
