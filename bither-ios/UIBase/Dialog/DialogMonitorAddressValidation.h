//
//  DialogMonitorAddressValidation.h
//  bither-ios
//
//  Created by 宋辰文 on 16/6/13.
//  Copyright © 2016年 Bither. All rights reserved.
//

#import "DialogCentered.h"

@interface DialogMonitorAddressValidation : DialogCentered
-(instancetype)initWithAddresses:(NSArray*)addresses target:(id)target andOkSelector:(SEL)okSelector;
@end
