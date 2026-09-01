//
//  PinCodeSetting.m
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

#import "PinCodeSetting.h"
#import "UserDefaultsUtil.h"
#import "BitherActionSheet.h"

@interface PinCodeSetting () {

}
@property(weak) UIViewController *controller;
@end

static PinCodeSetting *S;

@implementation PinCodeSetting

+ (PinCodeSetting *)getPinCodeSetting {
    if (!S) {
        S = [[PinCodeSetting alloc] init];
    }
    return S;
}

- (instancetype)init {
    self = [super initWithName:NSLocalizedString(@"pin_code_setting_name", nil) icon:nil];
    if (self) {
        __weak PinCodeSetting *s = self;
        [self setSelectBlock:^(UIViewController *controller) {
            s.controller = controller;
            [s show];
        }];
    }
    return self;
}

- (void)show {
    BOOL hasPinCode = [[UserDefaultsUtil instance] hasPinCode];
    NSArray *titles = hasPinCode
        ? @[NSLocalizedString(@"pin_code_setting_close", nil), NSLocalizedString(@"pin_code_setting_change", nil)]
        : @[NSLocalizedString(@"pin_code_setting_open", nil)];
    BitherActionSheet *sheet = [[BitherActionSheet alloc] initWithTitle:NSLocalizedString(@"pin_code_setting_name", nil)
                                                           buttonTitles:titles
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                                 handler:^(NSInteger buttonIndex) {
        if (hasPinCode) {
            [self showPinCodeController:buttonIndex == 0 ? @"PinCodeDisable" : @"PinCodeChange"];
        } else if (buttonIndex == 0) {
            [self showPinCodeController:@"PinCodeEnable"];
        }
    }];
    [sheet showInViewController:self.controller];
}

- (void)showPinCodeController:(NSString *)identifier {
    UIViewController *vc = [self.controller.storyboard instantiateViewControllerWithIdentifier:identifier];
    [self.controller.navigationController pushViewController:vc animated:YES];
}

@end
