//
//  MinerFeeSettingCell.m
//  bither-ios
//
//  Created by 韩珍珍 on 2024/4/30.
//  Copyright © 2024 Bither. All rights reserved.
//

#import "MinerFeeSettingCell.h"

@interface MinerFeeSettingCell () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnMode;
@property (weak, nonatomic) IBOutlet UIImageView *ivCheck;
@property (weak, nonatomic) IBOutlet UITextField *tfCustom;
@property (weak, nonatomic) IBOutlet UILabel *lblCustomUnit;
@property (weak, nonatomic) IBOutlet UIButton *btnCustomConfirm;

@property (assign, nonatomic) MinerFeeMode minerFeeMode;
@property (assign, nonatomic) uint64_t minerFeeBase;

@end

@implementation MinerFeeSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _tfCustom.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showFromMinerFeeModeModel:(MinerFeeModeModel *)minerFeeModeModel curMinerFeeMode:(MinerFeeMode)curMinerFeeMode curMinerFeeBase:(uint64_t)curMinerFeeBase {
    _minerFeeMode = minerFeeModeModel.getMinerFeeMode;
    _minerFeeBase = [BitherSetting getMinerFeeBaseFromMinerFeeMode:_minerFeeMode];
    if (_minerFeeBase > 0) {
        [_btnMode setTitle:[[NSString alloc] initWithFormat:@"%@ %llusat/vB", [BitherSetting getMinerFeeModeName:_minerFeeMode], _minerFeeBase / 1000] forState:normal];
    } else {
        [_btnMode setTitle:[BitherSetting getMinerFeeModeName:_minerFeeMode] forState:normal];
    }
    if (curMinerFeeMode == _minerFeeMode) {
        [_ivCheck setHidden:false];
        if (curMinerFeeMode == CustomFee) {
            if (curMinerFeeBase > 0) {
                [_tfCustom setText:[[NSString alloc] initWithFormat:@"%llu", curMinerFeeBase / 1000]];
            }
            [self showCustom:true];
        } else {
            [self showCustom:false];
        }
    } else {
        [_ivCheck setHidden:true];
        [self showCustom:false];
    }
}

- (void)showCustom:(BOOL)isShow {
    [_tfCustom setHidden:!isShow];
    [_lblCustomUnit setHidden:!isShow];
    [_btnCustomConfirm setHidden:!isShow];
}

- (IBAction)btnModeClicked:(UIButton *)sender {
    [self.delegate minerFeeClicked:_minerFeeMode minerFeeBase:_minerFeeBase];

}

- (IBAction)btnCustomConfirmClicked:(UIButton *)sender {
    NSString *customStr = _tfCustom.text;
    if (!customStr || customStr.length == 0) {
        [self.delegate customConfirmClicked:0];
        return;
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString: customStr];
    if (number != nil) {
        uint64_t custom = [number unsignedLongLongValue];
        [self.delegate customConfirmClicked:custom];
    } else {
        [self.delegate customConfirmClicked:0];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self btnCustomConfirmClicked:_btnCustomConfirm];
    return YES;
}

@end
