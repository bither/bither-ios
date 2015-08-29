//
//  HotAddressTabButton.h
//  bither-ios
//
//  Created by noname on 14-7-31.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "TabButton.h"

@interface HotAddressTabButton : TabButton

- (void)setAmount:(int64_t)amount;

- (void)balanceChanged;
@end
