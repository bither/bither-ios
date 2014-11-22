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
#import "PinCodeViewController.h"
#import "IOS7ContainerViewController.h"
#import "FXBlurView/FXBlurView.h"

#define kCausePinCodeBackgroundTime (10)

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
    [FXBlurView setUpdatesDisabled];
    __block __weak UIViewController* vc = self.topVC;
    [self removeBlur:vc];
    if([[UserDefaultsUtil instance]hasPinCode]){
        if(!self.backgroundDate || [[NSDate new] timeIntervalSinceDate:self.backgroundDate] > kCausePinCodeBackgroundTime){
            if(![vc isKindOfClass:[PinCodeViewController class]]){
                [self addBlur];
                [vc presentViewController:[self.rootVC.storyboard instantiateViewControllerWithIdentifier:@"PinCode"] animated:NO completion:^{
                    [self removeBlur:vc];
                }];
            }
        }
    }
}

-(void)resignActive{
    if(![self.topVC isKindOfClass:[PinCodeViewController class]]){
        if([UserDefaultsUtil instance].hasPinCode){
            [self addBlur];
        }
        self.backgroundDate = [NSDate new];
    }
}

-(void)addBlur{
    UIView* v = self.topVC.view;
    if(![v.subviews[v.subviews.count - 1] isKindOfClass:[FXBlurView class]]){
        FXBlurView* blur = [[FXBlurView alloc]initWithFrame:CGRectMake(0, 0, v.frame.size.width, v.frame.size.height)];
        blur.underlyingView = v;
        blur.dynamic = NO;
        blur.blurRadius = 20;
        blur.tintColor = [UIColor clearColor];
        [blur setNeedsDisplay];
        [v addSubview:blur];
    }
}

-(void)removeBlur:(UIViewController*)vc{
    if(!vc){
        return;
    }
    UIView* v = vc.view;
    NSUInteger subViewCount = v.subviews.count;
    NSMutableArray *viewsToRemove = [NSMutableArray new];
    for(NSInteger i = subViewCount - 1; i >= 0; i--){
        UIView* subView = v.subviews[i];
        if([subView isKindOfClass:[FXBlurView class]]){
            [viewsToRemove addObject:subView];
        }else{
            break;
        }
    }
    for(UIView* v in viewsToRemove){
        [v removeFromSuperview];
    }
}

-(UIViewController*)rootVC{
    UIViewController* rootVC = ((AppDelegate*)[UIApplication sharedApplication].delegate).window.rootViewController;
    if([rootVC isKindOfClass:[IOS7ContainerViewController class]]){
        rootVC = ((IOS7ContainerViewController*)rootVC).controller;
    }
    return rootVC;
}

-(UIViewController*)topVC{
    UIViewController* vc = [self rootVC];
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    return vc;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
