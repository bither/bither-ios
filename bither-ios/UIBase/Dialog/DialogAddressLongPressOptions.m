//
//  DialogAddressLongPressOptions.m
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

#import "DialogAddressLongPressOptions.h"
#import "NSString+Size.h"

#define kButtonHeight (44)
#define kButtonEdgeInsets (UIEdgeInsetsMake(0, 10, 0, 10))

#define kHeight (kButtonHeight * 3 + 2)

#define kFontSize (14)

@interface DialogAddressLongPressOptions () {
    NSString *_prirvateKeyQrCodeEncryptedStr;
}
@property BTAddress *address;
@property(weak) NSObject <DialogAddressAliasDelegate> *aliasDelegate;
@end

@implementation DialogAddressLongPressOptions
- (instancetype)initWithAddress:(BTAddress *)address delegate:(NSObject <DialogPrivateKeyOptionsDelegate> *)delegate andAliasDelegate:(NSObject <DialogAddressAliasDelegate> *)aliasDelegate {
    NSString *viewStr = NSLocalizedString(@"Private Key QR Code (Decrypted)", nil);
    if (!address.hasPrivKey) {
        viewStr = NSLocalizedString(@"Stop Monitoring", nil);
    }
    if (NSLocalizedString(@"address_detail_private_Key_qr_code_bip38", nil).length >= viewStr.length) {
        viewStr = NSLocalizedString(@"address_detail_private_Key_qr_code_bip38", nil);
    }
    self = [super initWithFrame:CGRectMake(0, 0, [viewStr sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, kButtonHeight) font:[UIFont systemFontOfSize:kFontSize]].width + kButtonEdgeInsets.left + kButtonEdgeInsets.right, kHeight)];
    if (self) {
        _prirvateKeyQrCodeEncryptedStr = viewStr;
        self.delegate = delegate;
        self.aliasDelegate = aliasDelegate;
        self.address = address;
        [self firstConfigureHasPrivateKey:address.hasPrivKey];
    }
    return self;
}

- (instancetype)initWithAddress:(BTAddress *)address andDelegate:(NSObject <DialogPrivateKeyOptionsDelegate> *)delegate {
    NSString *viewStr = NSLocalizedString(@"Private Key QR Code (Decrypted)", nil);
    if (!address.hasPrivKey) {
        viewStr = NSLocalizedString(@"Stop Monitoring", nil);
    }
    if (NSLocalizedString(@"address_detail_private_Key_qr_code_bip38", nil).length >= viewStr.length) {
        viewStr = NSLocalizedString(@"address_detail_private_Key_qr_code_bip38", nil);
    }
    self = [super initWithFrame:CGRectMake(0, 0, [viewStr sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, kButtonHeight) font:[UIFont systemFontOfSize:kFontSize]].width + kButtonEdgeInsets.left + kButtonEdgeInsets.right, kHeight)];
    if (self) {
        _prirvateKeyQrCodeEncryptedStr = viewStr;
        self.delegate = delegate;
        self.address = address;
        [self firstConfigureHasPrivateKey:address.hasPrivKey];
    }
    return self;
}

- (void)firstConfigureHasPrivateKey:(BOOL)hasPrivateKey {
    self.bgInsets = UIEdgeInsetsMake(4, 16, 4, 16);
    AppMode mode = [BTSettings instance].getAppMode;
    CGFloat bottom = 0;
    if (hasPrivateKey) {
        bottom = [self createButtonWithText:NSLocalizedString(@"Private Key QR Code (Encrypted)", nil) top:bottom action:@selector(privateKeyEncryptedQrCodePressed:)];
        [self addSubview:[self getSeperator:bottom]];

        bottom += 1;
        bottom = [self createButtonWithText:NSLocalizedString(@"Private Key QR Code (Decrypted)", nil) top:bottom action:@selector(privateKeyDecryptedQrCodePressed:)];
        [self addSubview:[self getSeperator:bottom]];

        bottom += 1;
        bottom = [self createButtonWithText:NSLocalizedString(@"address_detail_private_Key_qr_code_bip38", nil) top:bottom action:@selector(showBIP38PrivateKey:)];
        [self addSubview:[self getSeperator:bottom]];

        bottom += 1;
        bottom = [self createButtonWithText:NSLocalizedString(@"Private Key", nil) top:bottom action:@selector(privateKeyTextQrCodePressed:)];
        [self addSubview:[self getSeperator:bottom]];

        if ([BTSettings instance].getAppMode == COLD) {
            bottom += 1;
            bottom = [self createButtonWithText:NSLocalizedString(@"sign_message_activity_name", nil) top:bottom action:@selector(signMessagePressed:)];
            [self addSubview:[self getSeperator:bottom]];
        }
    }
    if (mode == COLD && self.aliasDelegate) {
        bottom += 1;
        bottom = [self createButtonWithText:NSLocalizedString(@"address_alias_manage", nil) top:bottom action:@selector(addressAlias:)];
        [self addSubview:[self getSeperator:bottom]];
    }
    if (hasPrivateKey) {
        bottom += 1;
        bottom = [self createButtonWithText:NSLocalizedString(@"trash_private_key", nil) top:bottom action:@selector(trash:)];
    } else {
        bottom = [self createButtonWithText:NSLocalizedString(@"Stop Monitoring", nil) top:bottom action:@selector(stopMonitorPressed:)];
    }
    [self addSubview:[self getSeperator:bottom]];
    bottom += 1;
    bottom = [self createButtonWithText:NSLocalizedString(@"Cancel", nil) top:bottom action:@selector(cancelPressed:)];
    CGRect frame = self.frame;
    frame.size.height = bottom;
    self.frame = frame;
}

- (UIView *)getSeperator:(CGFloat)bottom {
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, self.frame.size.width, 1)];
    seperator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    seperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    return seperator;
}

- (CGFloat)createButtonWithText:(NSString *)text top:(CGFloat)top action:(SEL)selector {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, top, self.frame.size.width, kButtonHeight)];
    [btn setBackgroundImage:nil forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"card_foreground_pressed"] forState:UIControlStateHighlighted];
    btn.contentEdgeInsets = kButtonEdgeInsets;
    btn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateHighlighted];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    return CGRectGetMaxY(btn.frame);
}

- (void)addressAlias:(id)sender {
    __block UIWindow *w = self.window;
    __block BTAddress *a = self.address;
    [self dismissWithCompletion:^{
        [[[DialogAddressAlias alloc] initWithAddress:a andDelegate:self.aliasDelegate] showInWindow:w];
    }];
}

- (void)showBIP38PrivateKey:(id)sender {
    __block NSObject <DialogPrivateKeyOptionsDelegate> *delegate = self.delegate;
    [self dismissWithCompletion:^{
        if (delegate && [delegate respondsToSelector:@selector(showBIP38PrivateKey)]) {
            [delegate showBIP38PrivateKey];
        }
    }];
}

- (void)stopMonitorPressed:(id)sender {
    [self dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(stopMonitorAddress)]) {
            [self.delegate stopMonitorAddress];
        }
    }];
}

- (void)restMonitorPressed:(id)sender {
    [self dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(resetMonitorAddress)]) {
            [self.delegate resetMonitorAddress];
        }
    }];
}


- (void)privateKeyEncryptedQrCodePressed:(id)sender {
    [self dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(showPrivateKeyEncryptedQrCode)]) {
            [self.delegate showPrivateKeyEncryptedQrCode];
        }
    }];
}

- (void)privateKeyDecryptedQrCodePressed:(id)sender {
    [self dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(showPrivateKeyDecryptedQrCode)]) {
            [self.delegate showPrivateKeyDecryptedQrCode];
        }
    }];
}

- (void)privateKeyTextQrCodePressed:(id)sender {
    [self dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(showPrivateKeyTextQrCode)]) {
            [self.delegate showPrivateKeyTextQrCode];
        }
    }];
}

- (void)trash:(id)sender {
    [self dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(moveToTrash)]) {
            [self.delegate moveToTrash];
        }
    }];
}

- (void)signMessagePressed:(id)sender {
    [self dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(signMessage)]) {
            [self.delegate signMessage];
        }
    }];
}

- (void)cancelPressed:(id)sender {
    [self dismiss];
}

@end
