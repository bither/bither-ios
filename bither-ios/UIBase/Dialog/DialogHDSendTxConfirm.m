//
//  DialogHDSendConfirm.m
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
//  Created by songchenwen on 15/4/28.
//

#import "DialogHDSendTxConfirm.h"
#import "UnitUtil.h"
#import "StringUtil.h"

#define kWidth (270)

#define kVerticalGap (5)

#define kLabelHeight (20)
#define kLabelFontSize (14)
#define kLabelAlpha (0.7f)

#define kValueHeight (40)
#define kValueFontSize (16)
#define kValueAlpha (1.0f)

#define kButtonTopGap (10)
#define kButtonHeight (40)
#define kButtonGap (20)
#define kButtonFontSize (16)


@interface DialogHDSendTxConfirm () {
    BTTx *_tx;
    NSString *_toAddress;
}
@end

@implementation DialogHDSendTxConfirm
- (instancetype)initWithTx:(BTTx *)tx to:(NSString *)toAddress delegate:(NSObject <DialogSendTxConfirmDelegate> *)delegate {
    self = [super initWithFrame:CGRectMake(0, 0, kWidth, 200)];
    if (self) {
        _tx = tx;
        _toAddress = toAddress;
        self.delegate = delegate;
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    NSString *toAddress = _toAddress;
    NSString *amountString = [UnitUtil stringForAmount:[_tx amountSentTo:_toAddress]];
    NSString *feeString = [UnitUtil stringForAmount:_tx.feeForTransaction];

    UILabel *lblPayto = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kLabelHeight)];
    lblPayto.font = [UIFont systemFontOfSize:kLabelFontSize];
    lblPayto.textColor = [UIColor colorWithWhite:1 alpha:kLabelAlpha];
    lblPayto.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    lblPayto.text = NSLocalizedString(@"You will send to:", nil);

    UILabel *lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lblPayto.frame), self.frame.size.width, kValueHeight)];
    lblAddress.font = [UIFont systemFontOfSize:kValueFontSize];
    lblAddress.textColor = [UIColor colorWithWhite:1 alpha:kValueAlpha];
    lblAddress.adjustsFontSizeToFitWidth = YES;
    lblAddress.lineBreakMode = UILineBreakModeTailTruncation;
    lblAddress.numberOfLines = 2;
    lblAddress.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    lblAddress.text = [StringUtil formatAddress:toAddress groupSize:4 lineSize:24];

    UILabel *lblAmount = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lblAddress.frame) + kVerticalGap, self.frame.size.width, kLabelHeight)];
    lblAmount.font = [UIFont systemFontOfSize:kLabelFontSize];
    lblAmount.textColor = [UIColor colorWithWhite:1 alpha:kLabelAlpha];
    lblAmount.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    lblAmount.text = NSLocalizedString(@"Amount:", nil);

    UILabel *lblAmountValue = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lblAmount.frame), self.frame.size.width, kValueHeight)];
    lblAmountValue.font = [UIFont systemFontOfSize:kValueFontSize];
    lblAmountValue.textColor = [UIColor colorWithWhite:1 alpha:kValueAlpha];
    lblAmountValue.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    lblAmountValue.text = [NSString stringWithFormat:@"%@ %@", amountString, [UnitUtil unitName]];

    CGFloat bottom = CGRectGetMaxY(lblAmountValue.frame);

    UILabel *lblFee = [[UILabel alloc] initWithFrame:CGRectMake(0, bottom + kVerticalGap, self.frame.size.width, kLabelHeight)];
    lblFee.font = [UIFont systemFontOfSize:kLabelFontSize];
    lblFee.textColor = [UIColor colorWithWhite:1 alpha:kLabelAlpha];
    lblFee.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    lblFee.text = NSLocalizedString(@"Fee:", nil);

    UILabel *lblFeeValue = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lblFee.frame), self.frame.size.width, kValueHeight)];
    lblFeeValue.font = [UIFont systemFontOfSize:kValueFontSize];
    lblFeeValue.textColor = [UIColor colorWithWhite:1 alpha:kValueAlpha];
    lblFeeValue.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    lblFeeValue.text = [NSString stringWithFormat:@"%@ %@", feeString, [UnitUtil unitName]];

    CGFloat buttonTop = CGRectGetMaxY(lblFeeValue.frame) + kButtonTopGap;
    CGFloat buttonWidth = (self.frame.size.width - kButtonGap) / 2;

    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, buttonTop, buttonWidth, kButtonHeight)];
    [btnCancel setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
    btnCancel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [btnCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(cancelPressed:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btnOk = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btnCancel.frame) + kButtonGap, buttonTop, buttonWidth, kButtonHeight)];
    [btnOk setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
    btnOk.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [btnOk setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [btnOk addTarget:self action:@selector(confirmPressed:) forControlEvents:UIControlEventTouchUpInside];

    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, CGRectGetMaxY(btnOk.frame));

    [self addSubview:lblPayto];
    [self addSubview:lblAddress];
    [self addSubview:lblAmount];
    [self addSubview:lblAmountValue];
    [self addSubview:lblFee];
    [self addSubview:lblFeeValue];
    [self addSubview:btnCancel];
    [self addSubview:btnOk];
}

- (void)confirmPressed:(id)sender {
    [self dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onSendTxConfirmed:)]) {
            [self.delegate onSendTxConfirmed:_tx];
        }
    }];
}

- (void)cancelPressed:(id)sender {
    [self dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onSendTxCanceled)]) {
            [self.delegate onSendTxCanceled];
        }
    }];
}
@end