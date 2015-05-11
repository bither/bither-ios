//
//  SignMessageViewController.h
//  bither-ios
//
//  Created by 宋辰文 on 14/12/23.
//  Copyright (c) 2014年 宋辰文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTAddress.h"

@interface SignMessageViewController : UIViewController
@property BTAddress *address;

- (void)showMsg:(NSString *)msg;
@end
