//  UserDefaultsUtil.m
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

#import <AssertMacros.h>
#import <Bitheri/BTUtils.h>
#import "UserDefaultsUtil.h"
#import "GroupUserDefaultUtil.h"
#import "QRCodeThemeUtil.h"

#define PREFS_KEY_LAST_VERSION @"last_version"
#define USER_DEFAULT_LAST_VER @"last_ver"
#define DEFAULT_MARKET @"default_market"
#define DEFAULT_EXCHANGE_RATE @"default_exchange_rate"

#define LAST_CHECK_PRIVATE_KEY_TIME @"last_check_private_key_time"
#define LAST_BACK_UP_PRIVATE_KEY_TIME @"last_back_up_private_key_time"
#define HAS_PRIVATE_KEY @"has_private_key"
#define TRANSACTION_FEE_MODE @"transaction_fee_mode"

#define SYNC_BLOCK_ONLY_WIFI @"sync_block_only_wifi"
#define DOWNLOAD_SPV_FINISH @"download_spv_finish"
#define PASSWORD_SEED @"password_seed"
#define USER_AVATAR @"user_avatar"
#define FANCY_QR_CODE_THEME @"fancy_qr_code_theme"

#define BITCOIN_UNIT @"bitcoin_unit"
#define PIN_CODE @"pin_code"

#define KEYCHAIN_MODE @"keychain_mode"

#define PASSWORD_STRENGTH_CHECK @"password_strength_check"

#define PAYMENT_ADDRESS @"payment_address"

#define FIRST_RUN_DIALOG_SHOWN @"first_run_dialog_shown"

#define TOTAL_BALANCE_HIDE @"total_balance_hide"

static UserDefaultsUtil *userDefaultsUtil;

NSUserDefaults *userDefaults;

@implementation UserDefaultsUtil

+ (UserDefaultsUtil *)instance {
    @synchronized (self) {
        if (userDefaultsUtil == nil) {
            userDefaultsUtil = [[self alloc] init];
            userDefaults = [NSUserDefaults standardUserDefaults];
        }
    }
    return userDefaultsUtil;
}

- (NSInteger)getLastVersion {
    return [userDefaults integerForKey:USER_DEFAULT_LAST_VER];
}

- (void)setLastVersion:(NSInteger)version {
    [userDefaults setInteger:version forKey:USER_DEFAULT_LAST_VER];
    [userDefaults synchronize];
}

- (MarketType)getDefaultMarket {
    if (![userDefaults objectForKey:DEFAULT_MARKET]) {
        [self setDefaultMarket];
    }
    return [self getMarket];
}

- (MarketType)getMarket {
    NSInteger market = [userDefaults integerForKey:DEFAULT_MARKET];
    return [GroupUtil getMarketType:market];
}

- (void)setDefaultMarket {
    if ([self localeIsChina]) {
        [self setMarket:BTCCHINA];
    } else {
        [self setMarket:BITSTAMP];
    }

}

- (void)setMarket:(MarketType)marketType {
    [userDefaults setInteger:[GroupUtil getMarketValue:marketType] forKey:DEFAULT_MARKET];
    [userDefaults synchronize];
    [[GroupUserDefaultUtil instance] setDefaultMarket:marketType];
}

- (void)setExchangeType:(Currency)exchangeType {
    [userDefaults setInteger:exchangeType forKey:DEFAULT_EXCHANGE_RATE];
    [userDefaults synchronize];
    [[GroupUserDefaultUtil instance] setDefaultCurrency:(GroupCurrency) exchangeType];
}

- (Currency)getDefaultCurrency {
    NSInteger type = [self getExchangeType];
    if (type == -1) {
        [self setDefaultExchangeType];
    }
    return [self getExchangeType];
}

- (void)setDefaultExchangeType {

    if ([self localeIsChina]) {
        [self setExchangeType:CNY];
    } else {
        [self setExchangeType:USD];
    }
}

- (BOOL)localeIsChina {
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    return [language isEqualToString:@"zh-Hans"];
}

- (BOOL)localeIsZHHant {
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    return [language isEqualToString:@"zh-Hant"];
}

- (NSInteger)getExchangeType {
    if ([userDefaults objectForKey:DEFAULT_EXCHANGE_RATE]) {
        return [userDefaults integerForKey:DEFAULT_EXCHANGE_RATE];
    } else {
        return -1;
    }
}


- (long long)getLastCheckPrivateKeyTime {
    return [[userDefaults objectForKey:LAST_CHECK_PRIVATE_KEY_TIME] longLongValue];
}

- (void)setLastCheckPrivateKeyTime:(long long)time {
    [userDefaults setObject:[NSNumber numberWithLongLong:time] forKey:LAST_CHECK_PRIVATE_KEY_TIME];
    [userDefaults synchronize];
}

- (long long)getLastBackupKeyTime {
    return [[userDefaults objectForKey:LAST_BACK_UP_PRIVATE_KEY_TIME] longLongValue];
}

- (void)setLastBackupKeyTime:(long long)time {
    [userDefaults setObject:[NSNumber numberWithLongLong:time] forKey:LAST_BACK_UP_PRIVATE_KEY_TIME];
    [userDefaults synchronize];
}

- (BOOL)hasPrivateKey {
    return [userDefaults boolForKey:HAS_PRIVATE_KEY];
}

- (void)setHasPrivateKey:(BOOL)hasPrivateKey {
    [userDefaults setBool:hasPrivateKey forKey:HAS_PRIVATE_KEY];
    [userDefaults synchronize];
}

- (BOOL)getSyncBlockOnlyWifi {
    return [userDefaults boolForKey:SYNC_BLOCK_ONLY_WIFI];
}

- (void)setSyncBlockOnlyWifi:(BOOL)onlyWifi {
    [userDefaults setBool:onlyWifi forKey:SYNC_BLOCK_ONLY_WIFI];
    [userDefaults synchronize];
}

- (BOOL)getDownloadSpvFinish {
    return [userDefaults boolForKey:DOWNLOAD_SPV_FINISH];
}

- (void)setDownloadSpvFinish:(BOOL)finish {
    [userDefaults setBool:finish forKey:DOWNLOAD_SPV_FINISH];
    [userDefaults synchronize];
}

- (BTPasswordSeed *)getPasswordSeedForOldVersion {
    NSString *str = [userDefaults stringForKey:PASSWORD_SEED];
    if ([StringUtil isEmpty:str]) {
        return nil;
    }
    return [[BTPasswordSeed alloc] initWithString:str];
}

- (void)setPasswordSeed:(BTPasswordSeed *)passwordSeed {
    [userDefaults setValue:[passwordSeed toPasswordSeedString] forKey:PASSWORD_SEED];
    [userDefaults synchronize];

}

- (TransactionFeeMode)getTransactionFeeMode {
    if ([userDefaults objectForKey:TRANSACTION_FEE_MODE]) {
        if ([userDefaults integerForKey:TRANSACTION_FEE_MODE] == Low) {
            return Low;
        } else if ([userDefaults integerForKey:TRANSACTION_FEE_MODE] == High) {
            return High;
        } else {
            return Normal;
        }
    } else {
        return Normal;
    }
}

- (void)setTransactionFeeMode:(TransactionFeeMode)feeMode {
    if (!feeMode) {
        feeMode = Normal;
    }
    [userDefaults setInteger:feeMode forKey:TRANSACTION_FEE_MODE];
    [userDefaults synchronize];
}

- (BOOL)hasUserAvatar {
    return [StringUtil isEmpty:[self getUserAvatar]];

}

- (NSString *)getUserAvatar {
    return [userDefaults stringForKey:USER_AVATAR];
}

- (void)setUserAvatar:(NSString *)avatar {
    [userDefaults setObject:avatar forKey:USER_AVATAR];
    [userDefaults synchronize];
}

- (NSInteger)getQrCodeTheme {
    NSInteger index = [userDefaults integerForKey:FANCY_QR_CODE_THEME];
    if (index < 0) {
        index = 0;
    }
    if (index >= [QRCodeTheme themes].count) {
        index = [QRCodeTheme themes].count - 1;
    }
    if (index != [GroupUserDefaultUtil instance].getQrCodeTheme) {
        [[GroupUserDefaultUtil instance] setQrCodeTheme:index];
    }
    return index;
}

- (void)setQrCodeTheme:(NSInteger)qrCodeTheme {
    [userDefaults setInteger:qrCodeTheme forKey:FANCY_QR_CODE_THEME];
    [userDefaults synchronize];
    [[GroupUserDefaultUtil instance] setQrCodeTheme:qrCodeTheme];
}


- (void)setBitcoinUnit:(BitcoinUnit)bitcoinUnit {
    [userDefaults setInteger:bitcoinUnit forKey:BITCOIN_UNIT];
    [userDefaults synchronize];
    [[GroupUserDefaultUtil instance] setDefaultBitcoinUnit:(GroupBitcoinUnit) bitcoinUnit];
}

- (BitcoinUnit)getBitcoinUnit {
    if ([userDefaults objectForKey:BITCOIN_UNIT]) {
        return [userDefaults integerForKey:BITCOIN_UNIT];
    }
    return UnitBTC;
}

- (void)setPinCode:(NSString *)code {
    if (!code || code.length == 0) {
        [self deletePinCode];
        return;
    }
    NSUInteger salt;
    NSData *randomBytes = [NSData randomWithSize:sizeof(salt)];
    [randomBytes getBytes:&salt length:sizeof(salt)];

    NSString *beforeHashStr = [NSString stringWithFormat:@"%@%lu", code, (unsigned long) salt];

    [userDefaults setObject:[NSString stringWithFormat:@"%lu;%lu", salt, [beforeHashStr hash]] forKey:PIN_CODE];
    [userDefaults synchronize];
}

- (BOOL)hasPinCode {
    NSString *hash = [userDefaults objectForKey:PIN_CODE];
    if (!hash || hash.length == 0) {
        return NO;
    }
    NSArray *strs = [hash componentsSeparatedByString:@";"];
    if (strs.count != 2) {
        [self deletePinCode];
        return NO;
    }
    return YES;
}

- (void)deletePinCode {
    [userDefaults removeObjectForKey:PIN_CODE];
    [userDefaults synchronize];
}

- (BOOL)checkPinCode:(NSString *)code {
    if ([self hasPinCode]) {
        NSString *hash = [userDefaults objectForKey:PIN_CODE];
        NSArray *strs = [hash componentsSeparatedByString:@";"];
        NSString *saltStr = strs[0];
        hash = strs[1];
        NSString *codeHash = [NSString stringWithFormat:@"%@%@", code, saltStr];
        return [StringUtil compareString:hash compare:[NSString stringWithFormat:@"%lu", [codeHash hash]]];
    } else {
        return YES;
    }
}

- (KeychainMode)getKeychainMode {
    if ([userDefaults objectForKey:KEYCHAIN_MODE]) {
        if ([userDefaults integerForKey:KEYCHAIN_MODE] == Off) {
            return Off;
        } else {
            return On;
        }
    } else {
        return Off;
    }
}

- (void)setKeychainMode:(KeychainMode)keychainMode {
    if (!keychainMode) {
        keychainMode = Off;
    }
    [userDefaults setInteger:keychainMode forKey:KEYCHAIN_MODE];
    [userDefaults synchronize];
}

- (void)setPasswordStrengthCheck:(BOOL)check {
    [userDefaults setBool:check forKey:PASSWORD_STRENGTH_CHECK];
    [userDefaults synchronize];
}

- (BOOL)getPasswordStrengthCheck {
    if (![userDefaults objectForKey:PASSWORD_STRENGTH_CHECK]) {
        return NO;
    }
    return [userDefaults boolForKey:PASSWORD_STRENGTH_CHECK];
}

- (void)setPaymentAddress:(NSString *)address {
    if ([BTUtils compareString:address compare:self.paymentAddress]) {
        return;
    }
    if (address) {
        [userDefaults setObject:address forKey:PAYMENT_ADDRESS];
    } else {
        [userDefaults setObject:@"" forKey:PAYMENT_ADDRESS];
    }
    [userDefaults synchronize];
    if ([BTUtils isEmpty:address]) {
        [[GroupUserDefaultUtil instance] setPaymentAddress:nil];
    } else {
        [[GroupUserDefaultUtil instance] setPaymentAddress:address];
    }
}

- (NSString *)paymentAddress {
    return [userDefaults objectForKey:PAYMENT_ADDRESS];
}

- (void)setFirstRunDialogShown:(BOOL)shown {
    [userDefaults setBool:shown forKey:FIRST_RUN_DIALOG_SHOWN];
    [userDefaults synchronize];
}

- (BOOL)firstRunDialogShown {
    return [userDefaults boolForKey:FIRST_RUN_DIALOG_SHOWN];
}

- (TotalBalanceHide)getTotalBalanceHide {
    return [userDefaults integerForKey:TOTAL_BALANCE_HIDE];
}

- (void)setTotalBalanceHide:(TotalBalanceHide)h {
    [userDefaults setInteger:h forKey:TOTAL_BALANCE_HIDE];
    [userDefaults synchronize];
}

@end
