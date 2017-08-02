//
//  ObtainBccDetailViewController.h
//  bither-ios
//
//  Created by 韩珍 on 2017/7/26.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SendViewController.h"

@interface ObtainBccDetailViewController : UIViewController

@property BTAddress *btAddress;
@property uint64_t amount;
@property(weak) NSObject <SendDelegate> *sendDelegate;

@end
