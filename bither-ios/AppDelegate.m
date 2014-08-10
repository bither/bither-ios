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


#import "AppDelegate.h"
#import "BTAddressManager.h"
#import "BTPeerManager.h"
#import "BitherApi.h"
#import "BlockUtil.h"
#import "NSString+Base58.h"
#import "BTBlockChain.h"
#import "BTPeerProvider.h"
#import "IOS7ContainerViewController.h"
#import "NetworkUtil.h"
#import "UserDefaultsUtil.h"
#import "StringUtil.h"
#import "KeyUtil.h"
#import "PeerUtil.h"
#import "BitherTime.h"
#import "PeerUtil.h"
#import "BitherSetting.h"
#import "NotificationUtil.h"
#import "UIViewController+PiShowBanner.h"
#import "DialogAlert.h"
#import "PlaySoundUtil.h"
#import "CrashLog/CrashLog.h"
#import "AddressDetailViewController.h"
#import "Reachability.h"

@interface AppDelegate()
@end
static StatusBarNotificationWindow* notificationWindow;
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([[BTSettings instance] getAppMode]==COLD) {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
        
    }else{
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    }
    
    [[BTAddressManager sharedInstance] initAddress];
    [CrashLog initCrashLog];
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    if(![[BTSettings instance]needChooseMode]){
        IOS7ContainerViewController *container = [[IOS7ContainerViewController alloc]init];
        if ([[BTSettings instance] getAppMode]==HOT && [[BlockUtil instance] syncSpvFinish]) {
            container.controller = [storyboard instantiateViewControllerWithIdentifier:@"BitherHot"];
            self.window.rootViewController = container;
        }
        if([[BTSettings instance] getAppMode]==COLD && ![NetworkUtil isEnableWIFI] && ![NetworkUtil isEnable3G]){
            container.controller = [storyboard instantiateViewControllerWithIdentifier:@"BitherCold"];
            self.window.rootViewController = container;
        }
    }
    [self.window makeKeyAndVisible];
    
    NSLog(@"h %d",[[BTBlockChain instance] lastBlock].height);
    [self callInHot:^{
        [[PeerUtil instance] startPeer];
        [[BitherTime instance] start];
    }];
    [self callInCold:^{
        [[Reachability reachabilityForInternetConnection] startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChange) name:kReachabilityChangedNotification object:nil];
    }];
    notificationWindow = [[StatusBarNotificationWindow alloc]initWithOriWindow:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification:) name:BitherBalanceChangedNotification object:nil];
    return YES;
}
-(void)notification:(NSNotification *)notification{
    NSArray * array=[notification object];
    [NotificationUtil notificationTx:array];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self callInHot:^{
        [[BitherTime instance]pause];
    }];
    [self callInCold:^{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self callInHot:^{
        [[BitherTime instance] resume];
        if (![[BTPeerManager sharedInstance] connected]) {
            [[PeerUtil instance] startPeer];
        }
    }];
    [self callInCold:^{
        if ([NetworkUtil isEnable3G]||[NetworkUtil isEnableWIFI]) {
            if ([NetworkUtil isEnable3G]||[NetworkUtil isEnableWIFI]) {
                UIViewController * chooseModeViewController=[self.coldController.storyboard instantiateViewControllerWithIdentifier:@"ChooseModeViewController"];
                [self.coldController presentViewController:chooseModeViewController animated:YES completion:nil];
            }
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChange) name:kReachabilityChangedNotification object:nil];
        
    }];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    //TODO time of fetch
    if ([[BTSettings instance] getAppMode]==COLD) {
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    DDLogDebug(@"performFetc begin");
    __block id  syncFailedObserver = nil;
    __block void (^completion)(UIBackgroundFetchResult) = completionHandler;
    BTPeerManager *m = [BTPeerManager sharedInstance];
    
    if (m.syncProgress >= 1.0) {
        if (completion) completion(UIBackgroundFetchResultNoData);
        return;
    }
    
    // timeout after 25 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 25*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (syncFailedObserver) [[NSNotificationCenter defaultCenter] removeObserver:syncFailedObserver];
        syncFailedObserver = nil;
        [self stopPeerWithFetch];
        if (m.syncProgress > 0.1) {
            DDLogDebug(@"performFetc 25sec UIBackgroundFetchResultNewData");
            if (completion) completion(UIBackgroundFetchResultNewData);
        }
        else if (completion) completion(UIBackgroundFetchResultFailed);
         DDLogDebug(@"performFetc 25sec UIBackgroundFetchResultFailed");
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
                                                               DDLogDebug(@"performFetc BTPeerManagerSyncFailedNotification");
                                                           [self stopPeerWithFetch];
                                                           if (syncFailedObserver) [[NSNotificationCenter defaultCenter] removeObserver:syncFailedObserver];
                                                           // syncFinishedObserver = syncFailedObserver = nil;
                                                           syncFailedObserver=nil;
                                                           if (completion) completion(UIBackgroundFetchResultFailed);
                                                           completion = nil;
                                                           
//                                                           if (syncFinishedObserver) [[NSNotificationCenter defaultCenter] removeObserver:syncFinishedObserver];
                                                         }];
    
    [[PeerUtil instance] startPeer];
}
-(void)stopPeerWithFetch{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    if (state==UIApplicationStateBackground) {
        if ([[BTPeerManager sharedInstance] connected]) {
            [[BTPeerManager sharedInstance] disconnect];
        }
        
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification{
    NSDictionary* dic  = notification.userInfo;
    NSLog(@"user info = %@",[dic objectForKey:@"key"]);
    application.applicationIconBadgeNumber = 0;
    
    if([(NSNumber*)dic[@"ApplicationForeground"] boolValue] && dic[@"TxNotificationType"] && [(NSNumber*)dic[@"TxNotificationType"] integerValue] == txReceive){
        NSString* address = dic[@"address"];
        int64_t diff = [(NSNumber*)dic[@"diff"] longLongValue];
        if(diff != 0){
            [PlaySoundUtil playSound:@"coins_received" extension:@"wav" callback:nil];
            NSString* notification = [NSString stringWithFormat:@"%@ %@", diff >= 0 ? NSLocalizedString(@"Received", nil) : NSLocalizedString(@"Sent", nil), diff >= 0 ? [StringUtil stringForAmount:diff] : [StringUtil stringForAmount:0 - diff]];
            [notificationWindow showNotification:notification withAddress:address color:diff > 0 ? [UIColor greenColor] : [UIColor redColor]];
        }
    }
}

+(StatusBarNotificationWindow*)notificationWindow{
    return notificationWindow;
}

-(void)callInHot:(VoidBlock)voidBlock{
    if ([[BTSettings instance] getAppMode]==HOT) {
        if (voidBlock) {
            voidBlock();
        }
    }
}
-(void)callInCold:(VoidBlock) voidBlock{
    if ([[BTSettings instance] getAppMode]==COLD) {
        if (voidBlock) {
            voidBlock();
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BitherBalanceChangedNotification object:nil];
    [self callInCold:^{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    }];
    
    [[BitherTime instance] stop];
}
-(void)reachabilityChange{
    [self callInCold:^{
        if ([NetworkUtil isEnable3G]||[NetworkUtil isEnableWIFI]) {
            UIViewController * chooseModeViewController=[self.coldController.storyboard instantiateViewControllerWithIdentifier:@"ChooseModeViewController"];
            [self.coldController presentViewController:chooseModeViewController animated:YES completion:nil];
        }
    }];
    

}
@end

