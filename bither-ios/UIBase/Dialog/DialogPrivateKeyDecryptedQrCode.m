//
//  DialogPrivateKeyDecryptedQrCode.m
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


#import "DialogPrivateKeyDecryptedQrCode.h"
#import "UIImage+ImageWithColor.h"
#import "QRCodeThemeUtil.h"
#import "StringUtil.h"


#define kShareBottomDistance (20)
#define kShareBottomHeight (32)
#define kShareBottomFontSize (16)
#define kShareBottomImageMargin (3)

@interface DialogPrivateKeyDecryptedQrCode () <UIDocumentInteractionControllerDelegate> {
    NSString *_privateStr;
    NSString *_address;
}
@property UILabel *lblAddress;
@property UIImageView *iv;
@end

@implementation DialogPrivateKeyDecryptedQrCode

- (instancetype)initWithAddress:(NSString *)address privateKey:(NSString *)privateStr {

    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width + (kShareBottomDistance + kShareBottomHeight) * 2)];
    if (self) {
        _privateStr = privateStr;
        _address = address;
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.backgroundImage = [UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0]];
    self.bgInsets = UIEdgeInsetsMake(10, 0, 10, 0);
    self.dimAmount = 0.8f;
    self.iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, kShareBottomDistance + kShareBottomHeight, self.frame.size.width, self.frame.size.width)];
    self.iv.image = [QRCodeThemeUtil qrCodeOfContent:_privateStr andSize:self.frame.size.width margin:self.frame.size.width * 0.03f withTheme:[QRCodeTheme black]];
    [self addSubview:self.iv];
    UIButton *btnDismiss = [[UIButton alloc] initWithFrame:self.iv.frame];
    [btnDismiss setBackgroundImage:nil forState:UIControlStateNormal];
    [btnDismiss addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnDismiss];

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

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (point.y < self.iv.frame.origin.y || (point.y > CGRectGetMaxY(self.iv.frame) && point.y < CGRectGetMaxY(self.iv.frame) + kShareBottomDistance)) {
        return NO;
    }
    return [super pointInside:point withEvent:event];
}

- (void)dealloc {
    _privateStr = @"";
}
@end