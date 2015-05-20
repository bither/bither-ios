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


#import <Bitheri/BTTxProvider.h>
#import "UpgradeUtil.h"
#import "UserDefaultsUtil.h"
#import "BTAddressManager.h"
#import "SystemUtil.h"

#define UPGRADE_PUBLIC_KEY_VERSION 110
#define UPGRADE_KEY_FROM_FILE_TO_DB 131

@implementation UpgradeUtil

//+(void)upgradePubKey{
//    NSArray * addressList=[[BTAddressManager instance] allAddresses];
//    long long sortTime=[[NSDate new] timeIntervalSince1970]*1000;
//    for (int i=addressList.count-1; i>=0; i--) {
//        BTAddress * address=[addressList objectAtIndex:i];
//        address.sortTime=sortTime;
//        sortTime++;
////        [address updateAddressWithPub];
//    }
//    [[UserDefaultsUtil instance] setLastVersion:[SystemUtil getVersionCode]];
//}
//
//+(BOOL)needUpgradePubKey{
//    NSInteger currentVersion=[[UserDefaultsUtil instance] getLastVersion];
//    if (currentVersion>=UPGRADE_PUBLIC_KEY_VERSION) {
//        return NO;
//    }
//    NSArray * watchOnlyArray=[BTUtils getFileList:[BTUtils getWatchOnlyDir]];
//    NSArray * privateKeyArray=[BTUtils getFileList:[BTUtils getPrivDir]];
//    return !(watchOnlyArray.count == 0 && privateKeyArray.count == 0);
//
//}

+ (BOOL)needUpgradeKeyFromFileToDB; {
    NSInteger currentVersion = [[UserDefaultsUtil instance] getLastVersion];
    return currentVersion < UPGRADE_KEY_FROM_FILE_TO_DB;
}

+ (BOOL)upgradeKeyFromFileToDB; {
    BOOL success = YES;
    success &= [BTAddressManager updateKeyStoreFromFileToDbWithPasswordSeed:[[UserDefaultsUtil instance] getPasswordSeedForOldVersion]];
    [[BTTxProvider instance] clearAllTx];
    return success;
}

+ (BOOL)checkVersion; {
    __block BOOL success = YES;
    if ([UpgradeUtil needUpgradeKeyFromFileToDB]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            success &= [UpgradeUtil upgradeKeyFromFileToDB];
        });
    }
    if (success) {
        [[UserDefaultsUtil instance] setLastVersion:[SystemUtil getVersionCode]];
    }
    return success;
}

@end
