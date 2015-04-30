//
//  HotAddressAddOtherViewController.m
//  bither-ios
//
//  Created by 宋辰文 on 15/4/24.
//  Copyright (c) 2015年 Bither. All rights reserved.
//

#import <Bitheri/BTAddressManager.h>
#import "HotAddressAddOtherViewController.h"
#import "BitherSetting.h"
#import "UIViewController+PiShowBanner.h"
#import "IOS7ContainerViewController.h"

@interface HotAddressAddOtherViewController ()

@end

@implementation HotAddressAddOtherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)privateKeyPressed:(id)sender {
    if ([BTAddressManager instance].privKeyAddresses.count >= PRIVATE_KEY_OF_HOT_COUNT_LIMIT) {
        [self showBannerWithMessage:NSLocalizedString(@"private_key_count_limit", nil) belowView:nil belowTop:0 autoHideIn:1 withCompletion:nil];
        return;
    }
    IOS7ContainerViewController *container = [[IOS7ContainerViewController alloc] init];
    container.controller = [self.storyboard instantiateViewControllerWithIdentifier:@"HotAddressAddPrivateKey"];
    [self presentViewController:container animated:YES completion:nil];
}

- (IBAction)hdmPressed:(id)sender {
    IOS7ContainerViewController *container = [[IOS7ContainerViewController alloc] init];
    container.controller = [self.storyboard instantiateViewControllerWithIdentifier:@"HotAddressAddHDM"];
    [self presentViewController:container animated:YES completion:nil];
}


@end
