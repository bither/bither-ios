//
//  TouchIdIntegration.m
//  bither-ios
//
//  Created by noname on 14-11-22.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "TouchIdIntegration.h"
@import LocalAuthentication;

#define kPinCodeKey @"PIN_CODE"

static TouchIdIntegration* touchId;
@implementation TouchIdIntegration

+(TouchIdIntegration*)instance{
    if(!touchId){
        touchId = [[TouchIdIntegration alloc]init];
    }
    return touchId;
}

-(BOOL)hasTouchId{
    LAContext *la = [[LAContext alloc]init];
    if([la respondsToSelector:@selector(canEvaluatePolicy:error:)]){
        return [la canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    }else{
        return NO;
    }
}

-(void)checkTouchId:(void (^)(BOOL success))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        LAContext *la = [[LAContext alloc]init];
        [la evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"pin_code_touch_id_promot", nil) reply:^(BOOL success, NSError *error) {
            if(completion){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(success);
                });
            }
        }];
    });
}

@end
