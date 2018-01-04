//
//  GetForkCoinsController.h
//  bither-ios
//
//  Created by 张陆军 on 2018/1/19.
//  Copyright © 2018年 Bither. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+PiShowBanner.h"

@interface GetForkCoinsController : UIViewController <ShowBannerDelegete>
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) NSArray *settings;

- (void)reload;
@end
