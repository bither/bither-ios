//
//  MinerFeeModeModel.m
//  bither-ios
//
//  Created by 韩珍珍 on 2024/4/30.
//  Copyright © 2024 Bither. All rights reserved.
//

#import "MinerFeeModeModel.h"

@implementation MinerFeeModeModel

- (instancetype)initWithMinerFeeMode:(MinerFeeMode)minerFeeMode {
    self = [super init];
    if (self) {
        self.minerFeeMode = minerFeeMode;
    }
    return self;
}

+ (NSArray *)getAllModes {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (MinerFeeMode mode = DynamicFee; mode <= CustomFee; mode++) {
        [mutableArray addObject:[[MinerFeeModeModel alloc] initWithMinerFeeMode:mode]];
    }
    return mutableArray;
}

- (MinerFeeMode)getMinerFeeMode {
    return _minerFeeMode;
}

@end
