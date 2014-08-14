//
//  CurrencyCaculatorLink.h
//  bither-ios
//
//  Created by noname on 14-8-13.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrencyCalculatorLink : NSObject<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfBtc;
@property (weak, nonatomic) IBOutlet UITextField *tfCurrency;
@property (weak, nonatomic) NSObject<UITextFieldDelegate>* delegate;
@property u_int64_t amount;
-(BOOL)isLinked:(UITextField*)textField;
-(void)becomeFirstResponder;
-(BOOL)isFirstResponder;
-(void)resignFirstResponder;
@end
