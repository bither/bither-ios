//
//  MinerFeeSettingCell.h
//  bither-ios
//
//  Created by 韩珍珍 on 2024/4/30.
//  Copyright © 2024 Bither. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BitherSetting.h"
#import "MinerFeeModeModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MinerFeeSettingCellDelegate <NSObject>

- (void)minerFeeClicked:(MinerFeeMode)minerFeeMode minerFeeBase:(uint64_t)minerFeeBase;

- (void)customConfirmClicked:(uint64_t)custom;

@end

@interface MinerFeeSettingCell : UITableViewCell

- (void)showFromMinerFeeModeModel:(MinerFeeModeModel *)minerFeeModeModel curMinerFeeMode:(MinerFeeMode)curMinerFeeMode curMinerFeeBase:(uint64_t)curMinerFeeBase;

@property(weak) NSObject <MinerFeeSettingCellDelegate> *delegate;

@end

NS_ASSUME_NONNULL_END
