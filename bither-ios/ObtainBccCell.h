//
//  ObtainBccCell.h
//  bither-ios
//
//  Created by 韩珍 on 2017/7/28.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTAddress.h"
#import "SplitCoinUtil.h"

@interface ObtainBccCell : UITableViewCell

- (void)setObtainedForAddress:(BTAddress *)address splitCoin:(SplitCoin)splitCoin isShowLine:(BOOL)isShowLine;

- (void)setAddress:(BTAddress *)address bccBalance:(uint64_t)balance splitCoin:(SplitCoin)splitCoin isShowLine:(BOOL)isShowLine;

@end
