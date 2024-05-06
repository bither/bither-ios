//
//  BitherSetting.m
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

#define DEV_DEBUG TRUE

#import "BitherSetting.h"
#import "UserDefaultsUtil.h"

static BOOL _isUnitTest = NO;

@implementation BitherSetting


+ (NSString *)getCurrencySymbol:(Currency)currency; {
    switch (currency) {
        case USD:
            return @"$";
        case CNY:
            return @"¥";
        case EUR:
            return @"€";
        case GBP:
            return @"£";
        case JPY:
            return @"¥";
        case KRW:
            return @"₩";
        case CAD:
            return @"C$";
        case AUD:
            return @"A$";
        default:
            return @"$";
    }
}

+ (NSString *)getCurrencyName:(Currency)currency; {
    switch (currency) {
        case USD:
            return @"USD";
        case CNY:
            return @"CNY";
        case EUR:
            return @"EUR";
        case GBP:
            return @"GBP";
        case JPY:
            return @"JPY";
        case KRW:
            return @"KRW";
        case CAD:
            return @"CAD";
        case AUD:
            return @"AUD";
        default:
            return @"USD";
    }
}

+ (Currency)getCurrencyFromName:(NSString *)currencyName; {
    if (currencyName == nil || currencyName.length == 0) {
        return USD;
    }
    if ([currencyName isEqualToString:@"USD"]) {
        return USD;
    }
    if ([currencyName isEqualToString:@"CNY"]) {
        return CNY;
    }
    if ([currencyName isEqualToString:@"EUR"]) {
        return EUR;
    }
    if ([currencyName isEqualToString:@"GBP"]) {
        return GBP;
    }
    if ([currencyName isEqualToString:@"JPY"]) {
        return JPY;
    }
    if ([currencyName isEqualToString:@"KRW"]) {
        return KRW;
    }
    if ([currencyName isEqualToString:@"CAD"]) {
        return CAD;
    }
    if ([currencyName isEqualToString:@"AUD"]) {
        return AUD;
    }
    return USD;
}

+ (NSString *)getTransactionFeeMode:(TransactionFeeMode)transactionFee {
    if (transactionFee == Higher) {
        return NSLocalizedString(@"Higher", nil);
    } else if (transactionFee == High) {
        return NSLocalizedString(@"High", nil);
    } else if (transactionFee == Low) {
        return NSLocalizedString(@"Low", nil);
    } else {
        return NSLocalizedString(@"Normal", nil);
    }
}

+ (NSString *)getTransactionFee:(TransactionFeeMode)transactionFee {
    int dividend = 1000;
    NSString *unit = @"sat/vB";
    if (transactionFee == Higher) {
        return [NSString stringWithFormat:@"%d%@", Higher/dividend, unit];
    } else if (transactionFee == High) {
        return [NSString stringWithFormat:@"%d%@", High/dividend, unit];
    } else if (transactionFee == Low) {
        return [NSString stringWithFormat:@"%d%@", Low/dividend, unit];
    } else {
        return [NSString stringWithFormat:@"%d%@", Normal/dividend, unit];
    }
}

+ (NSString *)getKeychainMode:(KeychainMode)keychainMode {
    if (keychainMode == Off) {
        return NSLocalizedString(@"keychain_backup_off", nil);
    } else {
        return NSLocalizedString(@"keychain_backup_on", nil);
    }
}

+ (BOOL)isUnitTest; {
    return _isUnitTest;
}

+ (void)setIsUnitTest:(BOOL)isUnitTest; {
    _isUnitTest = isUnitTest;
}

+ (NSString *)getMinerFeeModeName:(MinerFeeMode)minerFeeMode {
    switch (minerFeeMode) {
        case DynamicFee:
            return NSLocalizedString(@"dynamic_miner_fee_title", nil);
        case HigherFee:
            return NSLocalizedString(@"Higher", nil);
        case HighFee:
            return NSLocalizedString(@"High", nil);
        case NormalFee:
            return NSLocalizedString(@"Normal", nil);
        case LowFee:
            return NSLocalizedString(@"Low", nil);
        case CustomFee:
            return NSLocalizedString(@"miner_fee_custom", nil);
    }
}

+ (uint64_t)getMinerFeeBaseFromMinerFeeMode:(MinerFeeMode)minerFeeMode {
    switch (minerFeeMode) {
        case HigherFee:
            return Higher;
        case HighFee:
            return High;
        case NormalFee:
            return Normal;
        case LowFee:
            return Low;
        default:
            return 0;
    }
}

+ (MinerFeeMode)getMinerFeeMode {
    if ([[UserDefaultsUtil instance] isUseDynamicMinerFee]) {
        return DynamicFee;
    }
    switch ([[UserDefaultsUtil instance] getTransactionFeeMode]) {
        case Higher:
            return HigherFee;
        case High:
            return HighFee;
        case Normal:
            return NormalFee;
        case Low:
            return LowFee;
        default:
            return DynamicFee;
    }
}

@end
