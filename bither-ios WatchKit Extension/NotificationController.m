//
//  NotificationController.m
//  bither-ios WatchKit Extension
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
//  Created by songchenwen on 2015/2/25.
//

#import "NotificationController.h"
#import "WatchStringUtil.h"
#import "WatchUnitUtil.h"

@interface NotificationController ()
@property(weak, nonatomic) IBOutlet WKInterfaceLabel *lblAddress;
@property(weak, nonatomic) IBOutlet WKInterfaceLabel *lblAmount;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *ivSymbol;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lblSign;
@end

@implementation NotificationController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.lblAmount setHidden:YES];
        [self.lblAddress setHidden:YES];
    }
    return self;
}

- (void)willActivate {
    [super willActivate];
}

- (void)didDeactivate {
    [super didDeactivate];
}

- (void)didReceiveLocalNotification:(UILocalNotification *)localNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    if ([self processNotification:localNotification.userInfo]) {
        completionHandler(WKUserNotificationInterfaceTypeCustom);
    } else {
        completionHandler(WKUserNotificationInterfaceTypeDefault);
    }
}

- (void)didReceiveRemoteNotification:(NSDictionary *)remoteNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    if ([self processNotification:remoteNotification]) {
        completionHandler(WKUserNotificationInterfaceTypeCustom);
    } else {
        completionHandler(WKUserNotificationInterfaceTypeDefault);
    }
}

- (BOOL)processNotification:(NSDictionary *)notice {
    NSString *address = [notice objectForKey:@"address"];
    if (!address) {
        return NO;
    }
    long long diff = ((NSNumber *) [notice objectForKey:@"diff"]).longLongValue;
    if ([address isEqualToString:@"HDAccount"]) {
        [self.lblAddress setText:NSLocalizedString(@"address_group_hd", nil)];
    } else {
        [self.lblAddress setText:[WatchStringUtil formatAddress:address groupSize:4 lineSize:12]];
    }
    if (diff >= 0) {
        [self.lblAmount setText:[WatchUnitUtil stringForAmount:diff]];
        [self.lblAmount setTextColor:[UIColor greenColor]];
        [self.lblSign setText:@"+"];
        [self.lblSign setTextColor:[UIColor greenColor]];
        [self.ivSymbol setImageNamed:[WatchUnitUtil imageNameOfGreenSymbol]];
    } else {
        [self.lblAmount setText:[WatchUnitUtil stringForAmount:-diff]];
        [self.lblAmount setTextColor:[UIColor redColor]];
        [self.lblSign setText:@"-"];
        [self.lblSign setTextColor:[UIColor redColor]];
        [self.ivSymbol setImageNamed:[WatchUnitUtil imageNameOfRedSymbol]];
        
    }
    [self.lblAmount setHidden:NO];
    [self.lblAddress setHidden:NO];
    return YES;
}

@end



