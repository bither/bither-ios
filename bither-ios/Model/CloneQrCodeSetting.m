//
//  CloneQrCodeSetting.m
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


#import "CloneQrCodeSetting.h"
#import "QrCodeViewController.h"
#import "BTAddress.h"
#import "BTAddressManager.h"
#import "BTQRCodeUtil.h"

@implementation CloneQrCodeSetting

- (instancetype)init {
    self = [super initWithName:NSLocalizedString(@"Cold Wallet Clone QR Code", nil) icon:[UIImage imageNamed:@"qr_code_button_icon"]];
    if (self) {
        __weak CloneQrCodeSetting *d = self;
        [self setSelectBlock:^(UIViewController *controller) {
            d.controller = controller;
            [[[DialogPassword alloc] initWithDelegate:d] showInWindow:controller.view.window];
        }];
    }
    return self;
}

- (void)onPasswordEntered:(NSString *)password {
    NSArray *addresses = [BTAddressManager instance].privKeyAddresses;
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    for (BTAddress *a in addresses) {
        [keys addObject:[BTQRCodeUtil replaceNewQRCode:a.fullEncryptPrivKey]];
    }
    if ([[BTAddressManager instance] hasHDMKeychain]) {
        BTHDMKeychain *keychain = [[BTAddressManager instance] hdmKeychain];
        [keys addObject:[keychain getFullEncryptPrivKeyWithHDMFlag]];
    }
    if ([BTAddressManager instance].hasHDAccountCold){
        [keys addObject:[BTAddressManager instance].hdAccountCold.getQRCodeFullEncryptPrivKey];
    }
    QrCodeViewController *qrController = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"QrCode"];
    qrController.content = [BTQRCodeUtil joinedQRCode:keys];
    qrController.qrCodeTitle = NSLocalizedString(@"Cold Wallet Clone QR Code", nil);
    qrController.qrCodeMsg = NSLocalizedString(@"Scan by clone destination", nil);
    [self.controller.navigationController pushViewController:qrController animated:YES];
}

@end

