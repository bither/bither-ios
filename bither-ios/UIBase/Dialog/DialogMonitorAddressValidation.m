//
//  DialogMonitorAddressValidation.m
//  bither-ios
//
//  Created by 宋辰文 on 16/6/13.
//  Copyright © 2016年 Bither. All rights reserved.
//

#import "DialogMonitorAddressValidation.h"
#import "StringUtil.h"
#import "NSString+Size.h"

#define kMinWidth (200)
#define kMinHeight (100)
#define kMaxHeight (400)
#define kButtonHeight (44)
#define kVerticalMargin (10)
#define kFontSize (16)
#define kTitleHeight (30)

@interface DialogMonitorAddressValidation()
@property (weak) id target;
@property SEL okSelector;
@end

@implementation DialogMonitorAddressValidation

-(instancetype)initWithAddresses:(NSArray*)addresses target:(id)target andOkSelector:(SEL)okSelector{
    NSString* firstAddress = [StringUtil formatAddress:addresses[0] groupSize:4 lineSize:16] ;
    CGSize addressSize = [firstAddress sizeWithRestrict:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX) font:[UIFont fontWithName:@"Courier New" size:kFontSize]];
    CGFloat width = MAX(addressSize.width, kMinWidth);
    CGFloat height = addressSize.height * addresses.count + kVerticalMargin * (addresses.count) + kButtonHeight + kTitleHeight;
    height = MIN(MAX(height, kMinHeight), kMaxHeight);
    self = [super initWithFrame:CGRectMake(0, 0, width, height)];
    if (self){
        [self configure:addresses];
        self.target = target;
        self.okSelector = okSelector;
    }
    return self;
}

- (void)configure:(NSArray*)addresses{
    UILabel* lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, kTitleHeight)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.font = [UIFont systemFontOfSize:kFontSize];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = NSLocalizedString(@"monitor_addresses_validation", nil);
    [self addSubview:lblTitle];
    
    UIButton* btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height - kButtonHeight, self.frame.size.width / 2, kButtonHeight)];
    [btnCancel setBackgroundImage:nil forState:UIControlStateNormal];
    [btnCancel setBackgroundImage:[UIImage imageNamed:@"card_foreground_pressed"] forState:UIControlStateHighlighted];
    btnCancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateHighlighted];
    [btnCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(cancelPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* btnOk = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, self.frame.size.height - kButtonHeight, self.frame.size.width / 2, kButtonHeight)];
    [btnOk setBackgroundImage:nil forState:UIControlStateNormal];
    [btnOk setBackgroundImage:[UIImage imageNamed:@"card_foreground_pressed"] forState:UIControlStateHighlighted];
    btnOk.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btnOk.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
    [btnOk setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnOk setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateHighlighted];
    [btnOk setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [btnOk addTarget:self action:@selector(okPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnCancel];
    [self addSubview:btnOk];
    
    
    NSString* firstAddress = [StringUtil formatAddress:addresses[0] groupSize:4 lineSize:16] ;
    CGSize addressSize = [firstAddress sizeWithRestrict:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX) font:[UIFont fontWithName:@"Courier New" size:kFontSize]];
    
    UIScrollView* scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, kTitleHeight, self.frame.size.width, self.frame.size.height - kTitleHeight - kButtonHeight - kVerticalMargin)];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.contentSize = CGSizeMake(self.frame.size.width, addressSize.height * addresses.count + kVerticalMargin * (addresses.count - 1));
    [self addSubview:scrollView];
    
    for(int i = 0; i < addresses.count; i ++){
        UILabel* lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(0, i * (addressSize.height + kVerticalMargin), scrollView.frame.size.width, addressSize.height)];
        lblAddress.backgroundColor = [UIColor clearColor];
        lblAddress.font = [UIFont fontWithName:@"Courier New" size:kFontSize];
        lblAddress.textColor = [UIColor whiteColor];
        lblAddress.text =[StringUtil formatAddress:addresses[i] groupSize:4 lineSize:16];
        lblAddress.numberOfLines = 0;
        [scrollView addSubview:lblAddress];
    }
}

-(void)okPressed:(id)sender {
    [self dismissWithCompletion:^{
        if(self.target && self.okSelector && [self.target respondsToSelector:self.okSelector]){
            IMP imp = [self.target methodForSelector:self.okSelector];
            void (*func)(id, SEL) = (void *)imp;
            func(self.target, self.okSelector);
        }
    }];
}

-(void)cancelPressed:(id)sender {
    [self dismiss];
}

@end
