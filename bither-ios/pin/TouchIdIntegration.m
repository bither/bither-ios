//
//  TouchIdIntegration.m
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

#import "TouchIdIntegration.h"

@import LocalAuthentication;

#define kPinCodeKey @"PIN_CODE"

static TouchIdIntegration *touchId;

@implementation TouchIdIntegration

+ (TouchIdIntegration *)instance {
    if (!touchId) {
        touchId = [[TouchIdIntegration alloc] init];
    }
    return touchId;
}

- (BOOL)hasTouchId {
    LAContext *la = [[LAContext alloc] init];
    if ([la respondsToSelector:@selector(canEvaluatePolicy:error:)]) {
        return [la canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    } else {
        return NO;
    }
}

- (void)checkTouchId:(void (^)(BOOL success, BOOL denied))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        LAContext *la = [[LAContext alloc] init];
        [la evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"pin_code_touch_id_promot", nil) reply:^(BOOL success, NSError *error) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        completion(YES, NO);
                    } else {
                        completion(NO, error.code == LAErrorAuthenticationFailed);
                    }
                });
            }
        }];
    });
}

@end
