//
//  ColdAddressListCell.m
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

#import <Bitheri/BTKey+BIP38.h>
#import "ColdAddressListCell.h"
#import "UIBaseUtil.h"
#import "StringUtil.h"
#import "QRCodeThemeUtil.h"
#import "NSString+Size.h"
#import "DialogBlackQrCode.h"
#import "ColdAddressViewController.h"
#import "DialogAddressLongPressOptions.h"
#import "DialogPassword.h"
#import "DialogPrivateKeyEncryptedQrCode.h"
#import "DialogPrivateKeyDecryptedQrCode.h"
#import "DialogProgress.h"
#import "DialogPrivateKeyText.h"
#import "HotAddressViewController.h"
#import "BitherSetting.h"
#import "DialogXrandomInfo.h"
#import "BTAddressManager.h"
#import "SignMessageViewController.h"
#import "AddressAliasView.h"

#define kAddressGroupSize (4)
#define kAddressLineSize (12)

@interface ColdAddressListCell () <DialogPrivateKeyOptionsDelegate, DialogPasswordDelegate> {
    BTAddress *_btAddress;
    PrivateKeyQrCodeType _qrcodeType;
    BOOL isMovingToTrash;

}
@property(weak, nonatomic) IBOutlet UIImageView *ivType;
@property(weak, nonatomic) IBOutlet UIImageView *ivXrandom;
@property(weak, nonatomic) IBOutlet UILabel *lblAddress;
@property(weak, nonatomic) IBOutlet UIView *vAddressContainer;
@property(weak, nonatomic) IBOutlet UIImageView *ivQr;
@property(weak, nonatomic) IBOutlet UIView *vQr;
@property(weak, nonatomic) IBOutlet UIView *vContainer;
@property(weak, nonatomic) IBOutlet AddressAliasView *btnAlias;
@property(strong, nonatomic) UILongPressGestureRecognizer *longPress;
@property(strong, nonatomic) UILongPressGestureRecognizer *xrandomLongPress;
@end

@implementation ColdAddressListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)showAddress:(BTAddress *)address {
    _btAddress = address;
    self.lblAddress.text = [StringUtil formatAddress:address.address groupSize:kAddressGroupSize lineSize:kAddressLineSize];
    if (self.longPress == nil) {
        self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTableviewCellLongPressed:)];

    }
    if (![[self.ivType gestureRecognizers] containsObject:self.longPress]) {
        [self.ivType addGestureRecognizer:self.longPress];
    }
    if (!self.xrandomLongPress) {
        self.xrandomLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleXrandomLabelLongPressed:)];
        [self.ivXrandom addGestureRecognizer:self.xrandomLongPress];
    }
    self.ivXrandom.hidden = !address.isFromXRandom;
    [self configureAddressFrame];
    self.ivQr.image = [QRCodeThemeUtil qrCodeOfContent:address.address andSize:self.ivQr.frame.size.width withTheme:[QRCodeTheme black]];
    self.btnAlias.address = address;
    isMovingToTrash = NO;
}

- (void)configureAddressFrame {
    CGSize lblSize = [self.lblAddress.text sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:self.lblAddress.font];
    lblSize.height = ceilf(lblSize.height);
    lblSize.width = ceilf(lblSize.width);
    CGSize containerSize = CGSizeMake(lblSize.width + self.lblAddress.frame.origin.x * 2, lblSize.height + self.lblAddress.frame.origin.y * 2);
    self.vAddressContainer.frame = CGRectMake(self.vAddressContainer.frame.origin.x, (self.vContainer.frame.size.height - containerSize.height) / 2, containerSize.width, containerSize.height);
    CGFloat qrSize = containerSize.height;
    self.vQr.frame = CGRectMake(self.vContainer.frame.size.width - qrSize - self.vAddressContainer.frame.origin.x, self.vAddressContainer.frame.origin.y, qrSize, qrSize);
}

- (IBAction)qrPressed:(id)sender {
    [[[DialogBlackQrCode alloc] initWithContent:_btAddress.address] showInWindow:self.window];
}

- (IBAction)copyAddressPressed:(id)sender {
    [UIPasteboard generalPasteboard].string = _btAddress.address;
    UIViewController *ctr = self.getUIViewController;
    if ([ctr isKindOfClass:[ColdAddressViewController class]]) {
        ColdAddressViewController *cctr = (ColdAddressViewController *) ctr;
        if ([cctr respondsToSelector:@selector(showMsg:)]) {
            [cctr showMsg:NSLocalizedString(@"Address copied.", nil)];
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
}

- (void)handleTableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        DialogAddressLongPressOptions *dialogPrivateKeyOptons = [[DialogAddressLongPressOptions alloc] initWithAddress:_btAddress delegate:self andAliasDelegate:self.btnAlias];
        [dialogPrivateKeyOptons showInWindow:self.window];
    }
}

- (void)handleXrandomLabelLongPressed:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [[[DialogXrandomInfo alloc] init] showInWindow:self.window];
    }
}

//DialogPrivateKeyOptionsDelegate
- (void)stopMonitorAddress {

}

- (void)resetMonitorAddress {
}

- (void)showPrivateKeyDecryptedQrCode {
    _qrcodeType = Decrypetd;
    DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
    [dialog showInWindow:self.window];
}

- (void)showPrivateKeyEncryptedQrCode {
    _qrcodeType = Encrypted;
    DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
    [dialog showInWindow:self.window];
}

- (void)showPrivateKeyTextQrCode {
    _qrcodeType = Text;
    DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
    [dialog showInWindow:self.window];
}

- (void)showBIP38PrivateKey {
    _qrcodeType = BIP38;
    DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
    [dialog showInWindow:self.window];
}

- (void)showMsg:(NSString *)msg {
    UIViewController *ctr = self.getUIViewController;
    if ([ctr respondsToSelector:@selector(showMsg:)]) {
        [ctr performSelector:@selector(showMsg:) withObject:msg];
    }
}

- (void)moveToTrash {
    if (_btAddress.balance > 0) {
        [self showMsg:NSLocalizedString(@"trash_with_money_warn", nil)];
    } else {
        isMovingToTrash = YES;
        DialogPassword *dp = [[DialogPassword alloc] initWithDelegate:self];
        [dp showInWindow:self.window];
    }
}

- (void)signMessage {
    if (!_btAddress.hasPrivKey) {
        return;
    }
    SignMessageViewController *sign = [self.getUIViewController.storyboard instantiateViewControllerWithIdentifier:@"SignMessage"];
    sign.address = _btAddress;
    [self.getUIViewController.navigationController pushViewController:sign animated:YES];
}

//DialogPasswordDelegate
- (void)onPasswordEntered:(NSString *)password {
    __block NSString *bpassword = password;
    password = nil;
    if (isMovingToTrash) {
        isMovingToTrash = NO;
        DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"trashing_private_key", nil)];
        [dp showInWindow:self.window completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [[BTAddressManager instance] trashPrivKey:_btAddress];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dp dismissWithCompletion:^{
                        UIViewController *vc = self.getUIViewController;
                        if (vc && [vc respondsToSelector:@selector(reload)]) {
                            [vc performSelector:@selector(reload) withObject:nil];
                        }
                    }];
                });
            });
        }];
        return;
    }
    if (_qrcodeType == Encrypted) {
        DialogPrivateKeyEncryptedQrCode *dialog = [[DialogPrivateKeyEncryptedQrCode alloc] initWithAddress:_btAddress];
        [dialog showInWindow:self.window];
    } else {
        DialogProgress *dialogProgress = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
        [dialogProgress showInWindow:self.window];
        if (_qrcodeType == BIP38) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                BTKey *key = [BTKey keyWithBitcoinj:_btAddress.fullEncryptPrivKey andPassphrase:bpassword];
                __block NSString *bip38 = [key BIP38KeyWithPassphrase:bpassword];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dialogProgress dismissWithCompletion:^{
                        DialogPrivateKeyDecryptedQrCode *dialogPrivateKey = [[DialogPrivateKeyDecryptedQrCode alloc] initWithAddress:_btAddress.address privateKey:bip38];
                        [dialogPrivateKey showInWindow:self.window];
                    }];
                });
            });
            return;
        }
        [self decrypted:bpassword callback:^(id response) {
            [dialogProgress dismiss];
            if (_qrcodeType == Decrypetd) {
                DialogPrivateKeyDecryptedQrCode *dialogPrivateKey = [[DialogPrivateKeyDecryptedQrCode alloc] initWithAddress:_btAddress.address privateKey:response];
                [dialogPrivateKey showInWindow:self.window];

            } else {
                DialogPrivateKeyText *dialogPrivateKeyText = [[DialogPrivateKeyText alloc] initWithPrivateKeyStr:response];
                [dialogPrivateKeyText showInWindow:self.window];

            }
            response = nil;
            bpassword = nil;

        }];
    }

}

- (void)decrypted:(NSString *)password callback:(IdResponseBlock)callback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        BTKey *key = [BTKey keyWithBitcoinj:_btAddress.fullEncryptPrivKey andPassphrase:password];
        __block NSString *privateKey = key.privateKey;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(privateKey);
            }
        });
        key = nil;
    });
}

@end
