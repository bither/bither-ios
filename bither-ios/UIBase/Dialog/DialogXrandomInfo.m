//
//  DialogXrandomInfo.m
//  bither-ios
//
//  Created by noname on 14-9-29.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "DialogXrandomInfo.h"

#define kButtonFontSize (15)
#define kButtonHeight (36)
#define kInnerMargin (10)
#define kOuterPadding (26)

@interface DialogXrandomInfo () {
    CGFloat width;
}
@property BOOL guide;
@property(strong) void(^completion)();
@end

@implementation DialogXrandomInfo

- (instancetype)initWithGuide:(BOOL)guide {
    self = [self initWithGuide:guide andPermission:nil];
    return self;
}

- (instancetype)init {
    self = [self initWithGuide:NO];
    return self;
}

- (instancetype)initWithPermission:(void (^)())completion {
    self = [self initWithGuide:NO andPermission:completion];
    return self;
}

- (instancetype)initWithGuide:(BOOL)guide andPermission:(void (^)())completion {
    self = [super init];
    if (self) {
        self.guide = guide;
        self.completion = completion;
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.touchOutSideToDismiss = YES;
    width = [UIScreen mainScreen].bounds.size.width - kOuterPadding * 2 - self.bgInsets.left - self.bgInsets.right;
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xrandom_info_logo"]];
    iv.frame = CGRectMake((width - iv.frame.size.width) / 2, 0, iv.frame.size.width, iv.frame.size.height);

    UITextView *tv = [[UITextView alloc] initWithFrame:CGRectZero];
    tv.backgroundColor = [UIColor clearColor];
    tv.textColor = [UIColor whiteColor];
    tv.font = [UIFont systemFontOfSize:kButtonFontSize];
    tv.scrollEnabled = NO;
    tv.text = NSLocalizedString(@"xrandom_info_detail", nil);
    if (self.guide) {
        tv.text = [NSString stringWithFormat:@"%@%@", tv.text, NSLocalizedString(@"xrandom_info_guide", nil)];
    }
    CGSize tvSize = [tv sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    tv.frame = CGRectMake(0, CGRectGetMaxY(iv.frame) + kInnerMargin / 2, width, tvSize.height);

    UIButton *btnConfirm = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tv.frame) + kInnerMargin * 2, width, kButtonHeight)];
    [btnConfirm setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
    btnConfirm.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    if (self.completion) {
        [btnConfirm setTitle:NSLocalizedString(@"xrandom_info_get_permissions", nil) forState:UIControlStateNormal];
    } else {
        [btnConfirm setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    }
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

- (void)dialogDidDismiss {
    [super dialogDidDismiss];
    if (self.completion) {
        self.completion();
    }
}

@end
