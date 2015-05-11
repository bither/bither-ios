//
//  AddHDMAddressViewController.m
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
//  Created by songchenwen on 15/2/4.
//

#import <Bitheri/BTAddressManager.h>
#import "AddHDMAddressViewController.h"
#import "DialogPassword.h"
#import "UIViewController+PiShowBanner.h"
#import "BitherSetting.h"
#import "PasswordGetter.h"
#import "DialogProgress.h"
#import "DialogAlert.h"
#import "ScanQrCodeViewController.h"
#import "PeerUtil.h"
#import "NSError+HDMHttpErrorMessage.h"
#import "BTHDMBid+Api.h"

@interface AddHDMAddressViewController () <PasswordGetterDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ScanQrCodeDelegate> {
    PasswordGetter *_passwordGetter;
    DialogProgress *dp;
    BTHDMKeychain *keychain;
}
@property(weak, nonatomic) IBOutlet UIView *vTopbar;
@property(weak, nonatomic) IBOutlet UIPickerView *pvCount;
@property NSUInteger countToGenerate;
@property NSUInteger limit;
@property(readonly) PasswordGetter *passwordGetter;
@end

@implementation AddHDMAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.limit = HDM_ADDRESS_PER_SEED_COUNT_LIMIT;
    self.pvCount.delegate = self;
    self.pvCount.dataSource = self;
    dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    keychain = [BTAddressManager instance].hdmKeychain;
    self.countToGenerate = 1;
}

- (IBAction)generatePressed:(id)sender {
    NSUInteger count = self.countToGenerate;
    if (keychain.uncompletedAddressCount < count) {
        [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"hdm_address_add_need_cold_pub", nil) confirm:^{
            ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc] initWithDelegate:self];
            [self presentViewController:scan animated:YES completion:nil];
        }                              cancel:nil] showInWindow:self.view.window];
        return;
    }
    [self performAdd:count];
}

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
    [self dismissViewControllerAnimated:YES completion:^{
        NSData *pub = [result hexToData];
        if (!pub) {
            [self showMsg:NSLocalizedString(@"hdm_address_add_need_cold_pub", nil)];
            return;
        }
        NSUInteger count = MIN(HDM_ADDRESS_PER_SEED_COUNT_LIMIT - keychain.allCompletedAddresses.count - keychain.uncompletedAddressCount, HDM_ADDRESS_PER_SEED_PREPARE_COUNT);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString *password = self.passwordGetter.password;
            if (!password) {
                return;
            }
            @try {
                NSUInteger prepared = [keychain prepareAddressesWithCount:count password:password andColdExternalPub:pub];
                NSLog(@"HDM try to complete %d, completed %d", count, prepared);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performAdd:self.countToGenerate];
                });
            } @catch (BTHDMColdPubNotSameException *notSame) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showMsg:NSLocalizedString(@"hdm_address_add_cold_pub_not_match", nil)];
                });
            } @catch (NSException *e) {
                NSLog(@"prepare hdm address error: %@", e);
            }
        });
    }];
}

- (void)performAdd:(NSUInteger)count {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *password = self.passwordGetter.password;
        if (!password) {
            return;
        }
        [[PeerUtil instance] stopPeer];
        __block NSError *error;

        NSArray *as = [keychain completeAddressesWithCount:count password:password andFetchBlock:^(NSString *p, NSArray *partialPubs) {
            BTHDMBid *hdmBid = [BTHDMBid getHDMBidFromDb];
            [hdmBid createHDMAddress:partialPubs andPassword:p andError:&error];
        }];
        [[PeerUtil instance] stopPeer];
        dispatch_async(dispatch_get_main_queue(), ^{
            [dp dismissWithCompletion:^{
                if (error) {
                    if (error && error.isHttp400) {
                        [self showMsg:error.msg];
                    } else {
                        [self showMsg:NSLocalizedString(@"Network failure.", nil)];
                    }
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        });
    });
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.limit - [BTAddressManager instance].hdmKeychain.allCompletedAddresses.count;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.countToGenerate = (NSUInteger) (row + 1);
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%ld", (long) (row + 1)];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void)showMsg:(NSString *)msg {
    [self showBannerWithMessage:msg belowView:self.vTopbar];
}

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (PasswordGetter *)passwordGetter {
    if (!_passwordGetter) {
        _passwordGetter = [[PasswordGetter alloc] initWithWindow:self.view.window andDelegate:self];
    }
    return _passwordGetter;
}

- (void)beforePasswordDialogShow {
    if (dp.shown) {
        [dp dismiss];
    }
}

- (void)afterPasswordDialogDismiss {
    if (!dp.shown) {
        [dp showInWindow:self.view.window];
    }
}
@end