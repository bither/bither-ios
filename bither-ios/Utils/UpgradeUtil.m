//
//  UpgradeUtil.m
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


#import "UpgradeUtil.h"
#import "UserDefaultsUtil.h"
#import "BTUtils.h"
#import "BTAddressManager.h"
#import "SystemUtil.h"
#define UPGRADE_PUBLIC_KEY_VERSION 110

@implementation UpgradeUtil

+(void)upgradePubKey{
    NSArray * addressList=[[BTAddressManager instance] allAddresses];
    long long sortTime=[[NSDate new] timeIntervalSince1970]*1000;
    for (int i=addressList.count-1; i>=0; i--) {
        BTAddress * address=[addressList objectAtIndex:i];
        address.sortTime=sortTime;
        sortTime++;
//        [address updateAddressWithPub];
    }
    [[UserDefaultsUtil instance] setLastVersion:[SystemUtil getVersionCode]];
}

+(BOOL)needUpgradePubKey{
    NSInteger currentVersion=[[UserDefaultsUtil instance] getLastVersion];
    if (currentVersion>=UPGRADE_PUBLIC_KEY_VERSION) {
        return NO;
    }
    NSArray * watchOnlyArray=[BTUtils getFileList:[BTUtils getWatchOnlyDir]];
    NSArray * privateKeyArray=[BTUtils getFileList:[BTUtils getPrivDir]];
    if (watchOnlyArray.count==0&&privateKeyArray.count==0) {
        return NO;
    }
    return YES;
    
}

+ (BOOL)need;{
    // version
    return YES;
}

@end
