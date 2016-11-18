//
//  DialogAddressQrCopy.m
//  bither-ios
//
//  Created by 宋辰文 on 2016/11/3.
//  Copyright © 2016年 Bither. All rights reserved.
//

#import "DialogAddressQrCopy.h"
#import "UIImage+ImageWithColor.h"
#import "QRCodeThemeUtil.h"
#import "BTUtils.h"
#import "StringUtil.h"
#import "UnitUtil.h"
#import "NSString+Size.h"

#define kTitleMargin (10)
#define kTitleFontSize (16)

#define kAddressFontSize (16)
#define kAddressButtonPadding (4)

#define kAddressGroupSize (4)
#define kAddressLineSize (20)

@interface DialogAddressQrCopy()
@property NSString *address;
@property NSString *title;
@property UILabel *lblTitle;
@end

@implementation DialogAddressQrCopy

- (instancetype)initWithAddress:(NSString *)address andTitle:(NSString*) title {
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height)];
    if (self) {
        [self configureWithAddress:address andTitle: title];
    }
    return self;
}

- (void)configureWithAddress:(NSString *)address andTitle:(NSString*) title {
    self.touchOutSideToDismiss = NO;
    self.address = address;
    self.title = title;
    self.backgroundImage = [UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0]];
    self.bgInsets = UIEdgeInsetsMake(10, 0, 10, 0);
    self.dimAmount = 0.8f;
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - self.frame.size.width) / 2, self.frame.size.width, self.frame.size.width)];
    iv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    iv.image = [QRCodeThemeUtil qrCodeOfContent:address andSize:iv.frame.size.width withTheme:[QRCodeTheme black]];
    [self addSubview:iv];
    if (![BTUtils isEmpty:title]) {
        CGFloat titleHeight = [title sizeWithRestrict:CGSizeMake(self.frame.size.width - kTitleMargin * 2, CGFLOAT_MAX) font:[UIFont systemFontOfSize:kTitleFontSize]].height;
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(kTitleMargin, (iv.frame.origin.y - titleHeight) / 2, self.frame.size.width - kTitleMargin * 2, titleHeight)];
        self.lblTitle.backgroundColor = [UIColor clearColor];
        self.lblTitle.textColor = [UIColor whiteColor];
        self.lblTitle.font = [UIFont systemFontOfSize:kTitleFontSize];
        self.lblTitle.text = title;
        self.lblTitle.textAlignment = NSTextAlignmentCenter;
        self.lblTitle.numberOfLines = 0;
        [self addSubview:self.lblTitle];
    }
    
    UIButton *btnDismiss = [[UIButton alloc] initWithFrame:self.bounds];
    [btnDismiss setBackgroundImage:nil forState:UIControlStateNormal];
    [btnDismiss addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnDismiss];
    
    UILabel *lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 10)];
    lblAddress.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    lblAddress.textColor = [UIColor whiteColor];
    lblAddress.font = [UIFont fontWithName:@"Courier New" size:kAddressFontSize];
    lblAddress.backgroundColor = [UIColor clearColor];
    lblAddress.numberOfLines = 0;
    lblAddress.text = [StringUtil formatAddress:address groupSize:kAddressGroupSize lineSize:kAddressLineSize];
    [lblAddress sizeToFit];
    CGSize addressSize = lblAddress.frame.size;
    
    UIButton *btnAddress = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width - (addressSize.width + kAddressButtonPadding * 2)) / 2, iv.frame.origin.y + iv.frame.size.height + (self.frame.size.height - iv.frame.origin.y - iv.frame.size.height - (addressSize.height + kAddressButtonPadding * 2)) / 2, addressSize.width + kAddressButtonPadding * 2, addressSize.height + kAddressButtonPadding * 2)];
    btnAddress.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    btnAddress.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    btnAddress.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    [btnAddress setBackgroundImage:[UIImage imageNamed:@"card_foreground_pressed"] forState:UIControlStateHighlighted];
    [btnAddress setImage:[UIImage imageNamed:@"dropdown_ic_arrow_normal_holo_light"] forState:UIControlStateNormal];
    [btnAddress setImage:[UIImage imageNamed:@"dropdown_ic_arrow_pressed_holo_light"] forState:UIControlStateHighlighted];
    [btnAddress addTarget:self action:@selector(copyAddress) forControlEvents:UIControlEventTouchUpInside];
    
    lblAddress.frame = CGRectMake(btnAddress.frame.origin.x + kAddressButtonPadding, btnAddress.frame.origin.y + kAddressButtonPadding, addressSize.width, addressSize.height);
    
    [self addSubview:lblAddress];
    [self addSubview:btnAddress];
}

- (void)copyAddress {
    [UIPasteboard generalPasteboard].string = self.address;
    self.lblTitle.text = NSLocalizedString(@"Address copied.", nil);
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(resetTitle) withObject:nil afterDelay:0.8];
}

- (void)resetTitle {
    self.lblTitle.text = self.title;
}

@end
