//
//  DialogHDMSeedWordList.m
//  bither-ios
//
//  Created by 宋辰文 on 15/1/30.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import "DialogHDMSeedWordList.h"
#import "NSString+Size.h"

#define kMargin (50)
#define kFontSize (16)
#define kButtonHeight (44)
#define kGap (18)
#define kButtonEdgeInsets (UIEdgeInsetsMake(0, 10, 0, 10))
#define kButtonFontSize (16)

@implementation DialogHDMSeedWordList

- (instancetype)initWithWords:(NSArray *)words {
    NSString *str = CFBridgingRelease(CFStringCreateByCombiningStrings(NULL, (__bridge CFArrayRef) words, CFSTR("-")));
    CGFloat width = [UIScreen mainScreen].bounds.size.width - kMargin * 2;
    CGFloat height = [str sizeWithRestrict:CGSizeMake(width, CGFLOAT_MAX) font:[UIFont systemFontOfSize:kFontSize]].height;
    self = [super initWithFrame:CGRectMake(0, 0, width, height + kGap + kButtonHeight)];
    if (self) {
        UIEdgeInsets insets = self.bgInsets;
        insets.bottom = 4;
        self.bgInsets = insets;
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        lbl.text = str;
        lbl.textColor = [UIColor whiteColor];
        lbl.font = [UIFont systemFontOfSize:kFontSize];
        lbl.numberOfLines = 0;
        [self addSubview:lbl];

        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, lbl.frame.size.height + kGap, self.frame.size.width, kButtonHeight)];
        [btn setBackgroundImage:nil forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"card_foreground_pressed"] forState:UIControlStateHighlighted];
        btn.contentEdgeInsets = kButtonEdgeInsets;
        btn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        btn.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateHighlighted];
        [btn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];

        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, btn.frame.origin.y, self.frame.size.width, 1)];
        seperator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        seperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self addSubview:seperator];
    }
    return self;
}

@end
