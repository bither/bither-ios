//
//  DialogBlackQrCode.m
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

#import "DialogBlackQrCode.h"
#import "UIImage+ImageWithColor.h"
#import "QRCodeThemeUtil.h"
#import "BTUtils.h"
#import "NSString+Size.h"

#define kTitleMargin (10)
#define kTitleFontSize (16)

@implementation DialogBlackQrCode

- (instancetype)initWithContent:(NSString *)content andTitle:(NSString *)title {
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
    if (self) {
        [self configureWithContent:content andTitle:title];
    }
    return self;
}

- (instancetype)initWithContent:(NSString *)content {
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
    if (self) {
        [self configureWithContent:content andTitle:nil];
    }
    return self;
}

- (void)configureWithContent:(NSString *)content andTitle:(NSString *)title {
    self.backgroundImage = [UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0]];
    self.bgInsets = UIEdgeInsetsMake(10, 0, 10, 0);
    self.dimAmount = 0.8f;
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)];
    iv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    iv.image = [QRCodeThemeUtil qrCodeOfContent:content andSize:iv.frame.size.width withTheme:[QRCodeTheme black]];
    [self addSubview:iv];
    if (![BTUtils isEmpty:title]) {
        CGFloat titleHeight = [title sizeWithRestrict:CGSizeMake(self.frame.size.width - kTitleMargin * 2, CGFLOAT_MAX) font:[UIFont systemFontOfSize:kTitleFontSize]].height;
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(kTitleMargin, -(([UIScreen mainScreen].bounds.size.height - iv.frame.size.height) / 2 - titleHeight) / 2, self.frame.size.width - kTitleMargin * 2, titleHeight)];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.textColor = [UIColor whiteColor];
        lblTitle.font = [UIFont systemFontOfSize:kTitleFontSize];
        lblTitle.text = title;
        lblTitle.textAlignment = NSTextAlignmentCenter;
        lblTitle.numberOfLines = 0;
        [self addSubview:lblTitle];
    }
    UIButton *btnDismiss = [[UIButton alloc] initWithFrame:iv.frame];
    [btnDismiss setBackgroundImage:nil forState:UIControlStateNormal];
    [btnDismiss addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnDismiss];
}
@end
