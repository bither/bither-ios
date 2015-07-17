//
//  StatusBarNotificationWindow.m
//  bither-ios
//
//  Copyright 2014 http://Bither.net
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "StatusBarNotificationWindow.h"
#import "IOS7ContainerViewController.h"
#import <BTAddressManager.h>
#import "AddressDetailViewController.h"
#import "StringUtil.h"

#define kNotificationAnimationDuration (0.6)

@interface NotificationViewController : UIViewController

@end

@implementation StatusBarNotificationWindow

- (instancetype)initWithOriWindow:(UIWindow *)ori {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.oriWindow = ori;
        self.windowLevel = UIWindowLevelStatusBar;
        self.rootViewController = [[NotificationViewController alloc] init];
        self.rootViewController.view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.rootViewController.view.backgroundColor = [UIColor clearColor];
        self.btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, [UIApplication sharedApplication].statusBarFrame.size.height)];
        [self.btn setBackgroundColor:[UIColor colorWithRed:56.0 / 255.0 green:61.0 / 255.0 blue:64.0 / 255.0 alpha:1]];
        [self.btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.btn addTarget:self action:@selector(notificationPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.btn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        [self.rootViewController.view addSubview:self.btn];
    }
    return self;
}


- (void)showNotification:(NSString *)notification withAddress:(NSString *)address color:(UIColor *)color {
    [self.btn setTitle:notification forState:UIControlStateNormal];
    [self.btn setTitleColor:color forState:UIControlStateNormal];
    self.notificationAddress = address;
    [self.btn sizeToFit];
    self.btn.frame = CGRectMake(self.frame.size.width - self.btn.frame.size.width, -self.frame.size.height, self.btn.frame.size.width, [UIApplication sharedApplication].statusBarFrame.size.height);
    [self makeKeyAndVisible];
    [UIView animateWithDuration:kNotificationAnimationDuration animations:^{
        self.btn.frame = CGRectMake(self.frame.size.width - self.btn.frame.size.width, 0, self.btn.frame.size.width, [UIApplication sharedApplication].statusBarFrame.size.height);
    }];
}

- (void)notificationPressed:(id)sender {
    UIViewController *ctr = self.oriWindow.rootViewController;
    if ([ctr isKindOfClass:[IOS7ContainerViewController class]] && self.notificationAddress) {
        IOS7ContainerViewController *container = (IOS7ContainerViewController *) ctr;
        if (container.childViewControllers.count == 0) {
            return;
        }
        if ([container.childViewControllers[0] isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = container.childViewControllers[0];
            if (nav.topViewController.presentedViewController) {
                [nav.topViewController dismissViewControllerAnimated:YES completion:^{
                    [self toDetail:nav];
                }];
                return;
            }
            [self toDetail:nav];
        }
    }
}

- (void)toDetail:(UINavigationController *)nav {
    UIViewController *topVc = nav.topViewController;
    if ([topVc isKindOfClass:[AddressDetailViewController class]] && ([StringUtil compareString:self.notificationAddress compare:[(AddressDetailViewController *) topVc address].address] || ([[(AddressDetailViewController *) topVc address] isKindOfClass:[BTHDAccount class]] && ((BTHDAccount *) [(AddressDetailViewController *) topVc address]).hasPrivKey && [StringUtil compareString:self.notificationAddress compare:kHDAccountPlaceHolder]) || ([[(AddressDetailViewController *) topVc address] isKindOfClass:[BTHDAccount class]] && !((BTHDAccount *) [(AddressDetailViewController *) topVc address]).hasPrivKey && [StringUtil compareString:self.notificationAddress compare:kHDAccountMonitoredPlaceHolder]))) {

    } else {
        if ([StringUtil compareString:self.notificationAddress compare:kHDAccountMonitoredPlaceHolder] && [BTAddressManager instance].hasHDAccountMonitored) {
            BTHDAccount *account = [BTAddressManager instance].hdAccountMonitored;
            AddressDetailViewController *detail = [nav.storyboard instantiateViewControllerWithIdentifier:@"AddressDetail"];
            detail.address = account;
            [nav pushViewController:detail animated:YES];
        } else if ([StringUtil compareString:self.notificationAddress compare:kHDAccountPlaceHolder] && [BTAddressManager instance].hasHDAccountHot) {
            BTHDAccount *account = [BTAddressManager instance].hdAccountHot;
            AddressDetailViewController *detail = [nav.storyboard instantiateViewControllerWithIdentifier:@"AddressDetail"];
            detail.address = account;
            [nav pushViewController:detail animated:YES];
        } else {
            NSArray *addresses = [BTAddressManager instance].allAddresses;
            for (BTAddress *address in addresses) {
                if ([StringUtil compareString:address.address compare:self.notificationAddress]) {
                    AddressDetailViewController *detail = [nav.storyboard instantiateViewControllerWithIdentifier:@"AddressDetail"];
                    detail.address = address;
                    [nav pushViewController:detail animated:YES];
                    break;
                }
            }
        }
    }
    [self removeNotification];
}

- (void)removeNotification {
    self.notificationAddress = nil;
    [UIView animateWithDuration:kNotificationAnimationDuration animations:^{
        self.btn.frame = CGRectMake(self.frame.size.width - self.btn.frame.size.width, -self.frame.size.height, self.btn.frame.size.width, self.frame.size.height);
    }                completion:^(BOOL finished) {
        [self.oriWindow makeKeyAndVisible];
        self.hidden = YES;
    }];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return CGRectContainsPoint(self.btn.frame, point);
}
@end

@implementation NotificationViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
