//
//  DialogHDMonitorFirstAddressValidation.h
//  bither-ios
//
//  Created by 宋辰文 on 16/6/11.
//  Copyright © 2016年 Bither. All rights reserved.
//

#import "DialogCentered.h"

@interface DialogHDMonitorFirstAddressValidation : DialogCentered
-(instancetype)initWithAddress:(NSString*)address target:(id)target okSelector:(SEL)okSelector cancelSelector:(SEL)cancelSelector;
@end
