//
//  DialogBalanceDetail.m
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

#import "DialogBalanceDetail.h"
#import "UnitUtil.h"
#import "NSString+Size.h"
#import "NSAttributedString+Size.h"
#import "BTTxProvider.h"

#define kLabelFontSize (16)
#define kCountFontSize (18)
#define kMinHorizontalMargin (22)
#define kMinWidth (160)
#define kLabelHeight (40)

@implementation DialogBalanceDetail

- (instancetype)initWithAddress:(BTAddress *)address {
    self = [super initWithFrame:CGRectMake(0, 0, 200, kLabelHeight * 3)];
    if (self) {
        [self configureViews:address];
    }
    return self;
}

- (void)configureViews:(BTAddress *)address {
    self.bgInsets = UIEdgeInsetsMake(6, 16, 6, 16);
    NSString *txCountLabel = NSLocalizedString(@"balance_detail_transaction_count", nil);
    NSString *txCount = [NSString stringWithFormat:@"%d", address.txCount];
    NSString *receivedLabel = NSLocalizedString(@"balance_detail_total_incoming", nil);
    NSString *sentLabel = NSLocalizedString(@"balance_detail_total_outgoing", nil);
//    NSArray *txs = address.txs;
//    for(BTTx* tx in txs){
//        int64_t amount = [tx deltaAmountFrom:address];
//        if(amount > 0){
//            received += amount;
//        }
//    }
    int64_t received = [[BTTxProvider instance] getTotalReceiveWithAddress:address.address];
    int64_t sent = received - address.balance;
    NSAttributedString *receivedStr = [UnitUtil attributedStringForAmount:received withFontSize:kCountFontSize];
    NSAttributedString *sentStr = [UnitUtil attributedStringForAmount:sent withFontSize:kCountFontSize];

    CGFloat maxWidth = kMinWidth;
    CGSize restrictSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    UIFont *labelFont = [UIFont systemFontOfSize:kLabelFontSize];
    UIFont *countFont = [UIFont systemFontOfSize:kCountFontSize];
    CGFloat width = [txCountLabel sizeWithRestrict:restrictSize font:labelFont].width + [txCount sizeWithRestrict:restrictSize font:countFont].width + kMinHorizontalMargin;
    if (width > maxWidth) {
        maxWidth = width;
    }
    width = [receivedLabel sizeWithRestrict:restrictSize font:labelFont].width + [receivedStr sizeWithRestrict:restrictSize].width + kMinHorizontalMargin;
    if (width > maxWidth) {
        maxWidth = width;
    }
    width = [sentLabel sizeWithRestrict:restrictSize font:labelFont].width + [sentStr sizeWithRestrict:restrictSize].width + kMinHorizontalMargin;
    if (width > maxWidth) {
        maxWidth = width;
    }
    self.frame = CGRectMake(0, 0, maxWidth, kLabelHeight * 3);

    UILabel *lbl = [self labelForTop:0 align:NSTextAlignmentLeft width:maxWidth];
    lbl.text = txCountLabel;
    lbl = [self labelForTop:0 align:NSTextAlignmentRight width:maxWidth];
    lbl.text = txCount;
    lbl = [self labelForTop:kLabelHeight align:NSTextAlignmentLeft width:maxWidth];
    lbl.text = receivedLabel;
    lbl = [self labelForTop:kLabelHeight align:NSTextAlignmentRight width:maxWidth];
    lbl.attributedText = receivedStr;
    lbl = [self labelForTop:kLabelHeight * 2 align:NSTextAlignmentLeft width:maxWidth];
    lbl.text = sentLabel;
    lbl = [self labelForTop:kLabelHeight * 2 align:NSTextAlignmentRight width:maxWidth];
    lbl.attributedText = sentStr;
}

- (UILabel *)labelForTop:(CGFloat)top align:(NSTextAlignment)align width:(CGFloat)width {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, top, width, kLabelHeight)];
    if (align == NSTextAlignmentLeft) {
        lbl.font = [UIFont systemFontOfSize:kLabelFontSize];
    } else {
        lbl.font = [UIFont systemFontOfSize:kCountFontSize];
    }
    lbl.textColor = [UIColor whiteColor];
    lbl.textAlignment = align;
    [self addSubview:lbl];
    return lbl;
}

@end
