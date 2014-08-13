//
//  CurrencyCaculatorLink.m
//  bither-ios
//
//  Created by noname on 14-8-13.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "CurrencyCaculatorLink.h"
#import "UserDefaultsUtil.h"
#import "BitherSetting.h"
#import "StringUtil.h"
#import "MarketUtil.h"

@interface CurrencyCaculatorLink()<UITextFieldDelegate>{
    __weak UITextField *_tfBtc;
    __weak UITextField *_tfCurrency;
    u_int64_t _amount;
}

@end
@implementation CurrencyCaculatorLink


-(void)firstConfigure{
    if(!self.tfBtc || !self.tfCurrency){
        return;
    }
    self.tfBtc.delegate = self;
    self.tfCurrency.delegate = self;
    [self configureTextField:self.tfBtc];
    [self configureTextField:self.tfCurrency];
    
    [(UIButton*)self.tfBtc.rightView addTarget:self action:@selector(clearBtc:) forControlEvents:UIControlEventTouchUpInside];
    [(UIButton*)self.tfCurrency.rightView addTarget:self action:@selector(clearCurrency:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView* iv = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"symbol_btc_slim_black"]];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    iv.frame = CGRectMake(0, 9, self.tfBtc.leftView.frame.size.width, 16);
    [self.tfBtc.leftView addSubview:iv];
    
    NSString* symbol = [BitherSetting getExchangeSymbol:[[UserDefaultsUtil instance] getDefaultExchangeType]];
    UILabel* lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 9, self.tfCurrency.leftView.frame.size.width, 18)];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.textColor = [UIColor blackColor];
    lbl.text = symbol;
    lbl.font = [UIFont systemFontOfSize:16];
    [self.tfCurrency.leftView addSubview:lbl];
    
    
}

-(void)setTfBtc:(UITextField *)tfBtc{
    _tfBtc = tfBtc;
    [self firstConfigure];
}

-(void)setTfCurrency:(UITextField *)tfCurrency{
    _tfCurrency = tfCurrency;
    [self firstConfigure];
}

-(void)configureTextField:(UITextField*)tf{
    UIView *leftView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, tf.frame.size.height)];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(string.length > 0 && [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0){
        return NO;
    }
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSRange pointRange = [text rangeOfString:@"."];
    if([self isInputingBtc]){
        if(pointRange.length > 0 && text.length > (pointRange.location + 9)){
            return NO;
        }
        if([self isZeroText:text]){
            _amount = 0;
        }else{
            u_int64_t amount = [StringUtil amountForString:text];
            if(amount > 0){
                _amount = amount;
                [self convertAmount2Currency];
            }else{
                return NO;
            }
        }
    }else{
        if(pointRange.length > 0 && text.length > (pointRange.location + 3)){
            return NO;
        }
        if([self isZeroText:text]){
            if(pointRange.length > 0 && text.length > (pointRange.location + 2)){
                return NO;
            }
        }else{
            double currency = [self getCurrencyFromText:text];
            if(currency <= 0){
                return NO;
            }
            [self convertCurrency2Amount:currency];
        }
    }
    return YES;
}

-(void)convertAmount2Currency{
    if(_amount <= 0){
        return;
    }
    self.tfCurrency.text = @"";
    if ([MarketUtil getDefaultNewPrice]>0) {
        double money=([MarketUtil getDefaultNewPrice]*_amount)/pow(10, 8);
        self.tfCurrency.placeholder = [StringUtil formatPrice:money];
    }
}

-(void)convertCurrency2Amount:(double)currency{
    self.tfBtc.text = @"";
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return YES;
}

-(u_int64_t)amount{
    return _amount;
}

-(void)setAmount:(u_int64_t)amount{
    _amount = amount;
}

-(double)getCurrencyFromText:(NSString*)text{
    NSNumberFormatter *format = [NSNumberFormatter new];
    format.numberStyle = NSNumberFormatterCurrencyStyle;
    format.lenient = YES;
    format.maximumFractionDigits = 2;
    return [[format numberFromString:text] doubleValue];
}

-(BOOL)isZeroText:(NSString*)text{
    if(text){
        if([text isEqualToString:@""] || [text isEqualToString:@"0"] || [text isEqualToString:@"."]){
            return YES;
        }
        BOOL prefixedZero = NO;
        if([text hasPrefix:@"0."]){
            text = [text substringFromIndex:2];
            prefixedZero = YES;
        }
        if(!prefixedZero && [text hasPrefix:@"."]){
            text = [text substringFromIndex:1];
            prefixedZero = YES;
        }
        if(prefixedZero){
            for(int i = 0; i < text.length; i++){
                if([text characterAtIndex:i] != '0'){
                    return NO;
                }
            }
            return YES;
        }
    }else{
        return YES;
    }
    return NO;
}

-(BOOL)isLinked:(UITextField*)textField{
    if(textField == self.tfBtc){
        return YES;
    }
    if(textField == self.tfCurrency){
        return YES;
    }
    return NO;
}

-(BOOL)isInputingBtc{
    return self.tfBtc.isFirstResponder;
}

-(void)clearBtc:(id)sender{
    self.tfBtc.text = @"";
}

-(void)clearCurrency:(id)sender{
    self.tfCurrency.text = @"";
}

-(UITextField*)tfBtc{
    return _tfBtc;
}

-(UITextField*)tfCurrency{
    return _tfCurrency;
}
@end
