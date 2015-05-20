//
//  PaymentInterfaceController.m
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
//  Created by songchenwen on 2015/05/08
//

#import "PaymentInterfaceController.h"
#import "GroupUserDefaultUtil.h"
#import "QRCodeThemeUtil.h"

#define kPaymentAddressQrCache @"PaymentAddressQrCache"
#define kQrImageSize (340)

@interface PaymentInterfaceController ()
@property(weak, nonatomic) IBOutlet WKInterfaceImage *ivQr;
@property NSString *currentAddress;
@property NSUInteger currentQrTheme;
@end

@implementation PaymentInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    NSString *payment = [GroupUserDefaultUtil instance].paymentAddress;
    if (!payment || payment.length == 0) {
        return;
    }
    [self.ivQr setImageNamed:kPaymentAddressQrCache];
    [self refreshQr];
}

- (void)willActivate {
    [super willActivate];
    [self refreshQr];
}

- (void)refreshQr {
    NSString *payment = [GroupUserDefaultUtil instance].paymentAddress;
    if (!payment || payment.length == 0) {
        return;
    }
    if (self.currentAddress == nil || ![self.currentAddress isEqualToString:[GroupUserDefaultUtil instance].paymentAddress] || self.currentQrTheme != [GroupUserDefaultUtil instance].getQrCodeTheme) {
        self.currentAddress = payment;
        self.currentQrTheme = [GroupUserDefaultUtil instance].getQrCodeTheme;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *qr = [QRCodeThemeUtil qrCodeOfContent:payment andSize:kQrImageSize withTheme:[[QRCodeTheme themes] objectAtIndex:[GroupUserDefaultUtil instance].getQrCodeTheme]];
            [[WKInterfaceDevice currentDevice] addCachedImage:qr name:kPaymentAddressQrCache];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.ivQr setImageNamed:kPaymentAddressQrCache];
            });
        });
    }
}

- (void)didDeactivate {
    [super didDeactivate];
}

@end
