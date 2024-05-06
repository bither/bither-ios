//
//  MinerFeeSettingViewController.h
//  bither-ios
//
//  Created by 韩珍珍 on 2024/4/30.
//  Copyright © 2024 Bither. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BitherSetting.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MinerFeeSettingViewControllerDelegate

- (void)changeMinerFeeMode:(MinerFeeMode)minerFeeMode minerFeeBase:(uint64_t)minerFeeBase;

@end

@interface MinerFeeSettingViewController : UIViewController

@property(assign, nonatomic) MinerFeeMode curMinerFeeMode;
@property(assign, nonatomic) uint64_t curMinerFeeBase;
@property(weak, nonatomic) NSObject <MinerFeeSettingViewControllerDelegate> *delegate;

- (instancetype)initWithDelegate:(NSObject <MinerFeeSettingViewControllerDelegate> *)delegate curMinerFeeMode:(MinerFeeMode)curMinerFeeMode curMinerFeeBase:(uint64_t)curMinerFeeBase;

@end

NS_ASSUME_NONNULL_END
