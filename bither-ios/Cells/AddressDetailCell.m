//
//  AddressDetailCell.m
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

#import <Bitheri/BTHDMAddress.h>
#import "AddressDetailCell.h"
#import "UIBaseUtil.h"
#import "StringUtil.h"
#import "QRCodeThemeUtil.h"
#import "AmountButton.h"
#import "SendViewController.h"
#import "AddressDetailViewController.h"
#import "DialogAddressQrCode.h"
#import "UserDefaultsUtil.h"
#import "UnsignedTransactionViewController.h"
#import "DialogBalanceDetail.h"
#import "HdmSendViewController.h"
#import "HDAccountSendViewController.h"
#import "HDAccountMonitoredSendViewController.h"

#define kAddressGroupSize (4)
#define kAddressLineSize (12)

#define kSendButtonPadding (10)
#define kSendButtonHeight (36)
#define kSendButtonMinWidth (66)
#define kSendButtonQrIconSize (16)

#define kBalanceLabelHorizontalMargin (5)

@interface AddressDetailCell () <SendDelegate, DialogAddressQrCodeDelegate, AmountButtonFrameChangeListener>
@property(weak, nonatomic) IBOutlet UILabel *lblAddress;
@property(weak, nonatomic) IBOutlet UIView *vAddressContainer;
@property(weak, nonatomic) IBOutlet UIButton *btnSend;
@property(weak, nonatomic) IBOutlet UIImageView *ivQr;
@property(weak, nonatomic) IBOutlet UIView *vQr;
@property(weak, nonatomic) IBOutlet AmountButton *btnAmount;
@property(weak, nonatomic) IBOutlet UIButton *btnBalanceDetail;
@property(weak, nonatomic) IBOutlet UILabel *lblBalance;
@property BTAddress *address;
@end

@implementation AddressDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        for (UIView *currentView in self.subviews) {
            if ([currentView isKindOfClass:[UIScrollView class]]) {
                ((UIScrollView *) currentView).delaysContentTouches = NO;
                break;
            }
        }
    }
    return self;
}

- (void)showAddress:(BTAddress *)address {
    self.address = address;
    self.lblAddress.text = [StringUtil formatAddress:address.address groupSize:kAddressGroupSize lineSize:kAddressLineSize];
    [self configureAddressFrame];
    self.ivQr.image = [QRCodeThemeUtil qrCodeOfContent:address.address andSize:self.ivQr.frame.size.width withTheme:[[QRCodeTheme themes] objectAtIndex:[[UserDefaultsUtil instance] getQrCodeTheme]]];
    [self.btnAmount setAmount:address.balance];
    self.btnAmount.frameChangeListener = self;

    CGPoint sendOri = self.btnSend.frame.origin;
    if (!address.hasPrivKey && !address.isHDM || (address.isHDM && ((BTHDMAddress *) address).isInRecovery) || (address.isHDAccount && !address.hasPrivKey)) {
        UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unsigned_transaction_button_icon"]];
        CGFloat margin = (self.btnSend.frame.size.height - kSendButtonQrIconSize) / 2;
        iv.frame = CGRectMake(self.btnSend.frame.size.width - kSendButtonQrIconSize - margin, margin, kSendButtonQrIconSize, kSendButtonQrIconSize);
        iv.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.btnSend addSubview:iv];
        self.btnSend.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kSendButtonQrIconSize + margin / 2);
    }
    [self.btnSend sizeToFit];
    CGFloat sendWidth = self.btnSend.frame.size.width + kSendButtonPadding * 2;
    self.btnSend.frame = CGRectMake(sendOri.x, sendOri.y, sendWidth, kSendButtonHeight);

    [self.lblBalance sizeToFit];
    [self amountButtonFrameChanged:self.btnAmount.frame];
    self.btnBalanceDetail.hidden = address.isHDAccount;
}

- (void)configureAddressFrame {
    CGSize lblSize = [self.lblAddress.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.lblAddress.font, NSParagraphStyleAttributeName : [NSParagraphStyle defaultParagraphStyle]} context:nil].size;
    lblSize.height = ceilf(lblSize.height);
    lblSize.width = ceilf(lblSize.width);
    CGSize containerSize = CGSizeMake(lblSize.width + self.lblAddress.frame.origin.x * 2, lblSize.height + self.lblAddress.frame.origin.y * 2);
    self.vAddressContainer.frame = CGRectMake(self.vAddressContainer.frame.origin.x, self.vAddressContainer.frame.origin.y, containerSize.width, containerSize.height);
}

- (void)amountButtonFrameChanged:(CGRect)frame {
    CGRect rect = self.lblBalance.frame;
    rect.origin.x = self.btnAmount.frame.origin.x - rect.size.width - kBalanceLabelHorizontalMargin;
    rect.size.height = self.btnAmount.frame.size.height;
    self.lblBalance.frame = rect;

    rect = self.btnBalanceDetail.frame;
    rect.origin.x = self.lblBalance.frame.origin.x - rect.size.width - kBalanceLabelHorizontalMargin;
    self.btnBalanceDetail.frame = rect;
}

- (void)configureQrCodeFrame {
    CGFloat size = self.vAddressContainer.frame.size.height;
    CGFloat gap = (self.frame.size.width - self.vAddressContainer.frame.size.width - size) / 3;
    self.vAddressContainer.frame = CGRectMake(gap, self.vAddressContainer.frame.origin.y, self.vAddressContainer.frame.size.width, self.vAddressContainer.frame.size.height);
    self.vQr.frame = CGRectMake(CGRectGetMaxX(self.vAddressContainer.frame) + gap, self.vAddressContainer.frame.origin.y, size, size);
}

- (void)qrCodeThemeChanged:(QRCodeTheme *)theme {
    self.ivQr.image = [QRCodeThemeUtil qrCodeOfContent:self.address.address andSize:self.ivQr.frame.size.width withTheme:theme];
}

- (IBAction)sendPressed:(id)sender {
    if (self.address.isHDAccount) {
        if (self.address.hasPrivKey) {
            HDAccountSendViewController *send = [self.getUIViewController.storyboard instantiateViewControllerWithIdentifier:@"HDAccountSend"];
            send.address = self.address;
            send.sendDelegate = self;
            [self.getUIViewController.navigationController pushViewController:send animated:YES];
        } else {
            HDAccountMonitoredSendViewController *send = [self.getUIViewController.storyboard instantiateViewControllerWithIdentifier:@"HDAccountMonitoredSend"];
            send.address = self.address;
            send.sendDelegate = self;
            [self.getUIViewController.navigationController pushViewController:send animated:YES];
        }
    } else if (self.address.isHDM) {
        HdmSendViewController *send = [self.getUIViewController.storyboard instantiateViewControllerWithIdentifier:@"HdmSend"];
        send.address = (BTHDMAddress *) self.address;
        send.sendDelegate = self;
        [self.getUIViewController.navigationController pushViewController:send animated:YES];
    } else if (self.address.hasPrivKey) {
        SendViewController *send = [self.getUIViewController.storyboard instantiateViewControllerWithIdentifier:@"Send"];
        send.address = self.address;
        send.sendDelegate = self;
        [self.getUIViewController.navigationController pushViewController:send animated:YES];
    } else {
        UnsignedTransactionViewController *unsignedTx = [self.getUIViewController.storyboard instantiateViewControllerWithIdentifier:@"UnsignedTransaction"];
        unsignedTx.address = self.address;
        unsignedTx.sendDelegate = self;
        [self.getUIViewController.navigationController pushViewController:unsignedTx animated:YES];
    }
}

- (IBAction)balanceDetailPressed:(id)sender {
    [[[DialogBalanceDetail alloc] initWithAddress:self.address] showFromView:self.btnBalanceDetail];
}

- (IBAction)qrPressed:(id)sender {
    DialogAddressQrCode *dialogQr = [[DialogAddressQrCode alloc] initWithAddress:self.address delegate:self];
    [dialogQr showInWindow:self.window];
}

- (void)sendSuccessed:(BTTx *)tx {
    if ([self.getUIViewController isKindOfClass:[AddressDetailViewController class]]) {
        AddressDetailViewController *controller = (AddressDetailViewController *) self.getUIViewController;
        [controller showMessage:NSLocalizedString(@"Send success.", nil)];
    }
}

- (IBAction)copyPressed:(id)sender {
    [UIPasteboard generalPasteboard].string = self.address.address;
    if ([self.getUIViewController isKindOfClass:[AddressDetailViewController class]]) {
        AddressDetailViewController *controller = (AddressDetailViewController *) self.getUIViewController;
        [controller showMessage:NSLocalizedString(@"Address copied.", nil)];
    }
}
@end
