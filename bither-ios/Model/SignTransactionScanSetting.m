//
//  SignTransactionScanDelegate.m
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

#import "SignTransactionScanSetting.h"
#import "ScanQrCodeTransportViewController.h"
#import "QRCodeTxTransport.h"
#import "SignTransactionViewController.h"

static Setting *SignTransactionSetting;

@implementation SignTransactionScanSetting

+ (Setting *)getSignTransactionSetting {
    if (!SignTransactionSetting) {
        SignTransactionScanSetting *setting = [[SignTransactionScanSetting alloc] init];
        SignTransactionSetting = setting;
    }
    return SignTransactionSetting;
}

- (instancetype)init {
    self = [super initWithName:NSLocalizedString(@"Sign Transaction", nil) icon:[UIImage imageNamed:@"scan_button_icon"]];
    if (self) {
        __weak SignTransactionScanSetting *d = self;
        [self setSelectBlock:^(UIViewController *controller) {
            d.controller = controller;
            ScanQrCodeTransportViewController *scan = [[ScanQrCodeTransportViewController alloc] initWithDelegate:d title:NSLocalizedString(@"Scan Unsigned TX", nil) pageName:NSLocalizedString(@"unsigned tx QR code", nil)];
            [controller presentViewController:scan animated:YES completion:nil];
        }];
    }
    return self;
}

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
    QRCodeTxTransport *tx = [QRCodeTxTransport formatQRCodeTransport:result];
    if (tx) {
        SignTransactionViewController *signController = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"SignTransaction"];
        signController.tx = tx;
        [self.controller.navigationController pushViewController:signController animated:NO];
    }
    [reader.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if (!tx) {
            if ([self.controller respondsToSelector:@selector(showMsg:)]) {
                [self.controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"Scan unsigned transaction failed", nil)];
            }
        }
    }];
}

@end
