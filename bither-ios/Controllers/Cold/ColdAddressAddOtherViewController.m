//
//  ColdAddressAddOtherViewController.m
//  bither-ios
//
//  Created by 宋辰文 on 15/7/15.
//  Copyright (c) 2015年 Bither. All rights reserved.
//

#import "ColdAddressAddOtherViewController.h"
#import <Bitheri/BTAddressManager.h>
#import "BitherSetting.h"
#import "UIViewController+PiShowBanner.h"
#import "IOS7ContainerViewController.h"

@interface ColdAddressAddOtherViewController ()

@end

@implementation ColdAddressAddOtherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)privateKeyPressed:(id)sender {
    if ([BTAddressManager instance].privKeyAddresses.count >= PRIVATE_KEY_OF_COLD_COUNT_LIMIT) {
        [self showBannerWithMessage:NSLocalizedString(@"private_key_count_limit", nil) belowView:nil belowTop:0 autoHideIn:1 withCompletion:nil];
        return;
    }
    IOS7ContainerViewController *container = [[IOS7ContainerViewController alloc] init];
    container.controller = [self.storyboard instantiateViewControllerWithIdentifier:@"HotAddressAddPrivateKey"];
    [self presentViewController:container animated:YES completion:nil];
}

- (IBAction)hdmPressed:(id)sender {
    if ([BTAddressManager instance].hasHDMKeychain) {
        [self showBannerWithMessage:NSLocalizedString(@"hdm_cold_seed_count_limit", nil) belowView:nil belowTop:0 autoHideIn:1 withCompletion:nil];
        return;
    }
    IOS7ContainerViewController *container = [[IOS7ContainerViewController alloc] init];
    container.controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ColdAddressAddHDM"];
    [self presentViewController:container animated:YES completion:nil];
}


@end
