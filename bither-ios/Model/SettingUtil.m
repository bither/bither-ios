//
//  SettingUtil.m
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

#import "SettingUtil.h"
#import "Setting.h"
#import "DonationSetting.h"
#import "SignTransactionScanSetting.h"
#import "CloneQrCodeSetting.h"
#import "ColdWalletCloneSetting.h"
#import "BTAddressManager.h"
#import "AvatarSetting.h"
#import "MonitorSetting.h"
#import "MonitorHDAccountSetting.h"


@implementation SettingUtil

+ (NSArray *)hotSettings {
    NSMutableArray *array = [NSMutableArray new];
    [array addObject:[MonitorSetting getMonitorSetting]];
    [array addObject:[MonitorHDAccountSetting getMonitorHDAccountSetting]];
    [array addObject:[Setting getBitcoinUnitSetting]];
    [array addObject:[Setting getExchangeSetting]];
    [array addObject:[Setting getMarketSetting]];
    [array addObject:[Setting getTransactionFeeSetting]];
    if ([BTAddressManager instance].allAddresses.count == 0 && [BTAddressManager instance].trashAddresses.count == 0 && ![BTAddressManager instance].hdmKeychain && ![BTAddressManager instance].hasHDAccountHot && ![BTAddressManager instance].hasHDAccountMonitored) {
        [array addObject:[Setting getSwitchToColdSetting]];
    }
    [array addObject:[AvatarSetting getAvatarSetting]];
    [array addObject:[Setting getCheckSetting]];
    //[array addObject:[DonationSetting getDonateSetting]];
    [array addObject:[Setting getAdvanceSetting]];
    return array;
}


+ (NSArray *)coldSettings {
    NSMutableArray *array = [NSMutableArray new];
    [array addObject:[SignTransactionScanSetting getSignTransactionSetting]];
    [array addObject:[ColdWalletCloneSetting getCloneSetting]];
    if ([BTAddressManager instance].privKeyAddresses.count > 0) {
        [array addObject:[Setting getColdMonitorSetting]];
    }
    [array addObject:[Setting getBitcoinUnitSetting]];
    [array addObject:[Setting getAdvanceSetting]];
    return array;
}


@end
