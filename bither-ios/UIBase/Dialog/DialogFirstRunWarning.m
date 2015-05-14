//
//  DialogFirstRunWarning.m
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
//  Created by songchenwen on 15/5/14.
//

#import "DialogFirstRunWarning.h"
#import "UserDefaultsUtil.h"
#import "NSString+Size.h"

#define kIconSize (30)
#define kLeftGap (5)
#define kTitleHeight (36)
#define kTitleFontSize (19)
#define kLineTop (10)
#define kLineFontSize (15)
#define kButtonTop (10)
#define kButtonFontSize (16)
#define kButtonHeight (32)

@implementation DialogFirstRunWarning

- (instancetype)init {
    CGSize restricted = CGSizeMake(280, CGFLOAT_MAX);
    CGFloat width = [NSLocalizedString(@"first_run_dialog_title", nil) sizeWithRestrict:restricted font:[UIFont systemFontOfSize:kTitleFontSize]].width;
    CGFloat nextWidth = [NSLocalizedString(@"first_run_dialog_line_1", nil) sizeWithRestrict:restricted font:[UIFont systemFontOfSize:kLineFontSize]].width;
    width = MAX(width, nextWidth);
    nextWidth = [NSLocalizedString(@"first_run_dialog_line_2", nil) sizeWithRestrict:restricted font:[UIFont systemFontOfSize:kLineFontSize]].width;
    width = MAX(width, nextWidth);
    width = ceil(width);
    width += kIconSize + kLeftGap;
    CGFloat height = kTitleHeight + 1 + kLineTop + kIconSize * 2 + kButtonTop + kButtonHeight;
    self = [super initWithFrame:CGRectMake(0, 0, width, height)];
    if (self) {
        self.bgInsets = UIEdgeInsetsMake(16, 16, 16, 16);
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, (kTitleHeight - kIconSize) / 2, kIconSize, kIconSize)];
    iv.image = [UIImage imageNamed:@"first_run_dialog_icon"];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:iv];

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iv.frame) + kLeftGap, 0, self.frame.size.width - CGRectGetMaxX(iv.frame) - kLeftGap, kTitleHeight)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.font = [UIFont systemFontOfSize:kTitleFontSize];
    lbl.textColor = [UIColor whiteColor];
    lbl.text = NSLocalizedString(@"first_run_dialog_title", nil);
    [self addSubview:lbl];

    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lbl.frame), self.frame.size.width, 1)];
    v.backgroundColor = [UIColor whiteColor];
    [self addSubview:v];

    iv = [[UIImageView alloc] initWithFrame:CGRectMake(kLeftGap, CGRectGetMaxY(v.frame) + kLineTop, kIconSize, kIconSize)];
    iv.image = [UIImage imageNamed:@"first_run_dialog_dot"];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:iv];

    lbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iv.frame), CGRectGetMinY(iv.frame), self.frame.size.width - CGRectGetMaxX(iv.frame), iv.frame.size.height)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.font = [UIFont systemFontOfSize:kLineFontSize];
    lbl.textColor = [UIColor whiteColor];
    lbl.text = NSLocalizedString(@"first_run_dialog_line_1", nil);
    [self addSubview:lbl];

    iv = [[UIImageView alloc] initWithFrame:CGRectMake(kLeftGap, CGRectGetMaxY(lbl.frame), kIconSize, kIconSize)];
    iv.image = [UIImage imageNamed:@"first_run_dialog_dot"];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:iv];

    lbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iv.frame), CGRectGetMinY(iv.frame), self.frame.size.width - CGRectGetMaxX(iv.frame), iv.frame.size.height)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.font = [UIFont systemFontOfSize:kLineFontSize];
    lbl.textColor = [UIColor whiteColor];
    lbl.text = NSLocalizedString(@"first_run_dialog_line_2", nil);
    [self addSubview:lbl];

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lbl.frame) + kButtonTop, self.frame.size.width, kButtonHeight)];
    [btn setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [btn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [btn addTarget:self action:@selector(okPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
}

- (void)showInWindow:(UIWindow *)window completion:(void (^)())completion {
    if (![UserDefaultsUtil instance].firstRunDialogShown) {
        [super showInWindow:window completion:completion];
        [[UserDefaultsUtil instance] setFirstRunDialogShown:YES];
    }
}

- (void)okPressed:(id)sender{
    [self dismiss];
}

+ (void)show:(UIWindow *)window {
    if (![UserDefaultsUtil instance].firstRunDialogShown) {
        [[[DialogFirstRunWarning alloc] init] showInWindow:window];
    }
}
@end