//
//  DialogAddressOptions.m
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

#import "DialogAddressOptions.h"
#import "NSString+Size.h"
#import "UserDefaultsUtil.h"
#import "DialogAddressAlias.h"
#import "DialogEditVanityLength.h"

#define kButtonHeight (44)
#define kButtonEdgeInsets (UIEdgeInsetsMake(0, 10, 0, 10))

#define kHeight (kButtonHeight * 3 + 2)

#define kFontSize (16)

@interface DialogAddressOptions () {
    NSString *_viewOnBlockChainInfoStr;
    BTAddress *_address;
}
@property(weak) NSObject <DialogAddressAliasDelegate> *aliasDelegate;
@end

@implementation DialogAddressOptions

- (instancetype)initWithAddress:(BTAddress *)address delegate:(NSObject <DialogAddressOptionsDelegate> *)delegate andAliasDialog:(NSObject <DialogAddressAliasDelegate> *)aliasDelegate {
    NSString *viewStr = NSLocalizedString(@"View on Blockchain.info", nil);
    NSString *manageStr = NSLocalizedString(@"private_key_management", nil);
    CGFloat width = MAX(MAX([viewStr sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, kButtonHeight) font:[UIFont systemFontOfSize:kFontSize]].width,
            [manageStr sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, kButtonHeight) font:[UIFont systemFontOfSize:kFontSize]].width),
            [NSLocalizedString(@"address_option_view_on_blockmeta", nil) sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, kButtonHeight) font:[UIFont systemFontOfSize:kFontSize]].width) +
            kButtonEdgeInsets.left + kButtonEdgeInsets.right;
    self = [super initWithFrame:CGRectMake(0, 0, width, kHeight)];
    if (self) {
        _viewOnBlockChainInfoStr = viewStr;
        _address = address;
        self.delegate = delegate;
        self.aliasDelegate = aliasDelegate;
        [self firstConfigureHasPrivateKey:address.hasPrivKey];
    }
    return self;
}

- (void)firstConfigureHasPrivateKey:(BOOL)hasPrivateKey {
    self.bgInsets = UIEdgeInsetsMake(4, 16, 4, 16);
    CGFloat bottom = 0;
    bottom = [self createButtonWithText:_viewOnBlockChainInfoStr top:bottom action:@selector(viewOnBlockChainInfoPressed:)];
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, self.frame.size.width, 1)];
    seperator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    seperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self addSubview:seperator];

    if ([UserDefaultsUtil instance].localeIsChina || [[UserDefaultsUtil instance] localeIsZHHant]) {
        bottom += 1;
        bottom = [self createButtonWithText:NSLocalizedString(@"address_option_view_on_blockmeta", nil) top:bottom action:@selector(viewOnBlockMetaPressed:)];
        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, self.frame.size.width, 1)];
        seperator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        seperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self addSubview:seperator];
    }

    if (hasPrivateKey) {
        bottom += 1;
        bottom = [self createButtonWithText:NSLocalizedString(@"private_key_management", nil) top:bottom action:@selector(privateKeyManagement:)];
        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, self.frame.size.width, 1)];
        seperator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        seperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self addSubview:seperator];

        bottom += 1;
        bottom = [self createButtonWithText:NSLocalizedString(@"sign_message_activity_name", nil) top:bottom action:@selector(signMessagePressed:)];
        seperator = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, self.frame.size.width, 1)];
        seperator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        seperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self addSubview:seperator];
    }

    if (self.aliasDelegate) {
        bottom += 1;
        bottom = [self createButtonWithText:NSLocalizedString(@"address_alias_manage", nil) top:bottom action:@selector(addressAlias:)];
        seperator = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, self.frame.size.width, 1)];
        seperator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        seperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self addSubview:seperator];
    }

    bottom += 1;
    bottom = [self createButtonWithText:NSLocalizedString(@"vanity_address_length", nil) top:bottom action:@selector(vanityLength:)];
    seperator = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, self.frame.size.width, 1)];
    seperator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    seperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self addSubview:seperator];

    if (!hasPrivateKey) {
        bottom += 1;
        bottom = [self createButtonWithText:NSLocalizedString(@"Stop Monitoring", nil) top:bottom action:@selector(stopMonitorPressed:)];
        seperator = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, self.frame.size.width, 1)];
        seperator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        seperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self addSubview:seperator];
    }

    bottom += 1;
    bottom = [self createButtonWithText:NSLocalizedString(@"Cancel", nil) top:bottom action:@selector(cancelPressed:)];
    CGRect frame = self.frame;
    frame.size.height = bottom;
    self.frame = frame;
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

- (void)vanityLength:(id)sender {
    __block UIWindow *w = self.window;
    [self dismissWithCompletion:^{
        [[[DialogEditVanityLength alloc] initWithAddress:_address] showInWindow:w];
    }];
}

- (void)addressAlias:(id)sender {
    __block UIWindow *w = self.window;
    [self dismissWithCompletion:^{
        [[[DialogAddressAlias alloc] initWithAddress:_address andDelegate:self.aliasDelegate] showInWindow:w];
    }];
}

- (void)viewOnBlockChainInfoPressed:(id)sender {
    [self dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(showAddressOnBlockChainInfo)]) {
            [self.delegate showAddressOnBlockChainInfo];
        }
    }];
}

- (void)viewOnBlockMetaPressed:(id)sender {
    [self dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(showAddressOnBlockMeta)]) {
            [self.delegate showAddressOnBlockMeta];
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

- (void)privateKeyManagement:(id)sender {
    [self dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(showPrivateKeyManagement)]) {
            [self.delegate showPrivateKeyManagement];
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

- (void)privateKeyQrCodePressed:(id)sender {
    [self dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(showPrivateKeyQrCode)]) {
            [self.delegate showPrivateKeyQrCode];
        }
    }];
}

- (void)cancelPressed:(id)sender {
    [self dismiss];
}

@end
