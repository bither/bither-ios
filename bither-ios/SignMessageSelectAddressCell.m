//
//  SignMessageSelectAddressCell.m
//  bither-ios
//
//  Created by 韩珍 on 2017/7/21.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "SignMessageSelectAddressCell.h"
#import "StringUtil.h"
#import "UnitUtil.h"
#import "UIColor+Util.h"

#define kBlackColor (0x333333)
#define kRedColor (0xE13A41)

@interface SignMessageSelectAddressCell()

@property (weak, nonatomic) IBOutlet UILabel *lblBalance;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblIndex;

@end

@implementation SignMessageSelectAddressCell

- (void)showByAddress:(BTAddress *)address index:(NSInteger)index {
    [self showAddress:address.address balance:address.balance index:index];
}

- (void)showByHDAccountAddress:(BTHDAccountAddress *)hdAccountAddress {
    [self showAddress:hdAccountAddress.address balance:hdAccountAddress.balance index:hdAccountAddress.index];
}

- (void)showAddress:(NSString *)address balance:(uint64_t)balance index:(NSInteger)index {
    if ([[BTSettings instance] getAppMode] == HOT) {
        NSString *balanceTitleStr = NSLocalizedString(@"address_balance", nil);
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:balanceTitleStr];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor parseColor:kBlackColor] range:NSMakeRange(0, balanceTitleStr.length)];
        [attrStr appendAttributedString:[UnitUtil stringWithSymbolForAmount:balance withFontSize:_lblBalance.font.pointSize  color:[UIColor parseColor:kRedColor]]];
        self.lblBalance.attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
    }
    self.lblAddress.text = [StringUtil formatAddress:address groupSize:4 lineSize:20];
    self.lblIndex.text = [NSString stringWithFormat:@"%@%ld", NSLocalizedString(@"address_index", nil), (long)index];
}



@end
