//
//  HotAddressAddWatchOnlyViewController.m
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

#import "HotAddressAddWatchOnlyViewController.h"
#import "HotAddressAddViewController.h"
#import <Bitheri/BTAddressManager.h>
#import "ScanQrCodeTransportViewController.h"
#import "DialogProgress.h"
#import "KeyUtil.h"
#import "BTQRCodeUtil.h"
#import "StringUtil.h"

@interface HotAddressAddWatchOnlyViewController () <ScanQrCodeDelegate>

@end

@implementation HotAddressAddWatchOnlyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)scanPressed:(id)sender {
    ScanQrCodeTransportViewController *scan = [[ScanQrCodeTransportViewController alloc] initWithDelegate:self title:NSLocalizedString(@"Scan to watch Bither Cold", nil) pageName:NSLocalizedString(@"Bither Cold Watch Only QR Code", nil)];
    [self presentViewController:scan animated:YES completion:nil];
}

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
    [reader.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if ([self checkQrCodeContent:result]) {
            DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
            [dp showInWindow:self.view.window completion:^{
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
    if (self.parentViewController.parentViewController && [self.parentViewController.parentViewController isKindOfClass:[HotAddressAddViewController class]]) {
        HotAddressAddViewController *parent = (HotAddressAddViewController *) self.parentViewController.parentViewController;
        [parent showMessage:msg];
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
        if (!key.publicKey) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [dp dismissWithCompletion:^{
                    [self showMsg:NSLocalizedString(@"Monitor Bither Cold failed.", nil)];
                }];
            });
            return;
        }
        BTAddress *btAddress = [[BTAddress alloc] initWithKey:key encryptPrivKey:nil isSyncComplete:NO isXRandom:key.isFromXRandom];
        [addressList addObject:btAddress];
        [addressStrList addObject:key.address];
    }
    [KeyUtil addAddressList:addressList];
    dispatch_async(dispatch_get_main_queue(), ^{
        [dp dismissWithCompletion:^{
            [self dismissViewControllerAnimated:YES completion:^{
            }];
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
