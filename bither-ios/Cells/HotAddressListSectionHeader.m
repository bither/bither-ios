//
//  HotAddressListSectionHeader.m
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

#import <Bitheri/BTAddressManager.h>
#import "HotAddressListSectionHeader.h"
#import "UIImage+ImageWithColor.h"
#import "UIColor+Util.h"

#define kBackgroundColor (0xE1EBF2)
#define kBackgroundColorPressed (0xCEE2F5)

#define kFontSize (17)
#define kTextColor (0x0099cc)
#define kMargin (5)

#define kPadding (10)

@interface HotAddressListSectionHeader () {
    NSUInteger _section;
}

@end

@implementation HotAddressListSectionHeader

- (instancetype)initWithSize:(CGSize)size isHD:(BOOL)hd isHdMonitored:(BOOL)hdMonitored isHDM:(BOOL)hdm isPrivate:(BOOL)isPrivate section:(NSUInteger)section delegate:(NSObject <SectionHeaderPressedDelegate> *)delegate {
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        self.delegate = delegate;
        _section = section;
        BOOL folded = NO;
        if (delegate && [delegate respondsToSelector:@selector(isSectionFolded:)]) {
            folded = [delegate isSectionFolded:section];
        }
        [self isHD:hd isHdMonitored:hdMonitored isHDM:hdm isPrivate:isPrivate isFolded:folded];
    }
    return self;
}

- (void)isHD:(BOOL)isHD isHdMonitored:(BOOL)isHdMonitored isHDM:(BOOL)isHDM isPrivate:(BOOL)isPrivate isFolded:(BOOL)isFolded {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    btn.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor parseColor:kBackgroundColor]] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor parseColor:kBackgroundColorPressed]] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(pressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];

    UIImageView *ivIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_item_address_group_indicator"]];
    ivIndicator.frame = CGRectMake(kPadding, (self.frame.size.height - ivIndicator.frame.size.height) / 2, ivIndicator.frame.size.width, ivIndicator.frame.size.height);
    if (isFolded) {
        ivIndicator.transform = CGAffineTransformIdentity;
    } else {
        ivIndicator.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    ivIndicator.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:ivIndicator];

    UIImage *typeImage = nil;
    if (isHD || isHdMonitored) {
        typeImage = [UIImage imageNamed:@"address_type_hd"];
    } else if (isHDM) {
        typeImage = [UIImage imageNamed:@"address_type_hdm"];
    } else if (isPrivate) {
        typeImage = [UIImage imageNamed:@"address_type_private"];
    } else {
        typeImage = [UIImage imageNamed:@"address_type_watchonly"];
    }
    UIImageView *ivType = [[UIImageView alloc] initWithImage:typeImage];
    ivType.contentMode = UIViewContentModeCenter;
    ivType.frame = CGRectMake(self.frame.size.width - self.frame.size.height - kPadding, 0, self.frame.size.height, self.frame.size.height);
    ivType.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [self addSubview:ivType];

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxY(ivIndicator.frame) + kMargin, 0, self.frame.size.width - ivIndicator.frame.size.width - ivType.frame.size.width - kMargin * 2, self.frame.size.height)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.font = [UIFont systemFontOfSize:kFontSize];
    lbl.textColor = [UIColor parseColor:kTextColor];
    lbl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (isHD) {
        lbl.text = NSLocalizedString(@"address_group_hd", nil);
    } else if (isHdMonitored) {
        lbl.text = NSLocalizedString(@"hd_account_cold_address_list_label", nil);
    } else if (isHDM) {
        if ([BTAddressManager instance].hdmKeychain.isInRecovery) {
            lbl.text = NSLocalizedString(@"address_group_hdm_recovery", nil);
        } else {
            lbl.text = NSLocalizedString(@"address_group_hdm_hot", nil);
        }
    } else if (isPrivate) {
        lbl.text = NSLocalizedString(@"Hot Wallet Address", nil);
    } else {
        lbl.text = NSLocalizedString(@"Cold Wallet Address", nil);
    }
    [self addSubview:lbl];

    if (isHDM) {
        UIButton *btnHDMAdd = [[UIButton alloc] initWithFrame:ivType.frame];
        [btnHDMAdd setBackgroundImage:nil forState:UIControlStateNormal];
        [btnHDMAdd setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:0 alpha:0.1]] forState:UIControlStateHighlighted];
        [btnHDMAdd setImage:[UIImage imageNamed:@"hdm_button_add_address_normal"] forState:UIControlStateNormal];
        [btnHDMAdd addTarget:self action:@selector(hdmAddPressed:) forControlEvents:UIControlEventTouchUpInside];

        CGRect frame = btnHDMAdd.frame;
        frame.origin.x = frame.origin.x - frame.size.width;
        UIButton *btnHDMSeed = [[UIButton alloc] initWithFrame:frame];
        [btnHDMSeed setBackgroundImage:nil forState:UIControlStateNormal];
        [btnHDMSeed setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:0 alpha:0.1]] forState:UIControlStateHighlighted];
        [btnHDMSeed setImage:[UIImage imageNamed:@"hdm_button_seed_normal"] forState:UIControlStateNormal];
        [btnHDMSeed addTarget:self action:@selector(hdmSeedPressed:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:btnHDMAdd];
        [self addSubview:btnHDMSeed];
        ivType.hidden = YES;
    }
}

- (void)pressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sectionHeaderPressed:)]) {
        [self.delegate sectionHeaderPressed:_section];
    }
}

- (void)hdmAddPressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(hdmAddPressed)]) {
        [self.delegate hdmAddPressed];
    }
}

- (void)hdmSeedPressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(hdmSeedPressed)]) {
        [self.delegate hdmSeedPressed];
    }
}

@end
