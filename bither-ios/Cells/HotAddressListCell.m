//
//  HotAddressListCell.m
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
#import "HotAddressListCell.h"
#import "StringUtil.h"
#import "UnitUtil.h"
#import "TransactionConfidenceView.h"
#import "AmountButton.h"
#import "NSAttributedString+Size.h"
#import "UIBaseUtil.h"
#import "DialogAddressFull.h"
#import "MarketUtil.h"
#import "DialogAddressLongPressOptions.h"
#import "DialogPassword.h"
#import "DialogPrivateKeyEncryptedQrCode.h"
#import "DialogPrivateKeyDecryptedQrCode.h"
#import "DialogProgress.h"
#import "DialogPrivateKeyText.h"
#import "DialogAlert.h"
#import "KeyUtil.h"
#import "HotAddressViewController.h"
#import "DialogXrandomInfo.h"
#import "BTAddressManager.h"
#import "SignMessageViewController.h"
#import "DialogHDMAddressOptions.h"
#import "AddressAliasView.h"
#import "DialogHDAccountOptions.h"

#define kUnconfirmedTxAmountLeftMargin (3)

#define kBalanceFontSize (19)

@interface HotAddressListCell () <DialogAddressFullDelegate, DialogPrivateKeyOptionsDelegate, DialogPasswordDelegate> {
    BTAddress *_btAddress;
    DialogHDAccountOptions *dialogHDAccountOptions;
    PrivateKeyQrCodeType _qrcodeType;
    BOOL isMovingToTrash;
}

@property(weak, nonatomic) IBOutlet UILabel *lblAddress;
@property(weak, nonatomic) IBOutlet UILabel *lblBalanceBtc;
@property(weak, nonatomic) IBOutlet UILabel *lblBalanceMoney;
@property(weak, nonatomic) IBOutlet UIImageView *ivType;
@property(weak, nonatomic) IBOutlet UIImageView *ivXrandom;
@property(weak, nonatomic) IBOutlet UILabel *lblTransactionCount;
@property(weak, nonatomic) IBOutlet UIImageView *ivHighlighted;
@property(weak, nonatomic) IBOutlet UIView *vNoUnconfirmedTx;
@property(weak, nonatomic) IBOutlet UIView *vUnconfirmedTx;
@property(weak, nonatomic) IBOutlet TransactionConfidenceView *vUnconfirmedTxConfidence;
@property(weak, nonatomic) IBOutlet AmountButton *vUnconfirmedTxAmount;
@property(weak, nonatomic) IBOutlet UIButton *btnAddressFull;
@property(weak, nonatomic) IBOutlet UIImageView *ivSymbolBtc;
@property(weak, nonatomic) IBOutlet AddressAliasView *btnAlias;
@property(strong, nonatomic) UILongPressGestureRecognizer *longPress;
@property(strong, nonatomic) UILongPressGestureRecognizer *xrandomLongPress;

@end

@implementation HotAddressListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setAddress:(BTAddress *)address {
    _btAddress = address;
    self.vUnconfirmedTxAmount.alignLeft = YES;
    self.lblAddress.text = [StringUtil shortenAddress:address.address];
    CGFloat width = [self widthForLabel:self.lblAddress maxWidth:self.frame.size.width];
    self.lblAddress.frame = CGRectMake(self.lblAddress.frame.origin.x, self.lblAddress.frame.origin.y, width, self.lblAddress.frame.size.height);
    if (self.longPress == nil) {
        self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTableviewCellLongPressed:)];
    }
    if (![[self.ivType gestureRecognizers] containsObject:self.longPress]) {
        [self.ivType addGestureRecognizer:self.longPress];
    }
    if (address.isHDAccount) {
        self.ivType.image = [UIImage imageNamed:@"address_type_hd"];
    } else if (address.isHDM) {
        self.ivType.image = [UIImage imageNamed:@"address_type_hdm"];
    } else if (address.hasPrivKey) {
        self.ivType.image = [UIImage imageNamed:@"address_type_private"];
    } else {
        self.ivType.image = [UIImage imageNamed:@"address_type_watchonly"];
    }

    if (!self.xrandomLongPress) {
        self.xrandomLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleXrandomLabelLongPressed:)];
        [self.ivXrandom addGestureRecognizer:self.xrandomLongPress];
    }
    self.ivXrandom.hidden = !address.isFromXRandom;

    self.lblBalanceBtc.attributedText = [UnitUtil attributedStringForAmount:address.balance withFontSize:kBalanceFontSize];

    width = [self.lblBalanceBtc.attributedText sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, self.lblBalanceBtc.frame.size.height)].width;
    self.lblBalanceBtc.frame = CGRectMake(CGRectGetMaxX(self.lblBalanceBtc.frame) - width, self.lblBalanceBtc.frame.origin.y, width, self.lblBalanceBtc.frame.size.height);
    self.ivSymbolBtc.frame = CGRectMake(CGRectGetMinX(self.lblBalanceBtc.frame) - self.ivSymbolBtc.frame.size.width - 2, self.ivSymbolBtc.frame.origin.y, self.ivSymbolBtc.frame.size.width, self.ivSymbolBtc.frame.size.height);
    self.ivSymbolBtc.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_black", [UnitUtil imageNameSlim]]];
//    if (![_btAddress.address isEqualToString:address.address])
//        self.lblTransactionCount.text = [NSString string];
    self.vNoUnconfirmedTx.hidden = NO;
    self.vUnconfirmedTx.hidden = YES;

    uint32_t txCount = address.txCount;
    BTTx *recentlyTx = address.recentlyTx;
    if (txCount > 0 && recentlyTx != nil) {
        self.vNoUnconfirmedTx.hidden = YES;
        self.vUnconfirmedTx.hidden = NO;
        [self.vUnconfirmedTxConfidence showTransaction:recentlyTx withAddress:_btAddress];
        self.vUnconfirmedTxAmount.amount = [recentlyTx deltaAmountFrom:address];
        CGRect frame = self.vUnconfirmedTxAmount.frame;
        frame.origin.x = CGRectGetMaxX(self.vUnconfirmedTxConfidence.frame) + kUnconfirmedTxAmountLeftMargin;
        self.vUnconfirmedTxAmount.frame = frame;
    } else {
        self.lblTransactionCount.text = [NSString stringWithFormat:@"%u", txCount];
        self.vNoUnconfirmedTx.hidden = NO;
        self.vUnconfirmedTx.hidden = YES;
    }

    CGRect frame = self.btnAddressFull.frame;
    frame.origin.x = CGRectGetMaxX(self.lblAddress.frame) + 5;
    self.btnAddressFull.frame = frame;
    if ([MarketUtil getDefaultNewPrice] > 0) {
        double balanceMoney = ([MarketUtil getDefaultNewPrice] * address.balance) / pow(10, 8);
        self.lblBalanceMoney.text = [StringUtil formatPrice:balanceMoney];
    } else {
        self.lblBalanceMoney.text = @"--";
    }

    self.btnAlias.address = address;
    isMovingToTrash = NO;
}

- (CGFloat)widthForLabel:(UILabel *)lbl maxWidth:(CGFloat)maxWidth {
    CGFloat width = [lbl.text boundingRectWithSize:CGSizeMake(maxWidth, lbl.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : lbl.font, NSParagraphStyleAttributeName : [NSParagraphStyle defaultParagraphStyle]} context:nil].size.width;
    width = ceilf(width);
    return width;
}

- (IBAction)addressFullPressed:(id)sender {
    [[[DialogAddressFull alloc] initWithDelegate:self] showFromView:self.btnAddressFull];
}

- (NSUInteger)dialogAddressFullRowCount {
    return 1;
}

- (NSString *)dialogAddressFullAddressForRow:(NSUInteger)row {
    return _btAddress.address;
}

- (int64_t)dialogAddressFullAmountForRow:(NSUInteger)row {
    return 0;
}

- (BOOL)dialogAddressFullDoubleColumn {
    return NO;
}

- (void)showMsg:(NSString *)msg {
    UIViewController *ctr = self.getUIViewController;
    if ([ctr respondsToSelector:@selector(showMsg:)]) {
        [ctr performSelector:@selector(showMsg:) withObject:msg];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.ivHighlighted.highlighted = highlighted;
}

- (void)handleTableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (_btAddress.isHDAccount) {
            if (!_btAddress.hasPrivKey) {
                return;
            }
            dialogHDAccountOptions = [[DialogHDAccountOptions alloc] initWithHDAccount:[BTAddressManager instance].hdAccountHot andDelegate:nil];
            [dialogHDAccountOptions showInWindow:self.window];
        } else if (_btAddress.isHDM) {
            [[[DialogHDMAddressOptions alloc] initWithAddress:_btAddress andAddressAliasDelegate:nil] showInWindow:self.window];
        } else {
            DialogAddressLongPressOptions *dialogPrivateKeyOptons = [[DialogAddressLongPressOptions alloc] initWithAddress:_btAddress andDelegate:self];
            [dialogPrivateKeyOptons showInWindow:self.window];
        }
    }
}

- (void)handleXrandomLabelLongPressed:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [[[DialogXrandomInfo alloc] init] showInWindow:self.window];
    }
}

//DialogPrivateKeyOptionsDelegate
- (void)stopMonitorAddress {
    [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"Sure to stop monitoring this address?", nil) confirm:^{
        [KeyUtil stopMonitor:_btAddress];
        if (self.viewController && [self.viewController isMemberOfClass:[HotAddressViewController class]]) {
            HotAddressViewController *hotAddressViewController = (HotAddressViewController *) self.viewController;
            [hotAddressViewController reload];
        }
    }                              cancel:nil] showInWindow:self.window];
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
            bpassword = nil;
            response = nil;
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
