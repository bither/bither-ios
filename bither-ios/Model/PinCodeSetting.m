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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"pin_code_setting_name", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if ([[UserDefaultsUtil instance] hasPinCode]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"pin_code_setting_close", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"pin_code_setting_change", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        actionSheet.cancelButtonIndex = 2;
    } else {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"pin_code_setting_open", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        actionSheet.cancelButtonIndex = 1;
    }
    [actionSheet showInView:self.controller.view.window];
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex < 0) {
        return;
    }
    UIViewController *vc;
    if ([[UserDefaultsUtil instance] hasPinCode]) {
        switch (buttonIndex) {
            case 0:
                vc = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"PinCodeDisable"];
                break;
            case 1:
                vc = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"PinCodeChange"];
                break;
            default:
                break;
        }
    } else {
        switch (buttonIndex) {
            case 0:
                vc = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"PinCodeEnable"];
                break;
            default:
                break;
        }
    }
    if (vc) {
        [self.controller.navigationController pushViewController:vc animated:YES];
    }
}

@end
