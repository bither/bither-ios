//
//  DialogHDAccountOptions.m
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
//
//  Created by songchenwen on 15/4/27.
//

#import <Bitheri/BTHDAccount.h>
#import "DialogHDAccountOptions.h"
#import "DialogPassword.h"
#import "DialogBlackQrCode.h"
#import "DialogProgress.h"
#import "DialogHDMSeedWordList.h"

@interface DialogHDAccountOptions () <DialogPasswordDelegate> {
    BOOL qr;
    BTHDAccount *hdAccount;
    UIWindow *_window;
}
@end

@implementation DialogHDAccountOptions

- (instancetype)initWithHDAccount:(BTHDAccount *)account {
    self = [super initWithActions:@[[[Action alloc] initWithName:NSLocalizedString(@"add_hd_account_seed_qr_code", nil) target:nil andSelector:@selector(qrPressed)],
            [[Action alloc] initWithName:NSLocalizedString(@"add_hd_account_seed_qr_phrase", nil) target:nil andSelector:@selector(phrasePressed)]]];
    if (self) {
        hdAccount = account;
    }
    return self;
}

- (void)qrPressed {
    qr = YES;
    [[[DialogPassword alloc] initWithDelegate:self] showInWindow:_window];
}

- (void)phrasePressed {
    qr = NO;
    [[[DialogPassword alloc] initWithDelegate:self] showInWindow:_window];
}

- (void)showInWindow:(UIWindow *)window completion:(void (^)())completion {
    _window = window;
    [super showInWindow:window completion:completion];
}

- (void)onPasswordEntered:(NSString *)password {
    if (qr) {
        [[[DialogBlackQrCode alloc] initWithContent:hdAccount.getQRCodeFullEncryptPrivKey andTitle:NSLocalizedString(@"add_hd_account_seed_qr_code", nil)] showInWindow:_window];
    } else {
        __block DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
        dp.touchOutSideToDismiss = NO;
        [dp showInWindow:_window completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                __block NSArray *words = [hdAccount seedWords:password];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dp dismissWithCompletion:^{
                        [[[DialogHDMSeedWordList alloc] initWithWords:words] showInWindow:_window];
                    }];
                });
            });
        }];
    }
}
@end