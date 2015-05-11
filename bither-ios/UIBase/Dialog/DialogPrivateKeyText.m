//
//  DialogPrivateKeyText.m
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

#import "DialogPrivateKeyText.h"
#import "NSString+Size.h"
#import "StringUtil.h"

#define kButtonHeight (44)
#define kButtonEdgeInsets (UIEdgeInsetsMake(0, 10, 0, 10))

#define kHeight (kButtonHeight * 3 + 2)

#define kFontSize (16)

@interface DialogPrivateKeyText () {
    NSString *_privateKeyStr;
    CGSize _fontSize;
}
@end


@implementation DialogPrivateKeyText

- (instancetype)initWithPrivateKeyStr:(NSString *)str {
    _privateKeyStr = [StringUtil formatAddress:str groupSize:4 lineSize:16];
    _fontSize = [_privateKeyStr sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, kButtonHeight) font:[UIFont fontWithName:@"Courier New" size:kFontSize]];
    self = [super initWithFrame:CGRectMake(0, 0, _fontSize.width + kButtonEdgeInsets.left + kButtonEdgeInsets.right, kHeight)];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.bgInsets = UIEdgeInsetsMake(4, 16, 4, 16);
    CGFloat bottom = 0;
    bottom = [self createLabelWithText:_privateKeyStr top:bottom];
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, self.frame.size.width, 1)];
    seperator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    seperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self addSubview:seperator];
    bottom += 1;
    seperator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    seperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self addSubview:seperator];
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
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btn.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateHighlighted];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    return CGRectGetMaxY(btn.frame);
}


- (CGFloat)createLabelWithText:(NSString *)text top:(CGFloat)top {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, top, self.frame.size.width, _fontSize.height * 3)];
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont fontWithName:@"Courier New" size:kFontSize];
    label.textColor = [UIColor whiteColor];
    label.text = text;
    label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.numberOfLines = 4;
    [self addSubview:label];
    return CGRectGetMaxY(label.frame);
}

- (void)cancelPressed:(id)sender {
    [self dismiss];
}

- (void)dealloc {
    _privateKeyStr = @"";
}

@end
