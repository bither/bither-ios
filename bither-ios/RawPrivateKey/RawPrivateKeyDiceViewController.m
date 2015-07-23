//
//  RawPrivateKeyDiceViewController.m
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
//  Created by songchenwen on 2015/3/21.
//

#import <Bitheri/BTPrivateKeyUtil.h>
#import "RawPrivateKeyDiceViewController.h"
#import "RawDataDiceView.h"
#import "DialogPassword.h"
#import "StringUtil.h"
#import "DialogProgress.h"
#import "NSString+Base58.h"
#import "NSData+Hash.h"
#import "UIViewController+PiShowBanner.h"
#import "BTAddress.h"
#import "KeyUtil.h"

@interface RawPrivateKeyDiceViewController () <DialogPasswordDelegate>
@property(weak, nonatomic) IBOutlet RawDataDiceView *vData;
@property(weak, nonatomic) IBOutlet UIView *vInput;
@property(weak, nonatomic) IBOutlet UIView *vButtons;

@property(weak, nonatomic) IBOutlet UIView *vShow;
@property(weak, nonatomic) IBOutlet UILabel *lblPrivateKey;
@property(weak, nonatomic) IBOutlet UILabel *lblAddress;
@property(weak, nonatomic) IBOutlet UIButton *btnAdd;

@end

@implementation RawPrivateKeyDiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat maxSize = MIN(self.vInput.frame.size.width, self.vInput.frame.size.height - 174) - 10;
    self.vData.restrictedSize = CGSizeMake(maxSize, maxSize);
    self.vData.dataSize = CGSizeMake(10, 10);
    CGRect frame = self.vButtons.frame;
    frame.size.height = self.vInput.frame.size.height - CGRectGetMaxY(self.vData.frame);
    frame.origin.y = CGRectGetMaxY(self.vData.frame);
    self.vButtons.frame = frame;

    frame = self.btnAdd.frame;
    frame.size.width = [self.btnAdd sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width + 30;
    frame.origin.x -= (frame.size.width - self.btnAdd.frame.size.width) / 2;
    self.btnAdd.frame = frame;
}

- (void)handleData {
    DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    __weak __block DialogProgress *dpB = dp;
    [dp showInWindow:self.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSMutableData *data = self.vData.data;
            if (!data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dpB dismiss];
                });
                return;
            }
            if (![self checkData:data]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dpB dismissWithCompletion:^{
                        [self showBannerWithMessage:NSLocalizedString(@"raw_private_key_not_safe", nil) belowView:nil withCompletion:^{
                            self.vData.dataSize = CGSizeMake(16, 16);
                        }];
                    }];
                });
                return;
            }
            BTKey *key = [[BTKey alloc] initWithSecret:data compressed:YES];
            NSString *privateKey = key.privateKey;
            NSString *address = key.address;
            dispatch_async(dispatch_get_main_queue(), ^{
                [dpB dismiss];
                self.lblPrivateKey.text = [StringUtil formatAddress:privateKey groupSize:4 lineSize:16];
                self.lblAddress.text = [StringUtil formatAddress:address groupSize:4 lineSize:12];
                self.vShow.hidden = NO;
                self.vInput.hidden = YES;
            });
        });
    }];
}

- (IBAction)dicePressed:(UIButton *)sender {
    if (self.vData.filledDataLength < self.vData.dataLength) {
        [self.vData addData:sender.tag];
        if (self.vData.filledDataLength >= self.vData.dataLength) {
            [self performSelector:@selector(handleData) withObject:nil afterDelay:0.5];
        }
    }
}

- (IBAction)deletePressed:(id)sender {
    [self.vData deleteLast];
}

- (IBAction)clearPressed:(id)sender {
    [self.vData removeAllData];
}

- (IBAction)addPressed:(id)sender {
    [[[DialogPassword alloc] initWithDelegate:self] showInWindow:self.view.window];
}

- (void)onPasswordEntered:(NSString *)password {
    DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    __weak __block DialogProgress *dpB = dp;
    __weak __block UIViewController *vc = self;
    [dp showInWindow:self.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSMutableData *data = self.vData.data;
            if (!data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dpB dismiss];
                });
                return;
            }
            BTKey *key = [[BTKey alloc] initWithSecret:data compressed:YES];
            NSString *privateKeyString = [BTPrivateKeyUtil getPrivateKeyString:key passphrase:password];
            BTAddress *address = [[BTAddress alloc] initWithKey:key encryptPrivKey:privateKeyString isSyncComplete:NO isXRandom:NO];
            [KeyUtil addAddressList:@[address]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [dpB dismissWithCompletion:^{
                    [vc.navigationController popViewControllerAnimated:YES];
                }];
            });
        });
    }];
}

- (BOOL)checkData:(NSData *)data {
    if ([data compare:[@"0" hexToData]] == 0) {
        return NO;
    }
    return YES;
}

@end
