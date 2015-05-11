//
//  MarketListCell.m
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

#import "MarketListCell.h"
#import "UserDefaultsUtil.H"

@interface MarketListCell ()

@property(weak, nonatomic) IBOutlet UILabel *lbMarketName;
@property(weak, nonatomic) IBOutlet UILabel *lbPrice;

@end


@implementation MarketListCell


- (void)setMarket:(Market *)market {
    self.lbMarketName.text = [market getName];
    self.lbMarketName.textColor = [GroupUtil getMarketColor:market.marketType];
    if (market.ticker) {
        NSString *symobl = [BitherSetting getCurrencySymbol:[[UserDefaultsUtil instance] getDefaultCurrency]];

        self.lbPrice.text = [NSString stringWithFormat:@"%@%.2f", symobl, [market.ticker getDefaultExchangePrice]];
    } else {
        self.lbPrice.text = @"--";
    }
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsZero;
}

@end
