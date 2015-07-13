//
//  HotAddressAddHDAccountViewViewController.m
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
//  Created by songchenwen on 2015/4/27.
//

#import <Bitheri/BTAddressManager.h>
#import "HotAddressAddHDAccountViewViewController.h"
#import "DialogPassword.h"
#import "DialogBlackQrCode.h"
#import "DialogProgress.h"
#import "DialogHDMSeedWordList.h"

@interface HotAddressAddHDAccountViewViewController () <DialogPasswordDelegate> {
    BOOL qr;
}

@end

@implementation HotAddressAddHDAccountViewViewController

- (IBAction)qrPressed:(id)sender {
    qr = YES;
    [[[DialogPassword alloc] initWithDelegate:self] showInWindow:self.view.window];
}

- (IBAction)phrasePressed:(id)sender {
    qr = NO;
    [[[DialogPassword alloc] initWithDelegate:self] showInWindow:self.view.window];
}

- (void)onPasswordEntered:(NSString *)password {
    if (qr) {
        [[[DialogBlackQrCode alloc] initWithContent:[BTAddressManager instance].hdAccountHot.getQRCodeFullEncryptPrivKey andTitle:NSLocalizedString(@"add_hd_account_seed_qr_code", nil)] showInWindow:self.view.window];
    } else {
        __block DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
        dp.touchOutSideToDismiss = NO;
        [dp showInWindow:self.view.window completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                __block NSArray *words = [[BTAddressManager instance].hdAccountHot seedWords:password];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dp dismissWithCompletion:^{
                        [[[DialogHDMSeedWordList alloc] initWithWords:words] showInWindow:self.view.window];
                    }];
                });
            });
        }];
    }
}
@end