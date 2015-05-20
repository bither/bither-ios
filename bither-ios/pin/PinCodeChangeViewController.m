//
//  PinCodeChangeViewController.m
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

#import "PinCodeChangeViewController.h"
#import "PinCodeEnterView.h"
#import "UIViewController+PiShowBanner.h"
#import "UserDefaultsUtil.h"

@interface PinCodeChangeViewController () <PinCodeEnterViewDelegate> {
    UserDefaultsUtil *d;
    NSString *firstPin;
    BOOL passedOld;
}

@property(weak, nonatomic) IBOutlet PinCodeEnterView *vEnter;
@property(weak, nonatomic) IBOutlet UIView *vTopBar;
@property(weak, nonatomic) IBOutlet UILabel *lblTitle;
@end

@implementation PinCodeChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    passedOld = NO;
    d = [UserDefaultsUtil instance];
    self.lblTitle.text = NSLocalizedString(@"pin_code_setting_change", nil);
    self.vEnter.delegate = self;
    self.vEnter.msg = NSLocalizedString(@"pin_code_setting_change_old_msg", nil);
    [self.vEnter becomeFirstResponder];
}

- (void)onEntered:(NSString *)code {
    if (!code || code.length == 0) {
        return;
    }
    if (!passedOld) {
        if ([d checkPinCode:code]) {
            passedOld = YES;
            [self.vEnter animateToNext];
            self.vEnter.msg = NSLocalizedString(@"pin_code_setting_change_new_msg", nil);
        } else {
            passedOld = NO;
            [self.vEnter shakeToClear];
            [self showMsg:NSLocalizedString(@"pin_code_setting_change_old_wrong", nil)];
        }
        return;
    }
    if (!firstPin) {
        firstPin = code;
        [self.vEnter animateToNext];
        self.vEnter.msg = NSLocalizedString(@"pin_code_setting_change_new_repeat_msg", nil);
    } else {
        if ([StringUtil compareString:firstPin compare:code]) {
            [d setPinCode:code];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self showMsg:NSLocalizedString(@"pin_code_setting_change_repeat_wrong", nil)];
            self.vEnter.msg = NSLocalizedString(@"pin_code_setting_change_new_msg", nil);
            [self.vEnter shakeToClear];
            firstPin = nil;
        }
    }
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showMsg:(NSString *)msg {
    [self showBannerWithMessage:msg belowView:self.vTopBar];
}

@end
