//
//  DialogPrivateKeyEncryptedQrCode.m
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

#import "DialogPrivateKeyEncryptedQrCode.h"
#import "UIImage+ImageWithColor.h"
#import "QRCodeThemeUtil.h"
#import "StringUtil.h"
#import "FileUtil.h"
#import "UIBaseUtil.h"
#import "BTQRCodeUtil.h"

#define kShareBottomDistance (20)
#define kShareBottomHeight (32)
#define kShareBottomFontSize (16)
#define kShareBottomImageMargin (3)

@interface DialogPrivateKeyEncryptedQrCode () <UIDocumentInteractionControllerDelegate> {
    NSString *_encrytedPrivateKey;
    NSString *_shareFileName;
    NSString *_address;
}
@property UILabel *lblAddress;
@property UIImageView *iv;
@property UIButton *btnShare;
@property UIDocumentInteractionController *interactionController;
@end

@implementation DialogPrivateKeyEncryptedQrCode

- (instancetype)initWithAddress:(BTAddress *)address {
    if (!address.hasPrivKey) {
        return nil;
    }
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width + (kShareBottomDistance + kShareBottomHeight) * 2)];
    if (self) {
        _address = address.address;
        _encrytedPrivateKey = [BTQRCodeUtil replaceNewQRCode:[address.fullEncryptPrivKey toUppercaseStringWithEn]];
        _shareFileName = [NSString stringWithFormat:@"%@_private_key", address.address];
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.backgroundImage = [UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0]];
    self.bgInsets = UIEdgeInsetsMake(10, 0, 10, 0);
    self.dimAmount = 0.8f;
    self.iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, kShareBottomDistance + kShareBottomHeight, self.frame.size.width, self.frame.size.width)];
    self.iv.image = [QRCodeThemeUtil qrCodeOfContent:_encrytedPrivateKey andSize:self.frame.size.width margin:self.frame.size.width * 0.03f withTheme:[QRCodeTheme black]];
    [self addSubview:self.iv];
    UIButton *btnDismiss = [[UIButton alloc] initWithFrame:self.iv.frame];
    [btnDismiss setBackgroundImage:nil forState:UIControlStateNormal];
    [btnDismiss addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnDismiss];

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height - kShareBottomHeight, 0, kShareBottomHeight)];
    [btn setTitle:NSLocalizedString(@"Back up private key", nil) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, kShareBottomHeight + kShareBottomImageMargin, 0, 0);
    btn.titleLabel.font = [UIFont systemFontOfSize:kShareBottomFontSize];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kShareBottomHeight, kShareBottomHeight)];
    iv.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    iv.image = [UIImage imageNamed:@"fancy_qr_code_share_normal"];
    [btn addSubview:iv];
    [btn sizeToFit];
    CGRect frame = btn.frame;
    frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
    btn.frame = frame;
    [btn addTarget:self action:@selector(sharePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];

    self.lblAddress = [[UILabel alloc] initWithFrame:CGRectZero];
    self.lblAddress.font = [UIFont fontWithName:@"Courier New" size:16];
    self.lblAddress.textColor = [UIColor whiteColor];
    self.lblAddress.numberOfLines = 0;
    self.lblAddress.text = [StringUtil formatAddress:_address groupSize:4 lineSize:20];
    [self.lblAddress sizeToFit];
    self.lblAddress.frame = CGRectMake((self.frame.size.width - self.lblAddress.frame.size.width) / 2.0f, 0, self.lblAddress.frame.size.width, self.lblAddress.frame.size.height);
    [self addSubview:self.lblAddress];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    [self dismiss];
}

- (void)dialogDidDismiss {
    [FileUtil deleteTmpImageForShareWithName:_shareFileName];
}

- (void)sharePressed:(id)sender {
    NSURL *url = [FileUtil saveTmpImageForShare:self.iv.image fileName:_shareFileName];
    self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    UIView *fromView = self.window.topViewController.view;
    self.interactionController.delegate = self;
    [self.interactionController presentOptionsMenuFromRect:CGRectMake(0, 0, fromView.frame.size.width, fromView.frame.size.height) inView:fromView animated:YES];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (point.y < self.iv.frame.origin.y || (point.y > CGRectGetMaxY(self.iv.frame) && point.y < CGRectGetMaxY(self.iv.frame) + kShareBottomDistance)) {
        return NO;
    }
    return [super pointInside:point withEvent:event];
}
@end
