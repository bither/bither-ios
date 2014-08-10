//
//  DialogTotalBalance.m
//  bither-ios
//
//  Created by noname on 14-8-4.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "DialogTotalBalance.h"
#import <Bitheri/BTAddressManager.h>
#import "PieChartView.h"
#import "StringUtil.h"
#import "UIImage+ImageRenderToColor.h"

#define kForegroundInsetsRate (0.05f)
#define kChartSize (260)
#define kTopLabelFontSize (18)
#define kVerticalGap (5)
#define kBottomLabelFontSize (13)
#define kBottomHorizontalMargin (30)

@interface DialogTotalBalance (){
    int64_t total;
    int64_t hot;
    int64_t cold;
}
@property PieChartView* chart;
@end

@implementation DialogTotalBalance

-(instancetype)init{
    self = [super initWithFrame:CGRectMake(0, 0, kChartSize, kChartSize)];
    if(self){
        [self firstConfigure];
    }
    return self;
}
-(void)firstConfigure{
    hot = 0;
    cold = 0;
    total = 0;
    NSArray* allAddresses = [BTAddressManager sharedInstance].allAddresses;
    for(BTAddress* a in allAddresses){
        if(a.hasPrivKey){
            hot+= a.balance;
        }else{
            cold+= a.balance;
        }
        total += a.balance;
    }
    self.bgInsets = UIEdgeInsetsMake(14, 6, 14, 6);
    UILabel* topLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, kTopLabelFontSize * 1.2)];
    topLabel.font = [UIFont systemFontOfSize:kTopLabelFontSize];
    topLabel.textColor = [UIColor whiteColor];
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Total BTC prefix", nil), [StringUtil stringForAmount:total]];
    [self addSubview:topLabel];
    
    self.chart = [[PieChartView alloc]initWithFrame:CGRectMake(kChartSize * kForegroundInsetsRate, CGRectGetMaxY(topLabel.frame) + kVerticalGap + kChartSize * kForegroundInsetsRate, kChartSize - kChartSize * kForegroundInsetsRate * 2, kChartSize - kChartSize * kForegroundInsetsRate * 2)];
    [self addSubview:self.chart];
    UIImageView* ivForeground = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pie_mask"]];
    ivForeground.frame = CGRectMake(0, CGRectGetMaxY(topLabel.frame) + kVerticalGap, kChartSize, kChartSize);
    [self addSubview:ivForeground];
    
    CGFloat bottom = CGRectGetMaxY(ivForeground.frame);
    
    if(hot > 0){
        UILabel* lbl = [[UILabel alloc]initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
        lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentLeft;
        lbl.attributedText = [self stringAddDotColor:[self.chart colorForIndex:0] string:NSLocalizedString(@"Hot Wallet Address", nil)];
        [self addSubview:lbl];
        
        lbl = [[UILabel alloc]initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
        lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentRight;
        lbl.text = [StringUtil stringForAmount:hot];
        [self addSubview:lbl];
        
        bottom = CGRectGetMaxY(lbl.frame);
    }
    
    if(cold > 0){
        UILabel* lbl = [[UILabel alloc]initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
        lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentLeft;
        lbl.attributedText = [self stringAddDotColor:[self.chart colorForIndex:1] string:NSLocalizedString(@"Cold Wallet Address", nil)];
        [self addSubview:lbl];
        
        lbl = [[UILabel alloc]initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
        lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentRight;
        lbl.text = [StringUtil stringForAmount:cold];
        [self addSubview:lbl];
        
        bottom = CGRectGetMaxY(lbl.frame);
    }
    
    CGRect frame = self.frame;
    frame.size.height = bottom;
    self.frame = frame;
}

-(void)dialogDidShow{
    [super dialogDidShow];
    [self.chart setAmounts:@[@(hot), @(cold)]];
    [self.chart setNeedsDisplay];
}

-(void)dialogDidDismiss{
    [super dialogDidDismiss];
    if(self.listener && [self.listener respondsToSelector:@selector(dialogDismissed)]){
        [self.listener dialogDismissed];
    }
}

-(NSAttributedString*)stringAddDotColor:(UIColor*)color string:(NSString*)str{
    UIImage* image = [[UIImage imageNamed:@"dialog_total_balance_dot"] renderToColor:color];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:str];
    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:kBottomLabelFontSize] range:NSMakeRange(0, attr.length)];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    CGRect bounds = attachment.bounds;
    CGFloat imageSize = kBottomLabelFontSize * 0.8;
    bounds.size.width = imageSize;
    bounds.size.height = imageSize;
    attachment.bounds = bounds;
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    [attr insertAttributedString:[[NSAttributedString alloc]initWithString:@" "] atIndex:0];
    [attr insertAttributedString:attachmentString atIndex:0];
    return attr;
}
@end
