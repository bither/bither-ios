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

#import "UserDefaultsUtil.h"

#define PREFS_KEY_LAST_VERSION @"last_version"
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




static UserDefaultsUtil *userDefaultsUtil;

NSUserDefaults *userDefaults;

@implementation UserDefaultsUtil

+ (UserDefaultsUtil *)instance {
    @synchronized(self) {
        if (userDefaultsUtil == nil) {
            userDefaultsUtil = [[self alloc] init];
            userDefaults = [NSUserDefaults  standardUserDefaults];
        }
    }
    return userDefaultsUtil;
}

-(NSInteger)getLastVersion{
    return [userDefaults integerForKey:PREFS_KEY_LAST_VERSION];
}

-(void)setLastVersion:(NSInteger) version{
    [userDefaults setInteger:version forKey:PREFS_KEY_LAST_VERSION];
    [userDefaults synchronize];
}
-(MarketType)getDefaultMarket{
    if (![userDefaults objectForKey:DEFAULT_MARKET]) {
        [self setDefaultMarket];
    }
    return [self getMarket];
}
-(MarketType) getMarket{
    NSInteger market=[userDefaults integerForKey:DEFAULT_MARKET];
    return market;
}
-(void)setDefaultMarket{
    if ([self localeIsChina]){
        [self setMarket:HUOBI];
    }else{
        [self setMarket:BITSTAMP];
    }

}
-(void)setMarket:(MarketType) marketType{
    [userDefaults setInteger:marketType forKey:DEFAULT_MARKET];
    [userDefaults synchronize];
}

-(void)setExchangeType:(Currency) exchangeType{
    [userDefaults setInteger:exchangeType forKey:DEFAULT_EXCHANGE_RATE];
    [userDefaults synchronize];
}
-(Currency)getDefaultCurrency {
    NSInteger type=[self  getExchangeType];
    if (type==-1) {
        [self setDefaultExchangeType];
    }
    return [self getExchangeType];
}
-(void) setDefaultExchangeType{
  
    if ([self localeIsChina]) {
        [self setExchangeType:CNY];
    }else{
        [self setExchangeType:USD];
    }
}
-(BOOL)localeIsChina{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    return  [language isEqualToString:@"zh-Hans"];
}

-(NSInteger) getExchangeType{
    if ([userDefaults objectForKey:DEFAULT_EXCHANGE_RATE]){
        return [userDefaults integerForKey:DEFAULT_EXCHANGE_RATE];
    }else{
        return -1;
    }
}




-(long long)getLastCheckPrivateKeyTime{
    return [[userDefaults objectForKey:LAST_CHECK_PRIVATE_KEY_TIME] longLongValue];
}
-(void)setLastCheckPrivateKeyTime:(long long)time{
    [userDefaults setObject:[NSNumber numberWithLongLong:time] forKey:LAST_CHECK_PRIVATE_KEY_TIME];
    [userDefaults synchronize];
}

-(long long)getLastBackupKeyTime{
    return [[userDefaults objectForKey:LAST_BACK_UP_PRIVATE_KEY_TIME] longLongValue];
}
-(void)setLastBackupKeyTime:(long long) time{
    [userDefaults setObject:[NSNumber numberWithLongLong:time] forKey:LAST_BACK_UP_PRIVATE_KEY_TIME];
    [userDefaults synchronize];
}
-(BOOL)hasPrivateKey{
    return [userDefaults boolForKey:HAS_PRIVATE_KEY];
}

-(void)setHasPrivateKey:(BOOL) hasPrivateKey{
    [userDefaults setBool:hasPrivateKey forKey:HAS_PRIVATE_KEY];
    [userDefaults synchronize];
}

-(BOOL)getSyncBlockOnlyWifi{
    return [userDefaults boolForKey:SYNC_BLOCK_ONLY_WIFI];
}
-(void)setSyncBlockOnlyWifi:(BOOL)onlyWifi{
    [userDefaults setBool:onlyWifi forKey:SYNC_BLOCK_ONLY_WIFI];
    [userDefaults synchronize];
}
-(BOOL)getDownloadSpvFinish{
    return [userDefaults boolForKey:DOWNLOAD_SPV_FINISH];
}
-(void)setDownloadSpvFinish:(BOOL)finish{
    [userDefaults setBool:finish forKey:DOWNLOAD_SPV_FINISH];
    [userDefaults synchronize];
}

-(BTPasswordSeed *)getPasswordSeed{
    NSString * str=[userDefaults stringForKey:PASSWORD_SEED];
    if ([StringUtil isEmpty:str]) {
        return nil;
    }
    return [[BTPasswordSeed alloc] initWithString:str];
}

-(void)setPasswordSeed:(BTPasswordSeed *)passwordSeed{
    [userDefaults setValue:[passwordSeed toPasswrodSeedString] forKey:PASSWORD_SEED];
    [userDefaults synchronize];

}
-(TransactionFeeMode) getTransactionFeeMode{
    if ([userDefaults objectForKey:TRANSACTION_FEE_MODE]) {
        if ([userDefaults integerForKey:TRANSACTION_FEE_MODE]==Low) {
            return Low;
        }else{
            return Normal;
        }
    }else{
        return Normal;
    }
}
-(void)setTransactionFeeMode :(TransactionFeeMode ) feeMode{
    if (!feeMode) {
        feeMode=Normal;
    }
    [userDefaults setInteger:feeMode forKey:TRANSACTION_FEE_MODE];
    [userDefaults synchronize];
}
-(BOOL) hasUserAvatar{
     return [StringUtil isEmpty:[self getUserAvatar]];

}

-(NSString *)getUserAvatar{
    return [userDefaults stringForKey:USER_AVATAR];
}

-(void) setUserAvatar:(NSString *)avatar{
    [userDefaults setObject:avatar forKey:USER_AVATAR];
    [userDefaults synchronize];
}
-(NSInteger)getQrCodeTheme{
    return [userDefaults integerForKey:FANCY_QR_CODE_THEME];
}

-(void)setQrCodeTheme:(NSInteger) qrCodeTheme{
    [userDefaults setInteger:qrCodeTheme forKey:FANCY_QR_CODE_THEME];
    [userDefaults synchronize];
}


-(void)setBitcoinUnit:(BitcoinUnit)bitcoinUnit{
    [userDefaults setInteger:bitcoinUnit forKey:BITCOIN_UNIT];
    [userDefaults synchronize];
}

-(BitcoinUnit)getBitcoinUnit{
    if([userDefaults objectForKey:BITCOIN_UNIT]){
        return [userDefaults integerForKey:BITCOIN_UNIT];
    }
    return BTC;
}

@end















