//
//  PinCodeEnableViewController.m
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

#import "PinCodeEnableViewController.h"
#import "PinCodeEnterView.h"
#import "UIViewController+PiShowBanner.h"
#import "UserDefaultsUtil.h"

@interface PinCodeEnableViewController () <PinCodeEnterViewDelegate> {
    UserDefaultsUtil *d;
    NSString *firstPin;
}

@property(weak, nonatomic) IBOutlet PinCodeEnterView *vEnter;
@property(weak, nonatomic) IBOutlet UIView *vTopBar;
@property(weak, nonatomic) IBOutlet UILabel *lblTitle;
@end

@implementation PinCodeEnableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    d = [UserDefaultsUtil instance];
    self.lblTitle.text = NSLocalizedString(@"pin_code_setting_open", nil);
    self.vEnter.delegate = self;
    self.vEnter.msg = NSLocalizedString(@"pin_code_setting_open_msg", nil);
    [self.vEnter becomeFirstResponder];
}

- (void)onEntered:(NSString *)code {
    if (!code || code.length == 0) {
        return;
    }
    if (!firstPin) {
        firstPin = code;
        [self.vEnter animateToNext];
        self.vEnter.msg = NSLocalizedString(@"pin_code_setting_open_repeat_msg", nil);
    } else {
        if ([StringUtil compareString:firstPin compare:code]) {
            [d setPinCode:code];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self showMsg:NSLocalizedString(@"pin_code_setting_open_repeat_wrong", nil)];
            self.vEnter.msg = NSLocalizedString(@"pin_code_setting_open_msg", nil);
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
