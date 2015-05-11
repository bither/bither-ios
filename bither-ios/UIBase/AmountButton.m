//
//  AmountButton.m
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

#import "AmountButton.h"
#import "StringUtil.h"
#import "MarketUtil.h"
#import "UnitUtil.h"
#import "NSString+Size.h"

#define kFontSize (15)
#define kButtonHeight (36)
#define kHorizontalPadding (10)
#define kSymbolMargin (2)

@interface AmountButton () {
    BOOL showMoney;
}
@property UIImageView *ivSymbol;
@end

@implementation AmountButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.backgroundColor = [UIColor clearColor];
    self.btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.btn.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.btn addTarget:self action:@selector(pressed:) forControlEvents:UIControlEventTouchUpInside];
    self.lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.lbl.backgroundColor = [UIColor clearColor];
    self.lbl.font = [UIFont systemFontOfSize:kFontSize];
    self.lbl.textAlignment = NSTextAlignmentCenter;
    self.lbl.textColor = [UIColor whiteColor];
    self.lbl.tintColor = self.lbl.textColor;
    self.lbl.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.ivSymbol = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[UnitUtil imageNameSlim]]];
    self.ivSymbol.frame = CGRectMake(kHorizontalPadding, (self.frame.size.height - kFontSize) / 2, kFontSize / self.ivSymbol.frame.size.height * self.ivSymbol.frame.size.width, kFontSize);
    [self addSubview:self.btn];
    [self addSubview:self.lbl];
    [self addSubview:self.ivSymbol];
}

- (void)setAmount:(uint64_t)amount {
    showMoney = NO;
    _amount = amount;
    [self show];
}

- (void)configureBg {
    if (![self belowZero]) {
        [self.btn setBackgroundImage:[UIImage imageNamed:@"button_small_green_normal"] forState:UIControlStateNormal];
        [self.btn setBackgroundImage:[UIImage imageNamed:@"button_small_green_pressed"] forState:UIControlStateHighlighted];
    } else {
        [self.btn setBackgroundImage:[UIImage imageNamed:@"button_small_red_normal"] forState:UIControlStateNormal];
        [self.btn setBackgroundImage:[UIImage imageNamed:@"button_small_red_pressed"] forState:UIControlStateHighlighted];
    }
}

- (void)show {
    NSString *str;
    if (showMoney) {
        double money = ([MarketUtil getDefaultNewPrice] * _amount) / pow(10, 8);
        str = [StringUtil formatPrice:money];
    } else {
        str = [UnitUtil stringForAmount:_amount];
    }
    CGFloat width = [str sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:self.lbl.font].width;
    width += kHorizontalPadding * 2;
    if (!showMoney) {
        width += self.ivSymbol.frame.size.width + kSymbolMargin;
    }
    self.lbl.text = str;
    [self configureBg];
    if (self.alignLeft) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, kButtonHeight);
    } else {
        self.frame = CGRectMake(self.frame.origin.x - width + self.frame.size.width, self.frame.origin.y, width, kButtonHeight);
    }
    CGRect frame = self.lbl.frame;
    if (showMoney) {
        self.ivSymbol.hidden = YES;
        frame.origin.x = kHorizontalPadding;
        frame.size.width = self.frame.size.width - kHorizontalPadding * 2;
    } else {
        self.ivSymbol.hidden = NO;
        frame.origin.x = kHorizontalPadding + kSymbolMargin + self.ivSymbol.frame.size.width;
        frame.size.width = self.frame.size.width - kHorizontalPadding * 2 - kSymbolMargin - self.ivSymbol.frame.size.width;
    }
    self.lbl.frame = frame;
    if (self.frameChangeListener && [self.frameChangeListener respondsToSelector:@selector(amountButtonFrameChanged:)]) {
        [self.frameChangeListener amountButtonFrameChanged:self.frame];
    }
    self.ivSymbol.image = [UIImage imageNamed:[UnitUtil imageNameSlim]];
}

- (void)pressed:(id)sender {
    if ([MarketUtil getDefaultNewPrice] > 0 || showMoney) {
        showMoney = !showMoney;
        [self show];
    }
}

- (BOOL)belowZero {
    return _amount < 0;
}

- (uint64_t)amount {
    return _amount;
}

@end
