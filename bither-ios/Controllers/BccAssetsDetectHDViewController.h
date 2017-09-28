//
//  BccAssetsDetectHDViewController.h
//  bither-ios
//
//  Created by LTQ on 2017/9/28.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTHDAccountAddress.h"

@interface BccAssetsDetectHDViewController : UIViewController

- (void)showHdAddresses:(PathType)path password:(NSString *)password isMonitored: (BOOL) isMonitored;

@end
