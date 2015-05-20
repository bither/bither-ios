//
//  PinCodeViewController.m
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

#import "PinCodeViewController.h"
#import "PinCodeEnterView.h"
#import "UIViewController+PiShowBanner.h"
#import "UIViewController+SwipeRightToPop.h"
#import "UserDefaultsUtil.h"
#import "TouchIdIntegration.h"

@interface PinCodeViewController () <PinCodeEnterViewDelegate> {
    UserDefaultsUtil *d;
    TouchIdIntegration *touchId;
    BOOL giveUpTouchId;
}

@property(weak, nonatomic) IBOutlet PinCodeEnterView *vEnter;
@end

@implementation PinCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    d = [UserDefaultsUtil instance];
    self.shouldSwipeRightToPop = NO;
    self.vEnter.delegate = self;
    self.vEnter.msg = NSLocalizedString(@"pin_code_enter_notice", nil);
    touchId = [TouchIdIntegration instance];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.vEnter becomeFirstResponder];
    [self invokeTouchId];
}

- (void)invokeTouchId {
    if (touchId.hasTouchId) {
        giveUpTouchId = NO;
        [touchId checkTouchId:^(BOOL success, BOOL denied) {
            if (success) {
                [self.vEnter resignFirstResponder];
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                if (denied) {
                    [self.vEnter shakeToClear];
                }
                giveUpTouchId = YES;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
            }
        }];
    }
}

- (void)onEntered:(NSString *)code {
    if ([d checkPinCode:code]) {
        [self.vEnter resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.vEnter shakeToClear];
    }
}

- (void)showMsg:(NSString *)msg {
    [self showBannerWithMessage:msg belowView:nil belowTop:0 autoHideIn:1 withCompletion:nil];
}

- (void)becomeActive {
    if (giveUpTouchId) {
        giveUpTouchId = NO;
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self invokeTouchId];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
