//
//  SignMessageSelectAddressCell.h
//  bither-ios
//
//  Created by 韩珍 on 2017/7/21.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTAddress.h"
#import "BTHDAccountAddress.h"

@interface SignMessageSelectAddressCell : UITableViewCell

- (void)showByHDAccountAddress:(BTHDAccountAddress *)hdAccountAddress;
- (void)showByAddress:(BTAddress *)address index:(NSInteger)index;

@end
