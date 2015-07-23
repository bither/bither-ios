//
//  DialogTotalBalance.m
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
//  Created by songchenwen on 14/8/4.
//

#import "DialogTotalBalance.h"
#import <Bitheri/BTAddressManager.h>
#import "PieChartView.h"
#import "UnitUtil.h"
#import "MarketUtil.h"
#import "UIImage+ImageRenderToColor.h"

#define kForegroundInsetsRate (0.05f)
#define kChartSize (260)
#define kChartSizeSmall (210)
#define kTopLabelFontSize (18)
#define kVerticalGap (5)
#define kBottomLabelFontSize (13)
#define kBottomHorizontalMargin (15)

@interface DialogTotalBalance () {
    int64_t total;
    int64_t hd;
    int64_t hdMonitored;
    int64_t hdm;
    int64_t hot;
    int64_t cold;
    double price;
}
@property PieChartView *chart;
@end

@implementation DialogTotalBalance

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, kChartSize, kChartSize)];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    hd = 0;
    hdMonitored = 0;
    hdm = 0;
    hot = 0;
    cold = 0;
    total = 0;
    price = [MarketUtil getDefaultNewPrice];
    NSArray *allAddresses = [BTAddressManager instance].allAddresses;
    for (BTAddress *a in allAddresses) {
        if (a.isHDM) {
            hdm += a.balance;
        } else if (a.hasPrivKey) {
            hot += a.balance;
        } else {
            cold += a.balance;
        }
        total += a.balance;
    }

    if ([BTAddressManager instance].hasHDAccountHot) {
        hd = [BTAddressManager instance].hdAccountHot.balance;
        total += hd;
    }
    if ([BTAddressManager instance].hasHDAccountMonitored){
        hdMonitored = [BTAddressManager instance].hdAccountMonitored.balance;
        total += hdMonitored;
    }

    CGFloat chartSize = kChartSize;
    int rowCount = (hdm > 0 ? 1 : 0) + (hot > 0 ? 1 : 0) + (cold > 0 ? 1 : 0) + (hd > 0 ? 1 : 0) + (hdMonitored > 0 ? 1 : 0);
    if (rowCount > 2 && [UIScreen mainScreen].bounds.size.height <= 480) {
        chartSize = kChartSizeSmall;
    }

    self.bgInsets = UIEdgeInsetsMake(14, 6, 14, 6);
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kTopLabelFontSize * 1.2)];
    topLabel.font = [UIFont systemFontOfSize:kTopLabelFontSize];
    topLabel.textColor = [UIColor whiteColor];
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Total BTC prefix", nil), [UnitUtil stringForAmount:total]];
    [self addSubview:topLabel];

    CGFloat left = (self.frame.size.width - chartSize) / 2;
    self.chart = [[PieChartView alloc] initWithFrame:CGRectMake(chartSize * kForegroundInsetsRate + left, CGRectGetMaxY(topLabel.frame) + kVerticalGap + chartSize * kForegroundInsetsRate, chartSize - chartSize * kForegroundInsetsRate * 2, chartSize - chartSize * kForegroundInsetsRate * 2)];
    [self addSubview:self.chart];
    UIImageView *ivForeground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pie_mask"]];
    ivForeground.frame = CGRectMake(left, CGRectGetMaxY(topLabel.frame) + kVerticalGap, chartSize, chartSize);
    [self addSubview:ivForeground];

    CGFloat bottom = CGRectGetMaxY(ivForeground.frame);

    NSString *symbol = [BitherSetting getCurrencySymbol:[[UserDefaultsUtil instance] getDefaultCurrency]];
    if (hd > 0) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
        lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentLeft;
        lbl.attributedText = [self stringAddDotColor:[self.chart colorForIndex:0] string:NSLocalizedString(@"address_group_hd", nil)];
        [self addSubview:lbl];

        lbl = [[UILabel alloc] initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
        lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentRight;
        lbl.attributedText = [UnitUtil stringWithSymbolForAmount:hd withFontSize:kBottomLabelFontSize color:lbl.textColor];
        [self addSubview:lbl];

        bottom = CGRectGetMaxY(lbl.frame);

        if (price > 0) {
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap - 4, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
            lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
            lbl.textColor = [UIColor whiteColor];
            lbl.textAlignment = NSTextAlignmentRight;
            lbl.text = [NSString stringWithFormat:@"%@ %.2f", symbol, (price * hd) / pow(10, 8)];
            [self addSubview:lbl];

            bottom = CGRectGetMaxY(lbl.frame);
        }
    }
    if (hdMonitored > 0) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
        lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentLeft;
        lbl.attributedText = [self stringAddDotColor:[self.chart colorForIndex:1] string:NSLocalizedString(@"hd_account_cold_address_list_label", nil)];
        [self addSubview:lbl];

        lbl = [[UILabel alloc] initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
        lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentRight;
        lbl.attributedText = [UnitUtil stringWithSymbolForAmount:hdMonitored withFontSize:kBottomLabelFontSize color:lbl.textColor];
        [self addSubview:lbl];

        bottom = CGRectGetMaxY(lbl.frame);

        if (price > 0) {
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap - 4, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
            lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
            lbl.textColor = [UIColor whiteColor];
            lbl.textAlignment = NSTextAlignmentRight;
            lbl.text = [NSString stringWithFormat:@"%@ %.2f", symbol, (price * hdMonitored) / pow(10, 8)];
            [self addSubview:lbl];

            bottom = CGRectGetMaxY(lbl.frame);
        }
    }
    if (hdm > 0) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
        lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentLeft;
        lbl.attributedText = [self stringAddDotColor:[self.chart colorForIndex:2] string:@"HDM"];
        [self addSubview:lbl];

        lbl = [[UILabel alloc] initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
        lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentRight;
        lbl.attributedText = [UnitUtil stringWithSymbolForAmount:hdm withFontSize:kBottomLabelFontSize color:lbl.textColor];
        [self addSubview:lbl];

        bottom = CGRectGetMaxY(lbl.frame);

        if (price > 0) {
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap - 4, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
            lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
            lbl.textColor = [UIColor whiteColor];
            lbl.textAlignment = NSTextAlignmentRight;
            lbl.text = [NSString stringWithFormat:@"%@ %.2f", symbol, (price * hdm) / pow(10, 8)];
            [self addSubview:lbl];

            bottom = CGRectGetMaxY(lbl.frame);
        }
    }

    if (hot > 0) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
        lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentLeft;
        lbl.attributedText = [self stringAddDotColor:[self.chart colorForIndex:3] string:NSLocalizedString(@"Hot Wallet Address", nil)];
        [self addSubview:lbl];

        lbl = [[UILabel alloc] initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
        lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentRight;
        lbl.attributedText = [UnitUtil stringWithSymbolForAmount:hot withFontSize:kBottomLabelFontSize color:lbl.textColor];
        [self addSubview:lbl];

        bottom = CGRectGetMaxY(lbl.frame);

        if (price > 0) {
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap - 4, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
            lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
            lbl.textColor = [UIColor whiteColor];
            lbl.textAlignment = NSTextAlignmentRight;
            lbl.text = [NSString stringWithFormat:@"%@ %.2f", symbol, (price * hot) / pow(10, 8)];
            [self addSubview:lbl];

            bottom = CGRectGetMaxY(lbl.frame);
        }
    }

    if (cold > 0) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
        lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentLeft;
        lbl.attributedText = [self stringAddDotColor:[self.chart colorForIndex:4] string:NSLocalizedString(@"Cold Wallet Address", nil)];
        [self addSubview:lbl];

        lbl = [[UILabel alloc] initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
        lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentRight;
        lbl.attributedText = [UnitUtil stringWithSymbolForAmount:cold withFontSize:kBottomLabelFontSize color:lbl.textColor];
        [self addSubview:lbl];

        bottom = CGRectGetMaxY(lbl.frame);

        if (price > 0) {
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(kBottomHorizontalMargin, bottom + kVerticalGap - 4, self.frame.size.width - kBottomHorizontalMargin * 2, kBottomLabelFontSize * 1.2)];
            lbl.font = [UIFont systemFontOfSize:kBottomLabelFontSize];
            lbl.textColor = [UIColor whiteColor];
            lbl.textAlignment = NSTextAlignmentRight;
            lbl.text = [NSString stringWithFormat:@"%@ %.2f", symbol, (price * cold) / pow(10, 8)];
            [self addSubview:lbl];

            bottom = CGRectGetMaxY(lbl.frame);
        }
    }

    CGRect frame = self.frame;
    frame.size.height = bottom;
    self.frame = frame;

    UIButton *dismissBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.chart.frame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(self.chart.frame))];
    [dismissBtn setBackgroundImage:nil forState:UIControlStateNormal];
    dismissBtn.adjustsImageWhenHighlighted = NO;
    [self addSubview:dismissBtn];
    [dismissBtn addTarget:self action:@selector(dismissPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dialogDidShow {
    [super dialogDidShow];
    [self.chart setAmounts:@[@(hd), @(hdMonitored), @(hdm), @(hot), @(cold)]];
    [self.chart setNeedsDisplay];

}

- (void)dialogDidDismiss {
    [super dialogDidDismiss];
    if (self.listener && [self.listener respondsToSelector:@selector(dialogDismissed)]) {
        [self.listener dialogDismissed];
    }
}

- (void)dismissPressed:(id)sender {
    [self dismiss];
}

- (NSAttributedString *)stringAddDotColor:(UIColor *)color string:(NSString *)str {
    UIImage *image = [[UIImage imageNamed:@"dialog_total_balance_dot"] renderToColor:color];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:kBottomLabelFontSize] range:NSMakeRange(0, attr.length)];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    CGRect bounds = attachment.bounds;
    CGFloat imageSize = kBottomLabelFontSize * 0.8;
    bounds.size.width = imageSize;
    bounds.size.height = imageSize;
    attachment.bounds = bounds;

    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    [attr insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:0];
    [attr insertAttributedString:attachmentString atIndex:0];
    return attr;
}

- (BOOL)arrowAlwaysOnTop {
    return YES;
}

@end
