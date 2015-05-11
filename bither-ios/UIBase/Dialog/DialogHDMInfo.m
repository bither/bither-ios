//
//  DialogHDMInfo.m
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
//  Created by songchenwen on 15/2/3.
//

#import "DialogHDMInfo.h"

#define kTitleHorizontalOffset (-8)
#define kTitleFontSizeRate (0.5)
#define kTitleMargin (6)
#define kVerticalMargin (0)
#define kButtonTop (16)
#define kButtonHeight (36)
#define kButtonHorizontalMargin (10)
#define kButtonFontSize (14)
#define kNoteFontSize (14)
#define kMinHorizontalGap (30)

@implementation DialogHDMInfo
- (instancetype)init {
    UIImage *img = [UIImage imageNamed:@"hdm_label"];
    NSString *note = NSLocalizedString(@"hdm_seed_generation_notice", nil);
    UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(0, img.size.height + kVerticalMargin, [UIScreen mainScreen].bounds.size.width - kMinHorizontalGap * 2, 0)];
    tv.textColor = [UIColor whiteColor];
    tv.font = [UIFont systemFontOfSize:kNoteFontSize];
    tv.scrollEnabled = NO;
    tv.backgroundColor = [UIColor clearColor];
    tv.text = note;
    CGSize noteSize = [tv sizeThatFits:CGSizeMake(tv.frame.size.width, CGFLOAT_MAX)];
    self = [super initWithFrame:CGRectMake(0, 0, noteSize.width, img.size.height + kVerticalMargin + noteSize.height + kButtonTop + kButtonHeight)];
    if (self) {
        UIImageView *iv = [[UIImageView alloc] initWithImage:img];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, img.size.height)];
        lbl.textColor = [UIColor whiteColor];
        lbl.text = @"HDM";
        lbl.font = [UIFont systemFontOfSize:img.size.height * kTitleFontSizeRate];
        CGFloat titleWidth = [lbl sizeThatFits:CGSizeMake(CGFLOAT_MAX, img.size.height)].width;
        CGFloat titleTotalWidth = iv.frame.size.width + titleWidth + kTitleMargin;
        CGRect frame = iv.frame;
        frame.origin.x = (self.frame.size.width - titleTotalWidth) / 2 + kTitleHorizontalOffset;
        iv.frame = frame;
        frame = lbl.frame;
        frame.origin.x = CGRectGetMaxX(iv.frame) + kTitleMargin;
        frame.size.width = titleWidth;
        lbl.frame = frame;
        frame = tv.frame;
        frame.size.height = noteSize.height;
        tv.frame = frame;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(kButtonHorizontalMargin, CGRectGetMaxY(tv.frame) + kButtonTop, self.frame.size.width - kButtonHorizontalMargin * 2, kButtonHeight)];
        [btn setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
        [btn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
        [btn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:iv];
        [self addSubview:lbl];
        [self addSubview:tv];
        [self addSubview:btn];
    }
    return self;
}
@end