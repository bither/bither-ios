//
//  DialogRCheckInfo.m
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

#import "DialogRCheckInfo.h"

#define kButtonFontSize (15)
#define kButtonHeight (36)
#define kInnerMargin (10)
#define kOuterPadding (26)

@interface DialogRCheckInfo () {
    CGFloat width;
}
@end

@implementation DialogRCheckInfo
- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.touchOutSideToDismiss = YES;
    width = [UIScreen mainScreen].bounds.size.width - kOuterPadding * 2 - self.bgInsets.left - self.bgInsets.right;
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rcheck_info_logo"]];
    iv.frame = CGRectMake((width - iv.frame.size.width) / 2, 0, iv.frame.size.width, iv.frame.size.height);

    UITextView *tv = [[UITextView alloc] initWithFrame:CGRectZero];
    tv.backgroundColor = [UIColor clearColor];
    tv.textColor = [UIColor whiteColor];
    tv.font = [UIFont systemFontOfSize:kButtonFontSize];
    tv.scrollEnabled = NO;
    tv.text = NSLocalizedString(@"rcheck_info", nil);
    CGSize tvSize = [tv sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    tv.frame = CGRectMake(0, CGRectGetMaxY(iv.frame) + kInnerMargin / 2, width, tvSize.height);

    UIButton *btnConfirm = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tv.frame) + kInnerMargin * 2, width, kButtonHeight)];
    [btnConfirm setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
    btnConfirm.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [btnConfirm setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnConfirm.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [btnConfirm addTarget:self action:@selector(confirmPressed:) forControlEvents:UIControlEventTouchUpInside];

    self.frame = CGRectMake(0, 0, width, CGRectGetMaxY(btnConfirm.frame));
    [self addSubview:iv];
    [self addSubview:tv];
    [self addSubview:btnConfirm];
}

- (void)confirmPressed:(id)sender {
    [self dismiss];
}
@end
