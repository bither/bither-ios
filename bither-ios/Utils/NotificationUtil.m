//
//  NotificationUtil.m
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
#import "NotificationUtil.h"
#import "BTAddressManager.h"
#import "UnitUtil.h"
#import "AppDelegate.h"

@implementation NotificationUtil
+ (void)notificationTx:(NSArray *)array {
    if ([array objectAtIndex:0] == [NSNull null] || [array objectAtIndex:1] == [NSNull null]) {
        return;
    }
    NSString *address = [array objectAtIndex:0];
    long long diff = [[array objectAtIndex:1] longLongValue];
    NSString *typeString = diff < 0 ? NSLocalizedString(@"Send:", nil) : NSLocalizedString(@"Received:", nil);
    long long diffValue = diff;
    if (diff < 0) {
        diffValue = 0 - diff;
    }
    NSString *balanceString = [[UnitUtil stringForAmount:diff] stringByAppendingString:[NSString stringWithFormat:@" %@", [UnitUtil unitName]]];
    NSString *msg = [NSString stringWithFormat:@"%@ %@%@", address, typeString, balanceString];
    if ([BTUtils compareString:address compare:kHDAccountPlaceHolder]) {
        msg = [NSString stringWithFormat:@"%@ %@%@", NSLocalizedString(@"address_group_hd", nil), typeString, balanceString];
    } else if ([BTUtils compareString:address compare:kHDAccountMonitoredPlaceHolder]) {
        msg = [NSString stringWithFormat:@"%@ %@%@", NSLocalizedString(@"hd_account_cold_address_list_label", nil), typeString, balanceString];
    }
    NSMutableDictionary *infoDic = [NSMutableDictionary new];
    [infoDic setValue:address forKey:@"address"];
    TxNotificationType txNotificationType = -1;
    if ([array objectAtIndex:3] != [NSNull null]) {
        txNotificationType = [[array objectAtIndex:3] intValue];
        [infoDic setValue:[array objectAtIndex:3] forKey:@"TxNotificationType"];
    }
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    [infoDic setValue:[NSNumber numberWithBool:state == UIApplicationStateActive] forKey:ApplicationForeground];
    [infoDic setValue:[NSNumber numberWithLongLong:diff] forKey:@"diff"];
    DDLogDebug(@"notify:%@", infoDic);
    if (txNotificationType == txReceive || txNotificationType == txSend) {
        [self notification:msg dict:infoDic];
    }
}

+ (void)notification:(NSString *)msg dict:(NSDictionary *)dict {

    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if ([notification respondsToSelector:@selector(setCategory:)]) {
        notification.category = @"Transaction";
    }
    if (notification != nil) {
        notification.fireDate = [NSDate new];
        notification.repeatInterval = 0;

        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.soundName = @"coins_received.wav";
        notification.alertBody = msg;
        notification.hasAction = NO;
        notification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
        notification.userInfo = dict;

        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }

}


@end
