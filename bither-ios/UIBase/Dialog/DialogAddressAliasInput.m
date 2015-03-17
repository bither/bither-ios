//
//  DialogAddressAliasInput.m
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
//  Created by songchenwen on 2015/3/16.
//

#import <Bitheri/BTUtils.h>
#import "DialogAddressAliasInput.h"
#import "BTAddress.h"
#import "KeyboardController.h"
#import "DialogAlert.h"

#define kOuterPadding (1)
#define kInnerMargin (10)
#define kWidth (240)

#define kTextFieldFontSize (14)
#define kTextFieldHeight (35)
#define kTextFieldHorizontalMargin (10)

#define kButtonFontSize (15)
#define kButtonHeight (36)

#define kTitleFontSize (18)
#define kTitleHeight (20)

@interface DialogAddressAliasInput () <KeyboardControllerDelegate, UITextFieldDelegate> {
    BTAddress *address;
}
@property(weak) NSObject <DialogAddressAliasDelegate> *delegate;
@property KeyboardController *kc;
@property UITextField *tf;
@end

@implementation DialogAddressAliasInput
- (instancetype)initWithAddress:(BTAddress *)a andDelegate:(NSObject <DialogAddressAliasDelegate> *)delegate {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        address = a;
        self.delegate = delegate;
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.frame = CGRectMake(0, 0, kWidth, kOuterPadding * 2 + kTitleHeight + kTextFieldHeight + kButtonHeight + kInnerMargin * 2);
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(kOuterPadding, kOuterPadding, kWidth - kOuterPadding * 2, kTitleHeight)];
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont systemFontOfSize:kTitleFontSize];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    lbl.text = NSLocalizedString(@"address_alias_input_label", nil);
    [self addSubview:lbl];

    self.tf = [[UITextField alloc] initWithFrame:CGRectMake(kOuterPadding, CGRectGetMaxY(lbl.frame) + kInnerMargin, kWidth - kOuterPadding * 2, kTextFieldHeight)];
    NSString *holderString = NSLocalizedString(@"address_alias_input_hint", nil);
    self.tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:holderString attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:0.5]}];
    [self configureTextField:self.tf];
    self.tf.returnKeyType = UIReturnKeyDone;
    self.tf.delegate = self;
    [self addSubview:self.tf];

    CGFloat buttonTop = CGRectGetMaxY(self.tf.frame) + kInnerMargin;

    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(kOuterPadding, buttonTop, (kWidth - kOuterPadding * 2 - kInnerMargin) / 2, kButtonHeight)];
    [btnCancel setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [btnCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnCancel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [btnCancel addTarget:self action:@selector(cancelPressed:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btnConfirm = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btnCancel.frame) + kInnerMargin, buttonTop, (kWidth - kOuterPadding * 2 - kInnerMargin) / 2, kButtonHeight)];
    [btnConfirm setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
    btnConfirm.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [btnConfirm setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnConfirm.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [btnConfirm addTarget:self action:@selector(confirmPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:btnCancel];
    [self addSubview:btnConfirm];
}

- (void)confirmPressed:(id)sender {
    __block UIWindow *w = self.window;
    if (![BTUtils isEmpty:self.tf.text]) {
        if (self.delegate) {
            [self.delegate onAddressAliasChanged:address alias:self.tf.text];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [address updateAlias:self.tf.text];
        });
        [self dismiss];
    } else {
        [self dismissWithCompletion:^{
            [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"address_alias_remove_confirm", nil) confirm:^{
                if (self.delegate) {
                    [self.delegate onAddressAliasChanged:address alias:nil];
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [address removeAlias];
                });
            }                              cancel:nil] showInWindow:w];
        }];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger oriLength = textField.text.length;
    if (oriLength + string.length - range.length > 20) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self confirmPressed:nil];
    return NO;
}

- (void)cancelPressed:(id)sender {
    [self dismiss];
}

- (void)dialogWillShow {
    self.kc = [[KeyboardController alloc] initWithDelegate:self];
    self.tf.text = address.alias;
    [super dialogWillShow];
}

- (void)dialogDidDismiss {
    [super dialogDidDismiss];
    self.kc = nil;
}

- (void)dialogWillDismiss {
    if ([self.tf isFirstResponder]) {
        [self.tf resignFirstResponder];
    }
    [super dialogWillDismiss];
}

- (void)dialogDidShow {
    [super dialogDidShow];
    [self.tf becomeFirstResponder];
}

- (void)keyboardFrameChanged:(CGRect)frame {
    CGFloat totalHeight = frame.origin.y;
    CGFloat top = (totalHeight - self.frame.size.height) / 2;
    self.frame = CGRectMake(self.frame.origin.x, top, self.frame.size.width, self.frame.size.height);
}

- (void)configureTextField:(UITextField *)tf {
    tf.textColor = [UIColor whiteColor];
    tf.background = [UIImage imageNamed:@"textfield_activated_holo_light"];
    tf.delegate = self;
    tf.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    tf.font = [UIFont systemFontOfSize:kTextFieldFontSize];
    tf.borderStyle = UITextBorderStyleNone;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kTextFieldHorizontalMargin, tf.frame.size.height)];
    leftView.backgroundColor = [UIColor clearColor];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kTextFieldHorizontalMargin, tf.frame.size.height)];
    rightView.backgroundColor = [UIColor clearColor];
    tf.leftView = leftView;
    tf.rightView = rightView;
    tf.leftViewMode = UITextFieldViewModeAlways;
    tf.rightViewMode = UITextFieldViewModeAlways;
    tf.enablesReturnKeyAutomatically = YES;
    tf.keyboardType = UIKeyboardTypeASCIICapable;
}
@end