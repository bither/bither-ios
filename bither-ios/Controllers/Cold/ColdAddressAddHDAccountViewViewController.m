//
//  ColdAddressAddHDAccountViewViewController.m
//  bither-ios
//
//  Created by 宋辰文 on 15/7/15.
//  Copyright (c) 2015年 Bither. All rights reserved.
//

#import "ColdAddressAddHDAccountViewViewController.h"
#import <Bitheri/BTAddressManager.h>
#import "DialogPassword.h"
#import "DialogBlackQrCode.h"
#import "DialogProgress.h"
#import "DialogHDMSeedWordList.h"

@interface ColdAddressAddHDAccountViewViewController () <DialogPasswordDelegate> {
    BOOL qr;
}
@end

@implementation ColdAddressAddHDAccountViewViewController

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
        [[[DialogBlackQrCode alloc] initWithContent:[BTAddressManager instance].hdAccountCold.getQRCodeFullEncryptPrivKey andTitle:NSLocalizedString(@"add_hd_account_seed_qr_code", nil)] showInWindow:self.view.window];
    } else {
        __block DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
        dp.touchOutSideToDismiss = NO;
        [dp showInWindow:self.view.window completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                __block NSArray *words = [[BTAddressManager instance].hdAccountCold seedWords:password];
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
