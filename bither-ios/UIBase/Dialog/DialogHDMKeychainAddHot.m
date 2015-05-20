//
//  DialogHDMKeychainAddHot.m
//  bither-ios
//
//  Created by 宋辰文 on 15/2/2.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import "DialogHDMKeychainAddHot.h"
#import "NSString+Size.h"

#define kDialogAlertLabelMaxWidth 280
#define kDialogAlertLabelMaxHeight 200
#define kDialogAlertButtonFontSize 14
#define kDialogAlertMargin 5
#define kDialogAlertMinHeight 50
#define kDialogAlertHorizotalPadding 2
#define kDialogAlertVerticalPadding 2
#define kDialogAlertBtnWidthMin 80
#define kDialogAlertBtnHeightMin 36
#define kDialogAlertBtnDistance 10
#define kDialogAlertLabelAndBtnDistance 14
#define kDialogAlertLabelFontSize 16

@interface DialogHDMKeychainAddHot () {
    void(^block)(BOOL);

    BOOL xrandom;
    UIImage *imgXRandomChecked;
    UIImage *imgXRandomUnchecked;
}

@property(strong, nonatomic) UILabel *lbl;
@property(strong, nonatomic) UIButton *btnConfirm;
@property(strong, nonatomic) UIButton *btnCancel;
@end

@implementation DialogHDMKeychainAddHot

- (instancetype)initWithBlock:(void (^)(BOOL))b {
    self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
    if (self) {
        block = b;
        xrandom = YES;
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    imgXRandomChecked = [UIImage imageNamed:@"xrandom_checkbox_checked"];
    imgXRandomUnchecked = [UIImage imageNamed:@"xrandom_checkbox_normal"];
    CGSize constrainedSize = CGSizeMake(kDialogAlertLabelMaxWidth, kDialogAlertLabelMaxHeight);
    NSString *msg = NSLocalizedString(@"hdm_keychain_add_hot_confirm", nil);
    CGSize lableSize = [msg sizeWithRestrict:constrainedSize font:[UIFont systemFontOfSize:kDialogAlertLabelFontSize]];
    float minWidth = kDialogAlertHorizotalPadding * 2 + kDialogAlertBtnWidthMin * 2 + kDialogAlertBtnDistance;
    float width = fmaxf(minWidth, lableSize.width + kDialogAlertHorizotalPadding * 2);
    self.frame = CGRectMake(0, 0, width, lableSize.height + kDialogAlertVerticalPadding * 2 + kDialogAlertLabelAndBtnDistance * 2 + imgXRandomChecked.size.height + kDialogAlertBtnHeightMin);
    self.lbl = [[UILabel alloc] initWithFrame:CGRectMake(kDialogAlertHorizotalPadding, kDialogAlertVerticalPadding, self.frame.size.width - 2 * kDialogAlertHorizotalPadding, lableSize.height)];

    self.lbl.backgroundColor = [UIColor clearColor];
    self.lbl.font = [UIFont systemFontOfSize:kDialogAlertLabelFontSize];
    self.lbl.numberOfLines = 0;
    self.lbl.textColor = [UIColor whiteColor];
    self.lbl.textAlignment = NSTextAlignmentLeft;
    self.lbl.text = msg;

    UIImage *imageNormal = [UIImage imageNamed:@"dialog_btn_bg_normal"];
    imageNormal = [imageNormal resizableImageWithCapInsets:UIEdgeInsetsMake(imageNormal.size.height / 2, imageNormal.size.width / 2, imageNormal.size.height / 2, imageNormal.size.width / 2)];

    float btnWidth = (self.frame.size.width - kDialogAlertHorizotalPadding * 2 - kDialogAlertBtnDistance) / 2;

    self.btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(kDialogAlertHorizotalPadding, kDialogAlertVerticalPadding + self.lbl.frame.size.height + kDialogAlertLabelAndBtnDistance * 2 + imgXRandomChecked.size.height, btnWidth, kDialogAlertBtnHeightMin)];
    [self.btnCancel setBackgroundImage:imageNormal forState:UIControlStateNormal];
    [self.btnCancel setTitle:NSLocalizedString(@"Cancel", @"dialogAlertCancel") forState:UIControlStateNormal];
    [self.btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.btnCancel.adjustsImageWhenDisabled = YES;
    self.btnCancel.adjustsImageWhenHighlighted = YES;
    self.btnCancel.titleLabel.font = [UIFont boldSystemFontOfSize:kDialogAlertButtonFontSize];
    [self.btnCancel addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];

    self.btnConfirm = [[UIButton alloc] initWithFrame:CGRectMake(self.btnCancel.frame.origin.x + kDialogAlertBtnDistance + self.btnCancel.frame.size.width, self.btnCancel.frame.origin.y, btnWidth, kDialogAlertBtnHeightMin)];

    [self.btnConfirm setBackgroundImage:imageNormal forState:UIControlStateNormal];
    [self.btnConfirm setTitle:NSLocalizedString(@"OK", @"dialogAlertConfirm") forState:UIControlStateNormal];
    [self.btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.btnConfirm.adjustsImageWhenDisabled = YES;
    self.btnConfirm.adjustsImageWhenHighlighted = YES;
    self.btnConfirm.titleLabel.font = [UIFont boldSystemFontOfSize:kDialogAlertButtonFontSize];
    [self.btnConfirm addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btnXRandom = [[UIButton alloc] initWithFrame:CGRectMake(kDialogAlertHorizotalPadding, CGRectGetMaxY(self.lbl.frame) + kDialogAlertLabelAndBtnDistance, imgXRandomChecked.size.width, imgXRandomChecked.size.height)];
    [btnXRandom setImage:imgXRandomChecked forState:UIControlStateNormal];
    btnXRandom.adjustsImageWhenHighlighted = YES;
    [btnXRandom addTarget:self action:@selector(xrandomPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.btnConfirm];
    [self addSubview:self.btnCancel];
    [self addSubview:btnXRandom];
    [self addSubview:self.lbl];
}

- (void)xrandomPressed:(UIButton *)sender {
    xrandom = !xrandom;
    if (xrandom) {
        [sender setImage:imgXRandomChecked forState:UIControlStateNormal];
    } else {
        [sender setImage:imgXRandomUnchecked forState:UIControlStateNormal];
    }
}

- (void)confirm:(id)sender {
    [self dismissWithCompletion:^{
        block(xrandom);
    }];
}

@end
