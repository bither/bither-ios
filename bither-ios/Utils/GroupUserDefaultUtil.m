//
//  GroupUserDefaultUtil.m
//  bither-ios
//
//  Copyright 2015 http://Bither.net
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
//  Created by songchenwen on 2015/3/5.
//

#import "GroupUserDefaultUtil.h"
#import "GroupFileUtil.h"
#import "QRCodeThemeUtil.h"

#define DEFAULT_MARKET @"default_market"
#define DEFAULT_EXCHANGE_RATE @"default_exchange_rate"
#define BITCOIN_UNIT @"bitcoin_unit"
#define PAYMENT_ADDRESS @"payment_address"
#define FANCY_QR_CODE_THEME @"fancy_qr_code_theme"

NSUserDefaults *groupUserDefaults;
static GroupUserDefaultUtil *groupUserDefaultsUtil;

@implementation GroupUserDefaultUtil

+ (GroupUserDefaultUtil *)instance {
    @synchronized (self) {
        if (groupUserDefaultsUtil == nil) {
            groupUserDefaultsUtil = [[self alloc] init];
            if ([GroupFileUtil supported]) {
                groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:kBitherGroupName];
            } else {
                groupUserDefaults = nil;
            }
        }
    }
    return groupUserDefaultsUtil;
}

- (MarketType)defaultMarket {
    if (groupUserDefaults) {
        NSInteger market = [groupUserDefaults integerForKey:DEFAULT_MARKET];
        if (market > 0) {
            return [GroupUtil getMarketType:market];
        }
    }
    if ([self localeIsChina]) {
        return BTCCHINA;
    }
    return BITSTAMP;
}

- (void)setDefaultMarket:(MarketType)market {
    if (groupUserDefaults) {
        [groupUserDefaults setInteger:[GroupUtil getMarketValue:market] forKey:DEFAULT_MARKET];
        [groupUserDefaults synchronize];
    }
}

- (GroupCurrency)defaultCurrency {
    if (groupUserDefaults) {
        if ([groupUserDefaults objectForKey:DEFAULT_EXCHANGE_RATE]) {
            return (GroupCurrency) [groupUserDefaults integerForKey:DEFAULT_EXCHANGE_RATE];
        }
    }
    if ([self localeIsChina]) {
        return CNYG;
    }
    return USDG;
}

- (void)setDefaultCurrency:(GroupCurrency)currency {
    if (groupUserDefaults) {
        [groupUserDefaults setInteger:currency forKey:DEFAULT_EXCHANGE_RATE];
        [groupUserDefaults synchronize];
    }
}

- (GroupBitcoinUnit)defaultBitcoinUnit {
    if (groupUserDefaults && [groupUserDefaults objectForKey:BITCOIN_UNIT]) {
        return (GroupBitcoinUnit) [groupUserDefaults integerForKey:BITCOIN_UNIT];
    }
    return UnitBTCG;
}

- (void)setDefaultBitcoinUnit:(GroupBitcoinUnit)unit {
    if (groupUserDefaults) {
        [groupUserDefaults setInteger:unit forKey:BITCOIN_UNIT];
        [groupUserDefaults synchronize];
    }
}

- (NSInteger)getQrCodeTheme {
    NSInteger index = [groupUserDefaults integerForKey:FANCY_QR_CODE_THEME];
    if (index < 0) {
        index = 0;
    }
    if (index >= [QRCodeTheme themes].count) {
        index = [QRCodeTheme themes].count - 1;
    }
    return index;
}

- (void)setQrCodeTheme:(NSInteger)qrCodeTheme {
    [groupUserDefaults setInteger:qrCodeTheme forKey:FANCY_QR_CODE_THEME];
    [groupUserDefaults synchronize];
}

- (void)setPaymentAddress:(NSString *)address {
    if (address) {
        [groupUserDefaults setObject:address forKey:PAYMENT_ADDRESS];
    } else {
        [groupUserDefaults removeObjectForKey:PAYMENT_ADDRESS];
    }
    NSLog(@"set payment address %@", address);
    [groupUserDefaults synchronize];
}

- (NSString *)paymentAddress {
    return [groupUserDefaults objectForKey:PAYMENT_ADDRESS];
}

- (BOOL)localeIsChina {
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    return [language isEqualToString:@"zh-Hans"];
}
@end
