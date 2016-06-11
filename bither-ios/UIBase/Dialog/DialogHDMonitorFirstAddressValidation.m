//
//  DialogHDMonitorFirstAddressValidation.m
//  bither-ios
//
//  Created by 宋辰文 on 16/6/11.
//  Copyright © 2016年 Bither. All rights reserved.
//

#import "DialogHDMonitorFirstAddressValidation.h"
#import "NSString+Size.h"
#import "StringUtil.h"

#define kButtonHeight (44)
#define kButtonEdgeInsets (UIEdgeInsetsMake(0, 10, 0, 10))
#define kVerticalMargin (10)
#define kFontSize (16)

@implementation DialogHDMonitorFirstAddressValidation

-(instancetype)initWithAddress:(NSString*)address{
    address = [StringUtil formatAddress:address groupSize:4 lineSize:16];
    CGSize size = [address sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:[UIFont fontWithName:@"Courier New" size:kFontSize]];
    CGSize titleSize = [NSLocalizedString(@"hd_account_monitor_check_first_address", nil) sizeWithRestrict:CGSizeMake(size.width, CGFLOAT_MAX) font:[UIFont systemFontOfSize:kFontSize]];
    self = [super initWithFrame:CGRectMake(0, 0, size.width + kButtonEdgeInsets.left + kButtonEdgeInsets.right, size.height + titleSize.height + kVerticalMargin * 3 + kButtonHeight)];
    if (self) {
        [self firstConfigure:address size:size titleSize:titleSize];
    }
    return self;
}

-(void)firstConfigure:(NSString*)address size:(CGSize)size titleSize:(CGSize)titleSize {
    UILabel* lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(kButtonEdgeInsets.left, kVerticalMargin, size.width, titleSize.height)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.font = [UIFont systemFontOfSize:kFontSize];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = NSLocalizedString(@"hd_account_monitor_check_first_address", nil);
    UILabel* lblAddress = [[UILabel alloc]initWithFrame:CGRectMake(kButtonEdgeInsets.left, kVerticalMargin * 2 + titleSize.height, size.width, size.height)];
    lblAddress.backgroundColor = [UIColor clearColor];
    lblAddress.font = [UIFont fontWithName:@"Courier New" size:kFontSize];
    lblAddress.textColor = [UIColor whiteColor];
    lblAddress.numberOfLines = 0;
    lblAddress.text = address;
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(kButtonEdgeInsets.left, kVerticalMargin * 3 + titleSize.height + size.height, size.width, kButtonHeight)];
    [btn setBackgroundImage:nil forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"card_foreground_pressed"] forState:UIControlStateHighlighted];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btn.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateHighlighted];
    [btn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    UIView* seperator = [[UIView alloc]initWithFrame:CGRectMake(0, kVerticalMargin * 3 + titleSize.height + size.height, size.width + kButtonEdgeInsets.left + kButtonEdgeInsets.right, 1 / [UIScreen mainScreen].scale)];
    seperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    
    [self addSubview:lblTitle];
    [self addSubview:lblAddress];
    [self addSubview:btn];
    [self addSubview:seperator];
}

@end
