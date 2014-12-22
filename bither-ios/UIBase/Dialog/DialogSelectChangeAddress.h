//
//  DialogSelectChangeAddress.h
//  bither-ios
//
//  Created by 宋辰文 on 14/12/22.
//  Copyright (c) 2014年 宋辰文. All rights reserved.
//

#import "DialogCentered.h"
#import "BTAddressManager.h"

@interface DialogSelectChangeAddress : DialogCentered
-(instancetype)initWithFromAddress:(BTAddress*)fromAddress;
@property(readonly) BTAddress* changeAddress;
@end
