//
//  DialogEditVanityLength.m
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
//  Created by songchenwen on 15/5/7.
//

#import <Bitheri/BTAddress.h>
#import "DialogEditVanityLength.h"
#import "NSString+Size.h"
#import "UIColor+Util.h"

#define kPickerHeight (160)
#define kVerticalGap (10)
#define kMinWidth (240)
#define kMaxWidth (280)
#define kTitleHeight (20)
#define kTitleFontSize (17)
#define kLabelAddressHeight (15)
#define kLabelAddressFontSize (13)
#define kVanityAddressGlowColor (0x00bbff)
#define kVanityAddressTextColor (0xd8f5ff)
#define kButtonFontSize (15)
#define kButtonHeight (36)

@interface DialogEditVanityLength () <UIPickerViewDataSource, UIPickerViewDelegate> {
    NSInteger currentLength;
    NSMutableAttributedString *attr;
    NSDictionary *attributs;
}
@property UIPickerView *pvLength;
@property UILabel *lblAddress;
@property BTAddress *address;
@end

@implementation DialogEditVanityLength

- (instancetype)initWithAddress:(BTAddress *)address {
    CGSize labelSize = [address.address sizeWithRestrict:CGSizeMake(kMaxWidth, CGFLOAT_MAX) font:[UIFont boldSystemFontOfSize:kLabelAddressFontSize]];
    self = [super initWithFrame:CGRectMake(0, 0, MAX(ceil(labelSize.width), kMinWidth), kLabelAddressHeight + kTitleHeight + kPickerHeight + kButtonHeight + kVerticalGap * 3)];
    if (self) {
        self.address = address;
        currentLength = 0;
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kTitleHeight)];
    lblTitle.text = NSLocalizedString(@"vanity_address_length", nil);
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.font = [UIFont systemFontOfSize:kTitleFontSize];
    lblTitle.backgroundColor = [UIColor clearColor];
    [self addSubview:lblTitle];

    self.lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lblTitle.frame) + kVerticalGap, self.frame.size.width, kLabelAddressHeight)];
    self.lblAddress.textColor = [UIColor whiteColor];
    self.lblAddress.font = [UIFont boldSystemFontOfSize:kLabelAddressFontSize];
    self.lblAddress.backgroundColor = [UIColor clearColor];
    [self addSubview:self.lblAddress];

    self.pvLength = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lblAddress.frame) + kVerticalGap, self.frame.size.width, kPickerHeight)];
    self.pvLength.backgroundColor = [UIColor clearColor];
    self.pvLength.dataSource = self;
    self.pvLength.delegate = self;

    UIView *g = [[UIView alloc] initWithFrame:self.pvLength.frame];
    g.backgroundColor = [UIColor clearColor];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = g.bounds;
    gradientLayer.colors = @[(id) [UIColor colorWithWhite:0.1 alpha:1].CGColor,
            (id) [UIColor colorWithWhite:0.6 alpha:1].CGColor,
            (id) [UIColor whiteColor].CGColor,
            (id) [UIColor whiteColor].CGColor,
            (id) [UIColor colorWithWhite:0.6 alpha:1].CGColor,
            (id) [UIColor colorWithWhite:0.1 alpha:1].CGColor];
    [g.layer addSublayer:gradientLayer];

    [self addSubview:g];
    [self addSubview:self.pvLength];

    CGFloat buttonTop = CGRectGetMaxY(self.pvLength.frame) + kVerticalGap;

    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, buttonTop, (self.frame.size.width - kVerticalGap) / 2, kButtonHeight)];
    [btnCancel setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [btnCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnCancel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [btnCancel addTarget:self action:@selector(cancelPressed:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btnConfirm = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btnCancel.frame) + kVerticalGap, buttonTop, (self.frame.size.width - kVerticalGap) / 2, kButtonHeight)];
    [btnConfirm setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
    btnConfirm.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [btnConfirm setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnConfirm.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [btnConfirm addTarget:self action:@selector(confirmPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:btnCancel];
    [self addSubview:btnConfirm];

    NSInteger length = self.address.vanityLen;
    [self.pvLength selectRow:(length > 0 ? MAX(length - 1, 0) : 0) inComponent:0 animated:NO];
    [self showVanityLength:length];
}

- (void)showVanityLength:(NSInteger)length {
    length = MAX(length, 0);
    if (length <= 0) {
        self.lblAddress.attributedText = nil;
        self.lblAddress.text = self.address.address;
        currentLength = length;
        return;
    }
    if (currentLength == length) {
        return;
    }
    if (!attr) {
        attr = [[NSMutableAttributedString alloc] initWithString:self.address.address attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:kLabelAddressFontSize]}];
    }
    if (!attributs) {
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowBlurRadius = 6;
        shadow.shadowOffset = CGSizeZero;
        shadow.shadowColor = [UIColor parseColor:kVanityAddressGlowColor];
        UIColor *color = [UIColor parseColor:kVanityAddressTextColor];
        attributs = @{NSShadowAttributeName : shadow, NSForegroundColorAttributeName : color};
    }

    [attr beginEditing];
    [attr removeAttribute:NSShadowAttributeName range:NSMakeRange(0, self.address.address.length)];
    [attr removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, self.address.address.length)];
    [attr addAttributes:attributs range:NSMakeRange(0, length)];
    [attr endEditing];

    self.lblAddress.text = nil;
    self.lblAddress.attributedText = attr;

    currentLength = length;
}

- (void)updateText {
    NSInteger selected = [self.pvLength selectedRowInComponent:0];
    [self showVanityLength:[self lengthForPickerIndex:selected]];
}

- (NSInteger)lengthForPickerIndex:(NSInteger)index {
    if (index > 0) {
        return MIN(index + 1, self.address.address.length);
    }
    return 0;
}

- (void)confirmPressed:(id)sender {
    NSInteger length = [self lengthForPickerIndex:[self.pvLength selectedRowInComponent:0]];
    if (length > 0) {
        [self.address updateVanityLen:length];
    } else {
        [self.address removeVanity];
    }
    [self dismiss];
}

- (void)cancelPressed:(id)sender {
    [self dismiss];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self updateText];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSInteger length = [self lengthForPickerIndex:row];
    [self pickerView:pickerView didSelectRow:[pickerView selectedRowInComponent:component] inComponent:component];
    if (length > 0) {
        return [NSString stringWithFormat:@"%ld", (long) length];
    }
    return NSLocalizedString(@"vanity_address_none", nil);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.address.address.length;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

@end
