//
//  MonitorSetting.m
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
//  Created by songchenwen on 15/4/28.
//

#import <Bitheri/BTQRCodeUtil.h>
#import <Bitheri/BTKey.h>
#import <Bitheri/NSString+Base58.h>
#import <Bitheri/BTAddress.h>
#import <Bitheri/BTAddressManager.h>
#import "MonitorSetting.h"
#import "ScanQrCodeViewController.h"
#import "ScanQrCodeTransportViewController.h"
#import "DialogProgress.h"
#import "StringUtil.h"
#import "KeyUtil.h"

@interface MonitorSetting () <ScanQrCodeDelegate>
@property(weak) UIViewController *vc;

@end

static Setting *monitorSetting;

@implementation MonitorSetting

+ (MonitorSetting *)getMonitorSetting {
    if (!monitorSetting) {
        monitorSetting = [[MonitorSetting alloc] initWithName:NSLocalizedString(@"add_hd_account_monitor", nil) icon:[UIImage imageNamed:@"scan_button_icon"]];
    }
    return monitorSetting;
}

- (instancetype)initWithName:(NSString *)name icon:(UIImage *)icon {
    self = [super initWithName:name icon:icon];
    if (self) {
        [self configureSetting];
    }
    return self;
}

- (void)configureSetting {
    [self setSelectBlock:^(UIViewController *controller) {
        self.vc = controller;
        if ([BTAddressManager instance].watchOnlyAddresses.count >= WATCH_ONLY_COUNT_LIMIT) {
            [self showMsg:NSLocalizedString(@"watch_only_address_count_limit", nil)];
            return;
        }
        ScanQrCodeTransportViewController *scan = [[ScanQrCodeTransportViewController alloc] initWithDelegate:self title:NSLocalizedString(@"Scan to watch Bither Cold", nil) pageName:NSLocalizedString(@"Bither Cold Watch Only QR Code", nil)];
        [self.vc presentViewController:scan animated:YES completion:nil];
    }];
}

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
    [reader.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if ([self checkQrCodeContent:result]) {
            DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
            [dp showInWindow:self.vc.view.window completion:^{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [self processQrCodeContent:result dp:dp];
                });
            }];
        } else {
            if (result.isValidBitcoinAddress || [StringUtil isValidBitcoinBIP21Address:result]) {
                [self showMsg:NSLocalizedString(@"add_address_watch_only_scanned_address_warning", nil)];
            } else {
                [self showMsg:NSLocalizedString(@"Monitor Bither Cold failed.", nil)];
            }
        }
    }];
}

- (void)showMsg:(NSString *)msg {
    if (self.vc && [self.vc respondsToSelector:@selector(showMsg:)]) {
        [self.vc performSelector:@selector(showMsg:) withObject:msg];
    }
}

- (void)processQrCodeContent:(NSString *)content dp:(DialogProgress *)dp {
    NSArray *strs = [BTQRCodeUtil splitQRCode:content];
    NSMutableArray *addressList = [NSMutableArray new];
    NSMutableArray *addressStrList = [NSMutableArray new];
    for (NSString *temp in strs) {
        BOOL isXRandom = NO;
        NSString *pubStr = temp;
        if ([temp rangeOfString:XRANDOM_FLAG].location != NSNotFound) {
            pubStr = [temp substringFromIndex:1];
            isXRandom = YES;
        }
        BTKey *key = [BTKey keyWithPublicKey:[pubStr hexToData]];
        key.isFromXRandom = isXRandom;
        BTAddress *btAddress = [[BTAddress alloc] initWithKey:key encryptPrivKey:nil isXRandom:key.isFromXRandom];
        [addressList addObject:btAddress];
        [addressStrList addObject:key.address];
    }
    [KeyUtil addAddressList:addressList];
    dispatch_async(dispatch_get_main_queue(), ^{
        [dp dismissWithCompletion:^{
            [self showMsg:NSLocalizedString(@"add_hd_account_monitor_success", nil)];
            if (self.vc && [self.vc respondsToSelector:@selector(reload)]) {
                [self.vc performSelector:@selector(reload)];
            }
        }];
    });
}

- (BOOL)checkQrCodeContent:(NSString *)content {
    NSArray *strs = [BTQRCodeUtil splitQRCode:content];
    for (NSString *str in strs) {
        BOOL checkCompress = (str.length == 66) || (str.length == 67 && [str rangeOfString:XRANDOM_FLAG].location != NSNotFound);
        BOOL checkUncompress = (str.length == 130) || (str.length == 131 && [str rangeOfString:XRANDOM_FLAG].location != NSNotFound);
        if (!checkCompress && !checkUncompress) {
            return NO;
        }
    }
    return YES;
}

@end