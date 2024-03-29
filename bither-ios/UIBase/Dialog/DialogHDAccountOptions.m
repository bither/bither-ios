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
#import "DialogPrivateKeyText.h"
#import "BTWordsTypeManager.h"
#import "AddressDetailViewController.h"
#import "BTHDAccountProvider.h"
#import "AddressTypeUtil.h"

@interface DialogHDAccountOptions () <DialogPasswordDelegate> {
    SEL passwordSelector;
    BTHDAccount *hdAccount;
    UIWindow *_window;
}
@property(weak) NSObject <DialogHDAccountOptionsDelegate> *delegate;
@end

@implementation DialogHDAccountOptions

- (instancetype)initWithHDAccount:(BTHDAccount *)account andDelegate:(NSObject <DialogHDAccountOptionsDelegate> *)delegate {
    NSMutableArray *actions = [NSMutableArray new];
    if ([delegate isMemberOfClass:AddressDetailViewController.class]) {
        AddressDetailViewController *vc = (AddressDetailViewController *) delegate;
        BOOL isShowChangeAddressType = vc.isSegwit || [[BTHDAccountProvider instance] getSegwitExternalPub:(int) account.getHDAccountId] != nil;
        if (isShowChangeAddressType) {
            [actions addObject:[[Action alloc] initWithName:[AddressTypeUtil getAddressName:[AddressTypeUtil getSwitchAddressType:vc.isSegwit]] target:nil andSelector:@selector(changeAddressType)]];
        }
    }
    if (account.hasPrivKey) {
        [actions addObject:[[Action alloc] initWithName:NSLocalizedString(@"add_hd_account_seed_qr_phrase", nil) target:nil andSelector:@selector(phrasePressed)]];
    }
    if (delegate) {
        [actions addObject:[[Action alloc] initWithName:NSLocalizedString(@"hd_account_request_new_receiving_address", nil) target:nil andSelector:@selector(requestNewReceivingAddress)]];
        [actions addObject:[[Action alloc] initWithName:NSLocalizedString(@"hd_account_old_addresses", nil) target:nil andSelector:@selector(showOldAddresses)]];
    }
    if (account.hasPrivKey) {
        [actions addObject:[[Action alloc] initWithName:NSLocalizedString(@"hd_account_show_xpub", nil) target:nil andSelector:@selector(xPubPressed)]];
    }
    self = [super initWithActions:actions];
    if (self) {
        hdAccount = account;
        self.delegate = delegate;
    }
    return self;
}

- (void)dialogWillShow {
    [super dialogWillShow];
    passwordSelector = nil;
}

- (void)requestNewReceivingAddress {
    __block DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    __block BTHDAccount *account = hdAccount;
    __block NSObject <DialogHDAccountOptionsDelegate> *d = self.delegate;
    PathType pathType = EXTERNAL_ROOT_PATH;
    if ([self.delegate isMemberOfClass:AddressDetailViewController.class]) {
        AddressDetailViewController *vc = (AddressDetailViewController *) self.delegate;
        if (vc.isSegwit) {
            pathType = EXTERNAL_BIP49_PATH;
        }
    }
    [dp showInWindow:_window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            __block BOOL result = [account requestNewReceivingAddress:pathType];
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
    if (!self.delegate) {
        return;
    }
    PathType pathType;
    if ([self.delegate isMemberOfClass:AddressDetailViewController.class]) {
        pathType = ((AddressDetailViewController *) self.delegate).isSegwit ? EXTERNAL_BIP49_PATH : EXTERNAL_ROOT_PATH;
    } else {
        pathType = EXTERNAL_ROOT_PATH;
    }
    if ([hdAccount issuedExternalIndexForPathType:pathType] < 0) {
        [self.delegate showBannerWithMessage:NSLocalizedString(@"hd_account_old_addresses_zero", nil)];
    }
    [[[DialogOldAddressesOfHDAccount alloc] initWithAccount:hdAccount andDeleget:self.delegate] showInWindow:_window];
}

- (void)changeAddressType {
    if (!self.delegate) {
        return;
    }
    if ([self.delegate isMemberOfClass:AddressDetailViewController.class]) {
        AddressDetailViewController *vc = (AddressDetailViewController *) self.delegate;
        [vc setIsSegwit:!vc.isSegwit];
    }
}

- (void)phrasePressed {
    passwordSelector = @selector(showHDAccountPhrase:);
    [[[DialogPassword alloc] initWithDelegate:self] showInWindow:_window];
}

- (void)xPubPressed {
    passwordSelector = @selector(showXPub:);
    [[[DialogPassword alloc] initWithDelegate:self] showInWindow:_window];
}

- (void)showXPub:(NSString *) password{
    [[[DialogPrivateKeyText alloc] initWithPrivateKeyStr:[[hdAccount xPub:password] serializePubB58]] showInWindow:_window];
}

- (void)showInWindow:(UIWindow *)window completion:(void (^)())completion {
    _window = window;
    [super showInWindow:window completion:completion];
}

- (void)showHDAccountPhrase:(NSString*)password {
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

- (void)onPasswordEntered:(NSString *)password {
    if(passwordSelector){
        IMP imp = [self methodForSelector:passwordSelector];
        void (*func)(id, SEL, NSString *) = (void *)imp;
        func(self, passwordSelector, password);
    }
}
@end
