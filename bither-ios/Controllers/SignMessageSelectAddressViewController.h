//
//  SignMessageSelectAddressViewController.h
//  bither-ios
//
//  Created by 韩珍 on 2017/7/21.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTHDAccountAddress.h"

@interface SignMessageSelectAddressViewController : UIViewController

- (void)showAddresses:(NSArray *)addresses;
- (void)showHdAddresses:(PathType)path password:(NSString *)password;
@end
