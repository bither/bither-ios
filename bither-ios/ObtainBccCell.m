//
//  ObtainBccCell.m
//  bither-ios
//
//  Created by 韩珍 on 2017/7/28.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "ObtainBccCell.h"
#import "StringUtil.h"
#import "UnitUtil.h"
#import "UIColor+Util.h"

#define kBlackColor (0x333333)
#define kRedColor (0xE13A41)

@interface ObtainBccCell()

@property (weak, nonatomic) IBOutlet UILabel *lblBalance;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UIView *lblLine;

@end

@implementation ObtainBccCell

- (void)setObtainedForAddress:(BTAddress *)address splitCoin:(SplitCoin)splitCoin isShowLine:(BOOL)isShowLine {
    self.lblAddress.text = [StringUtil formatAddress:address.address groupSize:4 lineSize:20];
    self.lblBalance.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"you_already_get_split_coin", nil), [SplitCoinUtil getSplitCoinName:splitCoin]];
    [self.lblLine setHidden:!isShowLine];
}

- (void)setAddress:(BTAddress *)address bccBalance:(uint64_t)balance splitCoin:(SplitCoin)splitCoin isShowLine:(BOOL)isShowLine {
    self.lblAddress.text = [StringUtil formatAddress:address.address groupSize:4 lineSize:20];
    NSString *balanceTitleStr = NSLocalizedString(@"get_split_coin", nil);
    NSString *balanceStr = [NSString stringWithFormat:@"%@%@%@", balanceTitleStr, [UnitUtil stringForAmount:balance unit:[SplitCoinUtil getBitcoinUnit:splitCoin]], [SplitCoinUtil getSplitCoinName:splitCoin]];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:balanceStr];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor parseColor:kRedColor] range:NSMakeRange(0, balanceStr.length)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor parseColor:kBlackColor] range:NSMakeRange(0, balanceTitleStr.length)];
    self.lblBalance.attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
    [self.lblLine setHidden:!isShowLine];
}

@end
