//
//  DialogHDColdFirst20Addresses.h
//  bither-ios
//
//  Created by 宋辰文 on 16/6/9.
//  Copyright © 2016年 Bither. All rights reserved.
//

#import "DialogCentered.h"
#import <Bitheri/BTHDAccountCold.h>

@interface DialogHDColdFirst20Addresses : DialogCentered

- (instancetype)initWithAccount:(BTHDAccountCold *)account andPassword:(NSString*) password;
@end
