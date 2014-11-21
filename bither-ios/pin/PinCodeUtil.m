//
//  PinCodeUtil.m
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

#import "PinCodeUtil.h"
#import "AppDelegate.h"
#import "UserDefaultsUtil.h"
#import "IOS7ContainerViewController.h"

#define kCausePinCodeBackgroundTime (60)

@interface PinCodeUtil()
@property NSDate* backgroundDate;
@end

static PinCodeUtil* util;
@implementation PinCodeUtil

+(PinCodeUtil*)instance{
    if(!util){
        util = [[PinCodeUtil alloc]init];
    }
    return util;
}

-(instancetype)init{
    self = [super init];
    if(self){
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

-(void)becomeActive{
    if(!self.backgroundDate || [[NSDate new] timeIntervalSinceDate:self.backgroundDate] > kCausePinCodeBackgroundTime){
        if([[UserDefaultsUtil instance]hasPinCode]){
            UIViewController* rootVC = ((AppDelegate*)[UIApplication sharedApplication].delegate).window.rootViewController;
            if([rootVC isKindOfClass:[IOS7ContainerViewController class]]){
                rootVC = ((IOS7ContainerViewController*)rootVC).controller;
            }
            UIViewController* vc = rootVC;
            while (vc.presentedViewController) {
                vc = vc.presentedViewController;
            }
            [vc presentViewController:[rootVC.storyboard instantiateViewControllerWithIdentifier:@"PinCode"] animated:NO completion:nil];
        }
    }
}

-(void)resignActive{
    self.backgroundDate = [NSDate new];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
