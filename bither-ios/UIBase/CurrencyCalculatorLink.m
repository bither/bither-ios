//
//  CurrencyCalculatorLink.h
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
//

#import "CurrencyCalculatorLink.h"
#import "UserDefaultsUtil.h"
#import "UnitUtil.h"
#import "MarketUtil.h"

@interface CurrencyCalculatorLink () <UITextFieldDelegate> {
    __weak UITextField *_tfBtc;
    __weak UITextField *_tfCurrency;
    u_int64_t _amount;
}

@end

@implementation CurrencyCalculatorLink


- (void)firstConfigure {
    if (!self.tfBtc || !self.tfCurrency) {
        return;
    }
    self.tfBtc.delegate = self;
    self.tfCurrency.delegate = self;
    [self configureTextField:self.tfBtc];
    [self configureTextField:self.tfCurrency];

    [(UIButton *) self.tfBtc.rightView addTarget:self action:@selector(clearBtc:) forControlEvents:UIControlEventTouchUpInside];
    [(UIButton *) self.tfCurrency.rightView addTarget:self action:@selector(clearCurrency:) forControlEvents:UIControlEventTouchUpInside];

    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_black", [UnitUtil imageNameSlim]]]];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    iv.frame = CGRectMake(0, 9, self.tfBtc.leftView.frame.size.width, 16);
    [self.tfBtc.leftView addSubview:iv];

    NSString *symbol = [BitherSetting getCurrencySymbol:[[UserDefaultsUtil instance] getDefaultCurrency]];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 9, self.tfCurrency.leftView.frame.size.width, 18)];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.textColor = [UIColor blackColor];
    lbl.text = symbol;
    lbl.font = [UIFont systemFontOfSize:16];
    [self.tfCurrency.leftView addSubview:lbl];
}

- (void)setTfBtc:(UITextField *)tfBtc {
    _tfBtc = tfBtc;
    [self firstConfigure];
}

- (void)setTfCurrency:(UITextField *)tfCurrency {
    _tfCurrency = tfCurrency;
    [self firstConfigure];
}

- (void)configureTextField:(UITextField *)tf {
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, tf.frame.size.height)];
    leftView.backgroundColor = [UIColor clearColor];
    UIButton *rightView = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightView setImage:[UIImage imageNamed:@"ic_input_delete"] forState:UIControlStateNormal];
    [rightView setContentMode:UIViewContentModeLeft];
    [rightView sizeToFit];
    CGRect frame = rightView.frame;
    frame.size.width += 10;
    rightView.frame = frame;
    rightView.backgroundColor = [UIColor clearColor];
    tf.leftView = leftView;
    tf.rightView = rightView;
    tf.leftViewMode = UITextFieldViewModeAlways;
    tf.rightViewMode = UITextFieldViewModeWhileEditing;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length > 0 && [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        return NO;
    }
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSRange pointRange = [text rangeOfString:@"."];
    if ([self isInputingBtc]) {
        if (pointRange.length > 0 && text.length > (pointRange.location + 9)) {
            return NO;
        }
        if ([self isZeroText:text]) {
            if ([StringUtil isEmpty:self.tfCurrency.text]) {
                _amount = 0;
                [self convertAmount2Currency];
            }
        } else {
            u_int64_t amount = [UnitUtil amountForString:text];
            if (amount > 0) {
                _amount = amount;
                [self convertAmount2Currency];
            } else {
                return NO;
            }
        }
    } else {
        if (pointRange.length > 0 && text.length > (pointRange.location + 3)) {
            return NO;
        }
        if ([self isZeroText:text]) {
            if (pointRange.length > 0 && text.length > (pointRange.location + 2)) {
                return NO;
            }
            if ([StringUtil isEmpty:self.tfBtc.text]) {
                [self convertCurrency2Amount:0];
            }
        } else {
            double currency = [self getCurrencyFromText:text];
            if (currency <= 0) {
                return NO;
            }
            [self convertCurrency2Amount:currency];
        }
    }
    return YES;
}

- (void)convertAmount2Currency {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        [self.delegate textField:self.tfBtc shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:nil];
    }
    if (_amount > 0 || [StringUtil isEmpty:self.tfCurrency.text]) {
        self.tfCurrency.text = @"";
        self.tfBtc.placeholder = @"0.00";
        double price = [MarketUtil getDefaultNewPrice];
        if (price > 0) {
            double money = (price * _amount) / pow(10, 8);
            self.tfCurrency.placeholder = [NSString stringWithFormat:@"%.2f", money];
        }
    }
}

- (void)convertCurrency2Amount:(double)currency {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        [self.delegate textField:self.tfCurrency shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:nil];
    }
    if (currency > 0 || [StringUtil isEmpty:self.tfBtc.text]) {
        self.tfBtc.text = @"";
        self.tfCurrency.placeholder = @"0.00";
        double price = [MarketUtil getDefaultNewPrice];
        if (price > 0) {
            _amount = currency * pow(10, 8) / price;
            u_int32_t minimal = (u_int32_t) pow(10, 4);
            if (_amount > minimal) {
                u_int64_t extra = (_amount % minimal);
                if (extra < minimal / 2) {
                    _amount = _amount - extra;
                } else {
                    _amount = _amount - extra + minimal;
                }
            }
            self.tfBtc.placeholder = [UnitUtil stringForAmount:_amount];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.delegate textFieldDidEndEditing:textField];
    }
    if (![StringUtil isEmpty:self.tfBtc.text] && [UnitUtil amountForString:self.tfBtc.text] > 0) {
        _amount = [UnitUtil amountForString:self.tfBtc.text];
        [self convertAmount2Currency];
        return;
    }
    if (![StringUtil isEmpty:self.tfCurrency.text] && [self getCurrencyFromText:self.tfCurrency.text] > 0) {
        [self convertCurrency2Amount:[self getCurrencyFromText:self.tfCurrency.text]];
        return;
    }
    self.tfBtc.text = @"";
    self.tfCurrency.text = @"";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        [self.delegate textFieldShouldReturn:textField];
    }
    return YES;
}

- (u_int64_t)amount {
    return _amount;
}

- (void)setAmount:(u_int64_t)amount {
    _amount = amount;
    self.tfBtc.text = [UnitUtil stringForAmount:_amount];
    [self convertAmount2Currency];
}

- (double)getCurrencyFromText:(NSString *)text {
    NSNumberFormatter *format = [NSNumberFormatter new];
    format.numberStyle = NSNumberFormatterCurrencyStyle;
    format.lenient = YES;
    format.maximumFractionDigits = 2;
    return [[format numberFromString:text] doubleValue];
}

- (BOOL)isZeroText:(NSString *)text {
    if (text) {
        if ([text isEqualToString:@""] || [text isEqualToString:@"0"] || [text isEqualToString:@"."]) {
            return YES;
        }
        BOOL prefixedZero = NO;
        if ([text hasPrefix:@"0."]) {
            text = [text substringFromIndex:2];
            prefixedZero = YES;
        }
        if (!prefixedZero && [text hasPrefix:@"."]) {
            text = [text substringFromIndex:1];
            prefixedZero = YES;
        }
        if (prefixedZero) {
            for (int i = 0; i < text.length; i++) {
                if ([text characterAtIndex:i] != '0') {
                    return NO;
                }
            }
            return YES;
        }
    } else {
        return YES;
    }
    return NO;
}

- (void)becomeFirstResponder {
    if (self.tfBtc && ![StringUtil isEmpty:self.tfBtc.text]) {
        [self.tfBtc becomeFirstResponder];
        return;
    }
    if (self.tfCurrency && ![StringUtil isEmpty:self.tfCurrency.text]) {
        [self.tfCurrency becomeFirstResponder];
        return;
    }
    if (self.tfBtc) {
        [self.tfBtc becomeFirstResponder];
        return;
    }
}


- (BOOL)isFirstResponder {
    return (self.tfBtc && self.tfBtc.isFirstResponder) || (self.tfCurrency && self.tfCurrency.isFirstResponder);
}

- (void)resignFirstResponder {
    if (self.tfBtc) {
        [self.tfBtc resignFirstResponder];
    }
    if (self.tfCurrency) {
        [self.tfCurrency resignFirstResponder];
    }
}

- (BOOL)isLinked:(UITextField *)textField {
    if (textField == self.tfBtc) {
        return YES;
    }
    if (textField == self.tfCurrency) {
        return YES;
    }
    return NO;
}

- (BOOL)isInputingBtc {
    return self.tfBtc.isFirstResponder;
}

- (void)clearBtc:(id)sender {
    self.tfBtc.text = @"";
    _amount = 0;
    [self convertAmount2Currency];
}

- (void)clearCurrency:(id)sender {
    self.tfCurrency.text = @"";
    [self convertCurrency2Amount:0];
}

- (UITextField *)tfBtc {
    return _tfBtc;
}

- (UITextField *)tfCurrency {
    return _tfCurrency;
}
@end
