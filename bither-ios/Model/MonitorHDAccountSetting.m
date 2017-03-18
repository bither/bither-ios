//
//  MonitorHDAccountSetting.m
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
//  Created by songchenwen on 15/7/16.
//

#import <Bitheri/BTAddressManager.h>
#import "MonitorHDAccountSetting.h"
#import "ScanQrCodeViewController.h"
#import "ScanQrCodeTransportViewController.h"
#import "DialogProgress.h"
#import "StringUtil.h"
#import "BTQRCodeUtil.h"
#import "PeerUtil.h"
#import "AppDelegate.h"
#import "DialogWithActions.h"
#import "DialogCentered.h"
#import "DialogHDMonitorFirstAddressValidation.h"
#import <Bitheri/BTQRCodeUtil.h>
#import "BTHDAccount.h"

@interface MonitorHDAccountSetting () <ScanQrCodeDelegate>
@property(weak) UIViewController *vc;
@property (nonatomic,strong) NSString *senderResult;
@property BTBIP32Key* xpub;
@end

static MonitorHDAccountSetting *monitorSetting;

@implementation MonitorHDAccountSetting


+ (MonitorHDAccountSetting *)getMonitorHDAccountSetting {
    if (!monitorSetting) {
        monitorSetting = [[MonitorHDAccountSetting alloc] initWithName:NSLocalizedString(@"monitor_cold_hd_account", nil) icon:[UIImage imageNamed:@"scan_button_icon"]];
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
    __weak typeof(self) weakSelf = self;
    [self setSelectBlock:^(UIViewController *controller) {
        weakSelf.vc = controller;
        if ([BTAddressManager instance].hasHDAccountMonitored) {
            [weakSelf showMsg:NSLocalizedString(@"monitor_cold_hd_account_limit", nil)];
            return;
        }
        ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc] initWithDelegate:weakSelf title:nil message:nil];
        [weakSelf.vc presentViewController:scan animated:YES completion:nil];
    }];
}
#pragma mark - import HDAccount
- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
    _senderResult = result;
    [reader.presentingViewController dismissViewControllerAnimated:YES completion:^{
        DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
        [dp showInWindow:self.vc.view.window completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self processQrCodeContent:_senderResult dp:dp];
            });
        }];
    }];
}
- (void)showMsg:(NSString *)msg {
    if (self.vc && [self.vc respondsToSelector:@selector(showMsg:)]) {
        [self.vc performSelector:@selector(showMsg:) withObject:msg];
    }
}

- (void)processQrCodeContent:(NSString *)content dp:(DialogProgress *)dp {
    if(![content hasPrefix:HD_MONITOR_QR_PREFIX]){
        BOOL isXRandom = [content characterAtIndex:0] == [XRANDOM_FLAG characterAtIndex:0];
        NSData *bytes = isXRandom ? [content substringFromIndex:1].hexToData : content.hexToData;
        if(bytes.length != 65){
            dispatch_async(dispatch_get_main_queue(), ^{
                [dp dismissWithCompletion:^{
                    [self showMsg:NSLocalizedString(@"monitor_cold_hd_account_failed_wrong_qr_code", nil)];
                }];
            });
            return;
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [dp dismissWithCompletion:^{
                    [self showMsg:NSLocalizedString(@"hd_account_monitor_xpub_need_to_upgrade", nil)];
                }];
            });
            return;
        }
        return;
    }
    content = [content substringFromIndex:HD_MONITOR_QR_PREFIX.length];
    BTBIP32Key* key = [BTBIP32Key deserializeFromB58:content];
    if (key == nil){
        dispatch_async(dispatch_get_main_queue(), ^{
            [dp dismissWithCompletion:^{
                [self showMsg:NSLocalizedString(@"monitor_cold_hd_account_failed_wrong_qr_code", nil)];
            }];
        });
    }
    self.xpub = key;
    __block NSString* firstAddress = [[key deriveSoftened:EXTERNAL_ROOT_PATH] deriveSoftened:0].address;
    
    if ([self isRepeatHD:firstAddress]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [dp dismissWithCompletion:^{
                [self showMsg:NSLocalizedString(@"monitor_cold_hd_account_failed_duplicated", nil)];
            }];
        });
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [dp dismissWithCompletion:^{
            [[[DialogHDMonitorFirstAddressValidation alloc]initWithAddress:firstAddress target:self okSelector:@selector(accountValidatedSuccess) cancelSelector:nil] showInWindow:self.vc.view.window];
        }];
    });
}

- (BOOL)isRepeatHD:(NSString *)firstAddress {
    BTHDAccount *hdAccountHot = [[BTAddressManager instance] hdAccountHot];
    if (hdAccountHot == nil) {
        return false;
    }
    BTHDAccountAddress *addressHot = [hdAccountHot addressForPath:EXTERNAL_ROOT_PATH atIndex:0];
    if ([firstAddress isEqualToString:addressHot.address]) {
        return true;
    }
    return false;
}

-(void)accountValidatedSuccess {
    DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    [dp showInWindow:self.vc.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [[PeerUtil instance] stopPeer];
            [BTAddressManager instance].hdAccountMonitored = [[BTHDAccount alloc] initWithAccountExtendedPub:self.xpub.getPubKeyExtended fromXRandom:NO syncedComplete:NO andGenerationCallback:nil];
            [[PeerUtil instance] startPeer];
            dispatch_async(dispatch_get_main_queue(), ^{
                [dp dismissWithCompletion:^{
                    [self showMsg:NSLocalizedString(@"monitor_cold_hd_account_success", nil)];
                    
                    if (self.vc && [self.vc respondsToSelector:@selector(reload)]) {
                        [self.vc performSelector:@selector(reload)];
                    }
                }];
            });
        });
    }];
}

@end
