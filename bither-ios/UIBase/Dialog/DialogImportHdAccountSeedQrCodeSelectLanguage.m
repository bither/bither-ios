//
//  DialogImportHdAccountSeedQrCodeSelectLanguage.m
//  bither-ios
//
//  Created by 韩珍珍 on 2022/9/26.
//  Copyright © 2022 Bither. All rights reserved.
//

#import "DialogImportHdAccountSeedQrCodeSelectLanguage.h"
#import "StringUtil.h"
#import "UIColor+Util.h"
#import "DialogAlert.h"
#import "UnitUtil.h"
#import "UIImage+ImageWithColor.h"
#import "BTWordsTypeManager.h"

#define kCellBackgroundColor (0x262626)
#define kCellBackgroundColorPressed (0x212121)
#define kButtonHeight (44)
#define kCellHeight (50)
#define kPadding (15)
#define kButtonEdgeInsets (UIEdgeInsetsMake(0, 15, 0, 15))
#define kWidth ([UIScreen mainScreen].bounds.size.width * 0.8f)
#define kHeaderHeight (44)
#define kMaxHeight (250)
#define kFontSize (15)

@interface DialogImportHdAccountSeedQrCodeSelectLanguage () { }


@end

@implementation DialogImportHdAccountSeedQrCodeSelectLanguage

- (instancetype)initWithDelegate:(NSObject <DialogImportHdAccountSeedQrCodeSelectLanguageDelegate> *)delegate {
    self = [super initWithFrame:CGRectMake(0, 0, kWidth, kMaxHeight)];
    if (self) {
        self.delegate = delegate;
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.bgInsets = UIEdgeInsetsMake(kPadding, 0, kPadding, 0);
    self.backgroundImage = [UIImage imageNamed:@"dialog_sign_message_bg"];
    CGFloat y = 0;
    UILabel *lblTop = [[UILabel alloc] initWithFrame:CGRectMake(kPadding, y, self.frame.size.width, kHeaderHeight)];
    lblTop.textColor = [UIColor whiteColor];
    lblTop.font = [UIFont systemFontOfSize:kFontSize];
    lblTop.text = NSLocalizedString(@"hd_account_seed_language_select_title", nil);
    lblTop.backgroundColor = [UIColor clearColor];
    lblTop.textAlignment = NSTextAlignmentCenter;
    lblTop.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:lblTop];
    
    y = kHeaderHeight;
    UIButton *btnEn = [[UIButton alloc] initWithFrame:CGRectMake(kPadding, y, self.frame.size.width - kPadding * 2, kCellHeight)];
    [btnEn setBackgroundImage:[UIImage imageWithColor:[UIColor parseColor:kCellBackgroundColorPressed]] forState:UIControlStateHighlighted];
    [btnEn addTarget:self action:@selector(enPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnEn setTitle:NSLocalizedString(@"hd_account_seed_language_select_en", nil) forState:UIControlStateNormal];
    btnEn.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
    [btnEn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnEn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btnEn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:btnEn];

    CGFloat lineHeight = 0.5;
    y = y + kCellHeight;
    UIView *vEnLine = [[UIView alloc] initWithFrame:CGRectMake(kPadding, y, self.frame.size.width - kPadding * 2, lineHeight)];
    vEnLine.backgroundColor = [UIColor r:117 g:117 b:117];
    vEnLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:vEnLine];
    
    y = y + lineHeight;
    UIButton *btnZhCn = [[UIButton alloc] initWithFrame:CGRectMake(kPadding, y, self.frame.size.width - kPadding * 2, kCellHeight)];
    [btnZhCn setBackgroundImage:[UIImage imageWithColor:[UIColor parseColor:kCellBackgroundColorPressed]] forState:UIControlStateHighlighted];
    [btnZhCn addTarget:self action:@selector(zhCnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnZhCn setTitle:NSLocalizedString(@"hd_account_seed_language_select_zh_cn", nil) forState:UIControlStateNormal];
    btnZhCn.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
    [btnZhCn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnZhCn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btnZhCn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:btnZhCn];

    y = y + kCellHeight;
    UIView *vZhCnLine = [[UIView alloc] initWithFrame:CGRectMake(kPadding, y, self.frame.size.width - kPadding * 2, lineHeight)];
    vZhCnLine.backgroundColor = [UIColor r:117 g:117 b:117];
    vZhCnLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:vZhCnLine];
    
    y = y + lineHeight;
    UIButton *btnZhTw = [[UIButton alloc] initWithFrame:CGRectMake(kPadding, y, self.frame.size.width - kPadding * 2, kCellHeight)];
    [btnZhTw setBackgroundImage:[UIImage imageWithColor:[UIColor parseColor:kCellBackgroundColorPressed]] forState:UIControlStateHighlighted];
    [btnZhTw addTarget:self action:@selector(zhTwPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnZhTw setTitle:NSLocalizedString(@"hd_account_seed_language_select_zh_tw", nil) forState:UIControlStateNormal];
    btnZhTw.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
    [btnZhTw setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnZhTw.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btnZhTw.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:btnZhTw];
    
    y = y + kCellHeight;
    UIView *vZhTwLine = [[UIView alloc] initWithFrame:CGRectMake(kPadding, y, self.frame.size.width - kPadding * 2, lineHeight)];
    vZhTwLine.backgroundColor = [UIColor r:117 g:117 b:117];
    vZhTwLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:vZhTwLine];
    
    y = y + lineHeight;
    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(kPadding, y, self.frame.size.width - kPadding * 2, kCellHeight)];
    [btnCancel setBackgroundImage:[UIImage imageWithColor:[UIColor parseColor:kCellBackgroundColorPressed]] forState:UIControlStateHighlighted];
    [btnCancel addTarget:self action:@selector(cancelPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnCancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btnCancel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:btnCancel];
    
}

- (void)enPressed:(id)sender {
    if (self.delegate) {
        [self.delegate selectLanguage:[BTWordsTypeManager getWordsTypeValue:EN_WORDS]];
    }
    [self dismiss];
}

- (void)zhCnPressed:(id)sender {
    if (self.delegate) {
        [self.delegate selectLanguage:[BTWordsTypeManager getWordsTypeValue:ZHCN_WORDS]];
    }
    [self dismiss];
}

- (void)zhTwPressed:(id)sender {
    if (self.delegate) {
        [self.delegate selectLanguage:[BTWordsTypeManager getWordsTypeValue:ZHTW_WORDS]];
    }
    [self dismiss];
}

- (void)cancelPressed:(id)sender {
    [self dismiss];
}

@end
