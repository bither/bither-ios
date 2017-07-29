//
//  ObtainBCCSetting.m
//  bither-ios
//
//  Created by 韩珍 on 2017/7/26.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "ObtainBccSetting.h"
#import "BTAddressManager.h"

static ObtainBccSetting *S;

@interface ObtainBccSetting ()

@property(weak) UIViewController *controller;

@end


@implementation ObtainBccSetting

+ (Setting *)getObtainBccSetting {
    if (!S) {
        S = [[ObtainBccSetting alloc] init];
    }
    return S;
}

- (instancetype)init {
    self = [super initWithName:NSLocalizedString(@"obtain_bcc_setting_name", nil) icon:nil];
    if (self) {
        __weak ObtainBccSetting *s = self;
        [self setSelectBlock:^(UIViewController *controller) {
            s.controller = controller;
            [s show];
        }];
    }
    return self;
}

- (void)show {
    [self.controller.navigationController pushViewController:[self.controller.storyboard instantiateViewControllerWithIdentifier:@"ObtainBccViewController"] animated:YES];
}

@end
