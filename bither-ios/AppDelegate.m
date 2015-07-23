//
//  AppDelegate.m
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


#import <Bitheri/BTUtils.h>
#import "AppDelegate.h"
#import "BTAddressManager.h"
#import "BTPeerManager.h"
#import "BitherApi.h"
#import "BlockUtil.h"
#import "IOS7ContainerViewController.h"
#import "NetworkUtil.h"
#import "UnitUtil.h"
#import "PeerUtil.h"
#import "BitherTime.h"
#import "NotificationUtil.h"
#import "PlaySoundUtil.h"
#import "CrashLog/CrashLog.h"
#import "TrendingGraphicData.h"
#import "UpgradeUtil.h"
#import "PinCodeUtil.h"

#import "DialogProgress.h"
#import "SystemUtil.h"
#import "GroupFileUtil.h"

@interface AppDelegate ()
@end

static StatusBarNotificationWindow *notificationWindow;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([[BTSettings instance] getAppMode] == COLD) {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
    } else {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    }

    [[BTPeerManager instance] initAddress];

    if ([[BTSettings instance] needChooseMode]) {
        [[BTSettings instance] setAppMode:HOT];
    }

    [CrashLog initCrashLog];
    if ([UpgradeUtil needUpgradeKeyFromFileToDB]) {
        DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
        __block  DialogProgress *sslfDp = dp;
        [dp showInWindow:self.window completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                BOOL success = [UpgradeUtil upgradeKeyFromFileToDB];
                if (success) {
                    [[UserDefaultsUtil instance] setLastVersion:[SystemUtil getVersionCode]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [sslfDp dismissWithCompletion:^{
                            [self loadViewController];
                        }];

                    });
                }
            });
        }];
    } else {
        [self loadViewController];
    }

    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil]];
    }

    [self hdAccountPaymentAddressChanged:nil];
    [self updateGroupBalance];

    //   [[BTSettings instance] openBitheriConsole];

    return YES;
}

- (void)loadViewController {
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    if (![[BTSettings instance] needChooseMode]) {
        IOS7ContainerViewController *container = [[IOS7ContainerViewController alloc] init];
        if ([[BTSettings instance] getAppMode] == HOT && [[BlockUtil instance] syncSpvFinish]) {
            container.controller = [storyboard instantiateViewControllerWithIdentifier:@"BitherHot"];
            self.window.rootViewController = container;
        }
        if ([[BTSettings instance] getAppMode] == COLD && ![NetworkUtil isEnableWIFI] && ![NetworkUtil isEnable3G]) {
            container.controller = [storyboard instantiateViewControllerWithIdentifier:@"BitherCold"];
            self.window.rootViewController = container;
        }
    }
    [self.window makeKeyAndVisible];

    // NSLog(@"h %d",[[BTBlockChain instance] lastBlock].blockNo);
    [self callInHot:^{
        [[PeerUtil instance] startPeer];
        [[BitherTime instance] start];
    }];
    [self callInCold:^{
        [[Reachability reachabilityForInternetConnection] startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChange) name:kReachabilityChangedNotification object:nil];

    }];
    notificationWindow = [[StatusBarNotificationWindow alloc] initWithOriWindow:self.window];
    [[PinCodeUtil instance] becomeActive];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification:) name:BitherBalanceChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hdAccountPaymentAddressChanged:) name:kHDAccountPaymentAddressChangedNotification object:nil];
}

- (void)notification:(NSNotification *)notification {
    NSArray *array = [notification object];
    [NotificationUtil notificationTx:array];
    [self updateGroupBalance];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self callInHot:^{
        [[BitherTime instance] pause];
    }];
    [self callInCold:^{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self callInHot:^{
        [[BitherTime instance] resume];
        [TrendingGraphicData clearCache];
        if (![[BTPeerManager instance] connected]) {
            [[PeerUtil instance] startPeer];
        }
    }];
    [self callInCold:^{
        if ([NetworkUtil isEnable3G] || [NetworkUtil isEnableWIFI]) {
            if ([NetworkUtil isEnable3G] || [NetworkUtil isEnableWIFI]) {
                UIViewController *chooseModeViewController = [self.coldController.storyboard instantiateViewControllerWithIdentifier:@"ChooseModeViewController"];
                [self.coldController presentViewController:chooseModeViewController animated:YES completion:nil];
            }
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChange) name:kReachabilityChangedNotification object:nil];

    }];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    //TODO time of fetch
    if ([[BTSettings instance] getAppMode] == COLD) {
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    DDLogDebug(@"perform fetch begin");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hdAccountPaymentAddressChanged:) name:kHDAccountPaymentAddressChangedNotification object:nil];
    __block id syncFailedObserver = nil;
    __block void (^completion)(UIBackgroundFetchResult) = completionHandler;
    BTPeerManager *m = [BTPeerManager instance];

//    if (m.syncProgress >= 1.0) {
//        if (completion) completion(UIBackgroundFetchResultNoData);
//        return;
//    }

    // timeout after 25 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (syncFailedObserver) [[NSNotificationCenter defaultCenter] removeObserver:syncFailedObserver];
        syncFailedObserver = nil;
        double syncProgress = m.syncProgress;
        [self stopPeerWithFetch];
        if (syncProgress > 0.1) {
            DDLogDebug(@"perform fetch 25sec UIBackgroundFetchResultNewData");
            if (completion) completion(UIBackgroundFetchResultNewData);
        } else {
            if (completion) completion(UIBackgroundFetchResultNoData);
            DDLogDebug(@"perform fetch 25sec UIBackgroundFetchResultNoData");
        }
        completion = nil;

        //  if (syncFinishedObserver) [[NSNotificationCenter defaultCenter] removeObserver:syncFinishedObserver];

        //TODO: XXXX disconnect
    });

//    syncFinishedObserver =
//    [[NSNotificationCenter defaultCenter] addObserverForName:BTPeerManagerSyncFinishedNotification object:nil
//                                                       queue:nil usingBlock:^(NSNotification *note) {
//                                                           DDLogDebug(@"performFetc BTPeerManagerSyncFinishedNotification");
//                                                        
//                                                           if (completion) completion(UIBackgroundFetchResultNewData);
//                                                           completion = nil;
//                                                           
//                                                           if (syncFinishedObserver) [[NSNotificationCenter defaultCenter] removeObserver:syncFinishedObserver];
//                                                           if (syncFailedObserver) [[NSNotificationCenter defaultCenter] removeObserver:syncFailedObserver];
//                                                           syncFinishedObserver = syncFailedObserver = nil;
//                                                       }];
//    
    syncFailedObserver =
            [[NSNotificationCenter defaultCenter] addObserverForName:BTPeerManagerSyncFailedNotification object:nil
                                                               queue:nil usingBlock:^(NSNotification *note) {
                        DDLogDebug(@"perform fetch BTPeerManagerSyncFailedNotification");
                        [self stopPeerWithFetch];
                        if (syncFailedObserver) [[NSNotificationCenter defaultCenter] removeObserver:syncFailedObserver];
                        // syncFinishedObserver = syncFailedObserver = nil;
                        syncFailedObserver = nil;
                        if (completion) completion(UIBackgroundFetchResultFailed);
                        completion = nil;

//                                                           if (syncFinishedObserver) [[NSNotificationCenter defaultCenter] removeObserver:syncFinishedObserver];
                    }];

    [[PeerUtil instance] startPeer];
}

- (void)stopPeerWithFetch {
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    if (state == UIApplicationStateBackground) {
        if ([[BTPeerManager instance] connected]) {
            [[BTPeerManager instance] stop];
        }

    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    NSLog(@"user info = %@", [dic objectForKey:@"key"]);
    application.applicationIconBadgeNumber = 0;

    if ([(NSNumber *) dic[@"ApplicationForeground"] boolValue] && dic[@"TxNotificationType"] && [(NSNumber *) dic[@"TxNotificationType"] integerValue] == txReceive) {
        NSString *address = dic[@"address"];
        int64_t diff = [(NSNumber *) dic[@"diff"] longLongValue];
        if (diff != 0) {
            [PlaySoundUtil playSound:@"coins_received" extension:@"wav" callback:nil];
            NSString *notification = [NSString stringWithFormat:@"%@ %@ %@", diff >= 0 ? NSLocalizedString(@"Received", nil) : NSLocalizedString(@"Sent", nil), diff >= 0 ? [UnitUtil stringForAmount:diff] : [UnitUtil stringForAmount:0 - diff], [UnitUtil unitName]];
            [notificationWindow showNotification:notification withAddress:address color:diff > 0 ? [UIColor greenColor] : [UIColor redColor]];
        }
    }
}

+ (StatusBarNotificationWindow *)notificationWindow {
    return notificationWindow;
}

- (void)updateGroupBalance {
    if ([GroupFileUtil supported]) {
        int64_t hdm = 0;
        int64_t hot = 0;
        int64_t cold = 0;
        NSArray *allAddresses = [BTAddressManager instance].allAddresses;
        for (BTAddress *a in allAddresses) {
            if (a.isHDM) {
                hdm += a.balance;
            } else if (a.hasPrivKey) {
                hot += a.balance;
            } else {
                cold += a.balance;
            }
        }
        int64_t hd = 0;
        if ([BTAddressManager instance].hasHDAccountHot) {
            hd = [BTAddressManager instance].hdAccountHot.balance;
        }
        int64_t hdMonitored = 0;
        if ([BTAddressManager instance].hasHDAccountMonitored) {
            hdMonitored = [BTAddressManager instance].hdAccountMonitored.balance;
        }
        [GroupFileUtil setTotalBalanceWithHD:hd hdMonitored:hdMonitored hot:hot andCold:cold HDM:hdm];
    }
}

- (void)callInHot:(VoidBlock)voidBlock {
    if ([[BTSettings instance] getAppMode] == HOT) {
        if (voidBlock) {
            voidBlock();
        }
    }
}

- (void)callInCold:(VoidBlock)voidBlock {
    if ([[BTSettings instance] getAppMode] == COLD) {
        if (voidBlock) {
            voidBlock();
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BitherBalanceChangedNotification object:nil];
    [self callInCold:^{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHDAccountPaymentAddressChangedNotification object:nil];
    [[BitherTime instance] stop];
}

- (void)hdAccountPaymentAddressChanged:(NSNotification *)notification {
    if (![BTAddressManager instance].hasHDAccountHot && ![BTAddressManager instance].hasHDAccountMonitored) {
        return;
    }
    UserDefaultsUtil *defaults = [UserDefaultsUtil instance];
    BTHDAccount *accountHot = [BTAddressManager instance].hdAccountHot;
    BTHDAccount *accountMonitored = [BTAddressManager instance].hdAccountMonitored;
    NSString *paymentAddress = defaults.paymentAddress;
    BOOL configured = paymentAddress != nil;
    BOOL shouldChange = NO;
    BTHDAccount *targetAccount = nil;
    if (configured) {
        if ([BTUtils isEmpty:paymentAddress]) {
            shouldChange = NO;
        } else {
            if (accountHot) {
                shouldChange = [accountHot getBelongAccountAddressesFromAddresses:@[paymentAddress]].count > 0;
                if (shouldChange) {
                    targetAccount = accountHot;
                }
            }
            if (!shouldChange && accountMonitored) {
                shouldChange = [accountMonitored getBelongAccountAddressesFromAddresses:@[paymentAddress]].count > 0;
                if (shouldChange) {
                    targetAccount = accountMonitored;
                }
            }
        }
    } else {
        shouldChange = YES;
    }
    if (shouldChange && targetAccount) {
        if (![BTUtils compareString:targetAccount.address compare:paymentAddress]) {
            [defaults setPaymentAddress:targetAccount.address];
        }
    }
}

- (void)reachabilityChange {
    [self callInCold:^{
        if ([NetworkUtil isEnable3G] || [NetworkUtil isEnableWIFI]) {
            UIViewController *chooseModeViewController = [self.coldController.storyboard instantiateViewControllerWithIdentifier:@"ChooseModeViewController"];
            [self.coldController presentViewController:chooseModeViewController animated:YES completion:nil];
        }
    }];
}
@end

