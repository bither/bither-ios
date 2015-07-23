//
//  SignTransactionViewController.m
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

#import "SignTransactionViewController.h"
#import "StringUtil.h"
#import "UnitUtil.h"
#import "DialogProgress.h"
#import <Bitheri/BTAddressManager.h>
#import "DialogPassword.h"
#import "QrCodeViewController.h"
#import "BTQRCodeUtil.h"

@interface SignTransactionViewController () <DialogPasswordDelegate> {
    BTAddress *address;
}
@property(weak, nonatomic) IBOutlet UIView *vTopBar;
@property(weak, nonatomic) IBOutlet UILabel *lblFrom;
@property(weak, nonatomic) IBOutlet UILabel *lblTo;
@property(weak, nonatomic) IBOutlet UILabel *lblAmount;
@property(weak, nonatomic) IBOutlet UILabel *lblFee;
@property(weak, nonatomic) IBOutlet UILabel *lblNoPrivateKey;
@property(weak, nonatomic) IBOutlet UIButton *btnSign;
@property(weak, nonatomic) IBOutlet UIView *vChange;
@property(weak, nonatomic) IBOutlet UIView *vBottom;
@property(weak, nonatomic) IBOutlet UILabel *lblChangeAddress;
@property(weak, nonatomic) IBOutlet UILabel *lblChangeAmount;

@end

@implementation SignTransactionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.tx.txTransportType == TxTransportTypeColdHD) {
        self.lblFrom.text = NSLocalizedString(@"hd_account_cold_address_list_label", nil);
    } else {
        self.lblFrom.text = self.tx.myAddress;
    }
    self.lblTo.text = self.tx.toAddress;
    self.lblAmount.attributedText = [UnitUtil attributedStringWithSymbolForAmount:self.tx.to withFontSize:14 color:self.lblAmount.textColor];
    self.lblFee.attributedText = [UnitUtil attributedStringWithSymbolForAmount:self.tx.fee withFontSize:14 color:self.lblAmount.textColor];

    if (self.tx.changeAmt > 0 && ![StringUtil isEmpty:self.tx.changeAddress]) {
        self.vChange.hidden = NO;
        self.lblChangeAddress.text = self.tx.changeAddress;
        self.lblChangeAmount.attributedText = [UnitUtil attributedStringWithSymbolForAmount:self.tx.changeAmt withFontSize:14 color:self.lblChangeAmount.textColor];
    } else {
        self.vChange.hidden = YES;
    }

    CGRect bottomFrame = self.vBottom.frame;
    if (!self.vChange.hidden) {
        bottomFrame.origin.y = CGRectGetMaxY(self.vChange.frame);
    } else {
        bottomFrame.origin.y = self.vChange.frame.origin.y;
    }
    self.vBottom.frame = bottomFrame;

    NSArray *privKeys = [BTAddressManager instance].privKeyAddresses;
    if (self.tx.txTransportType == TxTransportTypeColdHD) {
        if ([BTAddressManager instance].hasHDAccountCold) {
            self.btnSign.hidden = NO;
            self.lblNoPrivateKey.hidden = YES;
        } else {
            self.btnSign.hidden = YES;
            self.lblNoPrivateKey.hidden = NO;
        }
    } else if (self.tx.hdmIndex >= 0 || self.tx.txTransportType == TxTransportTypeColdHDM) {
        if ([BTAddressManager instance].hdmKeychain) {
            self.btnSign.hidden = NO;
            self.lblNoPrivateKey.hidden = YES;
        } else {
            self.btnSign.hidden = YES;
            self.lblNoPrivateKey.hidden = NO;
        }
    } else {
        address = nil;
        for (BTAddress *a in privKeys) {
            if ([StringUtil compareString:a.address compare:self.tx.myAddress]) {
                address = a;
                break;
            }
        }
        if (address) {
            self.btnSign.hidden = NO;
            self.lblNoPrivateKey.hidden = YES;
        } else {
            self.btnSign.hidden = YES;
            self.lblNoPrivateKey.hidden = NO;
        }
    }
}

- (void)onPasswordEntered:(NSString *)password {
    if ((!address && self.tx.hdmIndex < 0 && self.tx.txTransportType != TxTransportTypeColdHD) || (self.tx.hdmIndex >= 0 && ![BTAddressManager instance].hasHDMKeychain) || (self.tx.txTransportType == TxTransportTypeColdHD && ![BTAddressManager instance].hasHDAccountCold)) {
        return;
    }
    __block NSString *bpassword = password;
    password = nil;
    DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Signing Transaction", nil)];
    [dp showInWindow:self.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *hashesData = [[NSMutableArray alloc] init];
            for (NSString *h in self.tx.hashList) {
                [hashesData addObject:[h hexToData]];
            }
            NSMutableArray *strHashes = [[NSMutableArray alloc] init];
            if (self.tx.txTransportType == TxTransportTypeColdHD) {
                NSArray *sigs = [[BTAddressManager instance].hdAccountCold signHashHexes:self.tx.hashList paths:self.tx.pathTypeIndexes andPassword:bpassword];
                for (NSData *data in sigs) {
                    [strHashes addObject:[NSString hexWithData:data]];
                }
            } else if (self.tx.hdmIndex >= 0) {
                BTBIP32Key *key = [[BTAddressManager instance].hdmKeychain externalKeyWithIndex:self.tx.hdmIndex andPassword:bpassword];
                for (NSData *hash in hashesData) {
                    [strHashes addObject:[NSString hexWithData:[key.key sign:hash]]];
                }
            } else {
                NSArray *hashes = [address signHashes:hashesData withPassphrase:bpassword];
                for (NSData *hash in hashes) {
                    [strHashes addObject:[NSString hexWithData:hash]];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                QrCodeViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"QrCode"];
                controller.content = [BTQRCodeUtil joinedQRCode:strHashes];
                controller.qrCodeMsg = NSLocalizedString(@"Scan with Bither Hot to sign tx", nil);
                controller.qrCodeTitle = NSLocalizedString(@"Signed Transaction", nil);
                [dp dismissWithCompletion:^{
                    [self.navigationController pushViewController:controller animated:YES];
                }];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    UINavigationController *nav = self.navigationController;
                    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:nav.viewControllers];
                    [array removeObject:self];
                    nav.viewControllers = array;
                });
            });
            bpassword = nil;
        });
    }];
}

- (IBAction)signButtonPressed:(id)sender {
    if ((!address && self.tx.hdmIndex < 0 && self.tx.txTransportType != TxTransportTypeColdHD) || (self.tx.hdmIndex >= 0 && ![BTAddressManager instance].hasHDMKeychain) || (self.tx.txTransportType == TxTransportTypeColdHD && ![BTAddressManager instance].hasHDAccountCold)) {
        return;
    }
    [[[DialogPassword alloc] initWithDelegate:self] showInWindow:self.view.window];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
