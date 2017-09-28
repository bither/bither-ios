//
//  DetectBccSetting.m
//  bither-ios
//
//  Created by LTQ on 2017/9/26.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "DetectBccSetting.h"
#import "BTAddressManager.h"
#import "UIViewController+PiShowBanner.h"
#import "BTOut.h"
#import "BTPeerManager.h"

static DetectBccSetting *S;

@interface DetectBccSetting()

@property(weak) UIViewController *controller;

@end

@implementation DetectBccSetting

+ (Setting *)getDetectBccSetting {
    if (!S) {
        S = [[DetectBccSetting alloc] init];
    }
    return S;
}

- (instancetype)init {
    self = [super initWithName:NSLocalizedString(@"detect_another_BCC_assets", nil) icon:nil];
    if (self) {
        __weak DetectBccSetting *s = self;
        [self setSelectBlock:^(UIViewController *controller) {
            
                BTAddressManager *manager = [BTAddressManager instance];
                if (![manager hasHDAccountHot] && ![manager hasHDAccountMonitored] && manager.privKeyAddresses.count == 0 && manager.watchOnlyAddresses.count == 0) {
                    [controller showBannerWithMessage:NSLocalizedString(@"no_private_key", nil) belowView:[controller.view subviews].lastObject];
                } else {
                    s.controller = controller;
                    [s show];
                }
        }];
    }
    return self;
}

- (void)show {
    [self.controller.navigationController pushViewController:[self.controller.storyboard instantiateViewControllerWithIdentifier:@"BCCAssetsDetectTableViewController"] animated:YES];
}
@end
