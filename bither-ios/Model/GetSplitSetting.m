//
//  GetSplitSetting.m
//  bither-ios
//
//  Created by 张陆军 on 2018/1/18.
//  Copyright © 2018年 Bither. All rights reserved.
//

#import "GetSplitSetting.h"
#import "BTAddressManager.h"
#import "UIViewController+PiShowBanner.h"
#import "BTOut.h"
#import "BTBlockProvider.h"
#import "BTPeerManager.h"
#import "ObtainBccViewController.h"


@interface GetSplitSetting ()

@property(weak) UIViewController *controller;

@end


@implementation GetSplitSetting

+ (Setting *)getSplitSetting:(SplitCoin)splitCoin; {
    GetSplitSetting *S = [[GetSplitSetting alloc] init:splitCoin];
    S.splitCoin = splitCoin;
    return S;
}

- (instancetype)init:(SplitCoin)splitCoin {
    self = [super initWithName:[NSString stringWithFormat:NSLocalizedString(@"get_split_coin_setting_name", nil), [SplitCoinUtil getSplitCoinName:splitCoin]] icon:nil];
    if (self) {
        __weak GetSplitSetting *s = self;
        [self setSelectBlock:^(UIViewController *controller) {
            
            u_int32_t lastBlockHeight = [BTPeerManager instance].lastBlockHeight;
            uint64_t forkBlockHeight = [BTTx getForkBlockHeightForCoin:[SplitCoinUtil getCoin:splitCoin]];
            if (lastBlockHeight < forkBlockHeight) {
                NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"please_firstly_sync_to_block_no", nil), forkBlockHeight];
                [controller showBannerWithMessage:msg belowView:[controller.view subviews].lastObject];
            } else {
                BTAddressManager *manager = [BTAddressManager instance];
                if (![manager hasHDAccountHot] && ![manager hasHDAccountMonitored] && manager.privKeyAddresses.count == 0 && manager.watchOnlyAddresses.count == 0) {
                    [controller showBannerWithMessage:NSLocalizedString(@"no_private_key", nil) belowView:[controller.view subviews].lastObject];
                } else {
                    s.controller = controller;
                    [s show];
                }
            }
        }];
    }
    return self;
}

- (void)show {
    ObtainBccViewController *vc = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"ObtainBccViewController"];
    vc.splitCoin = self.splitCoin;
    [self.controller.navigationController pushViewController:vc animated:YES];
}

@end

