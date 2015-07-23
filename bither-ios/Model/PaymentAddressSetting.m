//
//  PaymentAddressSetting.m
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
//
//  Created by songchenwen on 15/5/11.
//

#import <Bitheri/BTAddressManager.h>
#import <Bitheri/BTUtils.h>
#import "PaymentAddressSetting.h"
#import "UserDefaultsUtil.h"
#import "SelectViewController.h"

static PaymentAddressSetting *paymentAddressSetting;

@implementation PaymentAddressSetting

+ (instancetype)setting {
    if (!paymentAddressSetting) {
        paymentAddressSetting = [[self alloc] init];
    }
    return paymentAddressSetting;
}

- (instancetype)init {
    self = [super initWithName:NSLocalizedString(@"payment_address_setting", nil) icon:nil];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    [self setGetValueBlock:^NSObject * {
        NSString *a = [UserDefaultsUtil instance].paymentAddress;
        if (![BTUtils isEmpty:a]) {
            if ([self isHDAccountHotAddress:a]) {
                return NSLocalizedString(@"address_group_hd", nil);
            }
            if ([self isHDAccountMonitoredAddress:a]){
                return NSLocalizedString(@"hd_account_cold_address_list_label", nil);
            }
            return [StringUtil shortenAddress:a];
        } else {
            return NSLocalizedString(@"payment_address_none", nil);
        }
    }];
    [self setGetArrayBlock:^NSArray * {
        NSMutableArray *a = [NSMutableArray new];
        [a addObject:[self dictForNone]];
        if ([BTAddressManager instance].hasHDAccountHot) {
            [a addObject:[self dictForHDAccountHot]];
        }
        if ([BTAddressManager instance].hasHDAccountMonitored) {
            [a addObject:[self dictForHDAccountMonitored]];
        }
        for (BTAddress *address in [BTAddressManager instance].allAddresses) {
            [a addObject:[self dictForAddress:address.address]];
        }
        return a;
    }];
    [self setResult:^(NSDictionary *dict) {
        NSObject *o = [dict objectForKey:SETTING_VALUE];
        if ([o isKindOfClass:[NSString class]]) {
            [[UserDefaultsUtil instance] setPaymentAddress:o];
        }
    }];
    __block PaymentAddressSetting *s = self;
    [self setSelectBlock:^(UIViewController *controller) {
        SelectViewController *selectController = [controller.storyboard instantiateViewControllerWithIdentifier:@"SelectViewController"];
        UINavigationController *nav = controller.navigationController;
        selectController.setting = s;
        [nav pushViewController:selectController animated:YES];
    }];
}

- (NSDictionary *)dictForNone {
    return @{SETTING_KEY : NSLocalizedString(@"payment_address_none", nil), SETTING_VALUE : @"", SETTING_IS_DEFAULT : @([BTUtils isEmpty:[UserDefaultsUtil instance].paymentAddress])};
}

- (NSDictionary *)dictForAddress:(NSString *)a {
    return @{SETTING_KEY : [StringUtil shortenAddress:a], SETTING_VALUE : a, SETTING_IS_DEFAULT : @([BTUtils compareString:[UserDefaultsUtil instance].paymentAddress compare:a])};
}

- (NSDictionary *)dictForHDAccountHot {
    return @{SETTING_KEY : NSLocalizedString(@"address_group_hd", nil), SETTING_VALUE : [BTAddressManager instance].hdAccountHot.address, SETTING_IS_DEFAULT : @([self isHDAccountHotAddress:[UserDefaultsUtil instance].paymentAddress])};
}

- (NSDictionary *)dictForHDAccountMonitored {
    return @{SETTING_KEY : NSLocalizedString(@"hd_account_cold_address_list_label", nil), SETTING_VALUE : [BTAddressManager instance].hdAccountMonitored.address, SETTING_IS_DEFAULT : @([self isHDAccountMonitoredAddress:[UserDefaultsUtil instance].paymentAddress])};
}

- (BOOL)isHDAccountHotAddress:(NSString *)address {
    if(!address){
        return NO;
    }
    if ([BTAddressManager instance].hasHDAccountHot) {
        return [[BTAddressManager instance].hdAccountHot getBelongAccountAddressesFromAddresses:@[address]].count > 0;
    }
    return NO;
}

- (BOOL)isHDAccountMonitoredAddress:(NSString *)address {
    if (!address){
        return NO;
    }
    if ([BTAddressManager instance].hasHDAccountMonitored) {
        return [[BTAddressManager instance].hdAccountMonitored getBelongAccountAddressesFromAddresses:@[address]].count > 0;
    }
    return NO;
}

- (BOOL)isOurNormalAddress:(NSString *)address {
    return [[BTAddressManager instance].addressesSet containsObject:address];
}

@end
