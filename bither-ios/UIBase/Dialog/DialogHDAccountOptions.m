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
#import "DialogOldAddressesOfHDAccount.h"
#import "UIViewController+PiShowBanner.h"

@interface DialogHDAccountOptions () <DialogPasswordDelegate> {
    BOOL qr;
    BTHDAccount *hdAccount;
    UIWindow *_window;
}
@property(weak) NSObject <DialogHDAccountOptionsDelegate> *delegate;
@end

@implementation DialogHDAccountOptions

- (instancetype)initWithHDAccount:(BTHDAccount *)account andDelegate:(NSObject <DialogHDAccountOptionsDelegate> *)delegate {
    NSMutableArray *actions = [NSMutableArray new];
    if (account.hasPrivKey) {
        [actions addObjectsFromArray:@[[[Action alloc] initWithName:NSLocalizedString(@"add_hd_account_seed_qr_code", nil) target:nil andSelector:@selector(qrPressed)],
                [[Action alloc] initWithName:NSLocalizedString(@"add_hd_account_seed_qr_phrase", nil) target:nil andSelector:@selector(phrasePressed)]]];
    }
    if (delegate) {
        [actions addObject:[[Action alloc] initWithName:NSLocalizedString(@"hd_account_request_new_receiving_address", nil) target:nil andSelector:@selector(requestNewReceivingAddress)]];
        [actions addObject:[[Action alloc] initWithName:NSLocalizedString(@"hd_account_old_addresses", nil) target:nil andSelector:@selector(showOldAddresses)]];
    }
    self = [super initWithActions:actions];
    if (self) {
        hdAccount = account;
        self.delegate = delegate;
    }
    return self;
}

- (void)requestNewReceivingAddress {
    __block DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    __block BTHDAccount *account = hdAccount;
    __block NSObject <DialogHDAccountOptionsDelegate> *d = self.delegate;
    [dp showInWindow:_window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            __block BOOL result = account.requestNewReceivingAddress;
            dispatch_async(dispatch_get_main_queue(), ^{
                [dp dismissWithCompletion:^{
                    if (result) {
                        [d refresh];
                    } else {
                        [d showBannerWithMessage:NSLocalizedString(@"hd_account_request_new_receiving_address_failed", nil)];
                    }
                }];
            });
        });
    }];
}

- (void)showOldAddresses {
    if (hdAccount.issuedExternalIndex < 0) {
        if (self.delegate) {
            [self.delegate showBannerWithMessage:NSLocalizedString(@"hd_account_old_addresses_zero", nil)];
        }
    }
    [[[DialogOldAddressesOfHDAccount alloc] initWithAccount:hdAccount andDeleget:self.delegate] showInWindow:_window];
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