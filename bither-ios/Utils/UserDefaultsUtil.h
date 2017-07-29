//  UserDefaultsUtil.h
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

#import <Foundation/Foundation.h>
#import "StringUtil.h"
#import "BitherSetting.h"
#import "BTPasswordSeed.h"
#import "TotalBalanceHideUtil.h"
#import "ApiConfig.h"


///@description   UserDefaults相关
@interface UserDefaultsUtil : NSObject
+ (UserDefaultsUtil *)instance;


- (NSInteger)getLastVersion;

- (void)setLastVersion:(NSInteger)version;

- (MarketType)getDefaultMarket;

- (void)setMarket:(MarketType)marketType;

- (void)setExchangeType:(Currency)exchangeType;

- (Currency)getDefaultCurrency;

- (void)setBitcoinUnit:(BitcoinUnit)bitcoinUnit;

- (BitcoinUnit)getBitcoinUnit;

- (long long)getLastCheckPrivateKeyTime;

- (void)setLastCheckPrivateKeyTime:(long long)time;

- (long long)getLastBackupKeyTime;

- (void)setLastBackupKeyTime:(long long)time;

- (BOOL)hasPrivateKey;

- (void)setHasPrivateKey:(BOOL)hasPrivateKey;

- (BOOL)getSyncBlockOnlyWifi;

- (void)setSyncBlockOnlyWifi:(BOOL)onlyWifi;

- (BOOL)getDownloadSpvFinish;

- (void)setDownloadSpvFinish:(BOOL)finish;

- (BTPasswordSeed *)getPasswordSeedForOldVersion;
//-(void)setPasswordSeed:(BTPasswordSeed *)passwordSeed;

- (TransactionFeeMode)getTransactionFeeMode;

- (void)setTransactionFeeMode:(TransactionFeeMode)feeMode;

- (BOOL)hasUserAvatar;

- (NSString *)getUserAvatar;

- (void)setUserAvatar:(NSString *)avatar;

- (NSInteger)getQrCodeTheme;

- (void)setQrCodeTheme:(NSInteger)qrCodeTheme;

- (void)setPinCode:(NSString *)code;

- (BOOL)hasPinCode;

- (void)deletePinCode;

- (BOOL)checkPinCode:(NSString *)code;

- (BOOL)localeIsChina;

- (BOOL)localeIsZHHant;

- (KeychainMode)getKeychainMode;

- (void)setKeychainMode:(KeychainMode)keychainMode;

- (void)setPasswordStrengthCheck:(BOOL)check;

- (BOOL)getPasswordStrengthCheck;

- (void)setPaymentAddress:(NSString *)address;

- (NSString *)paymentAddress;

- (void)setFirstRunDialogShown:(BOOL)shown;

- (BOOL)firstRunDialogShown;

- (TotalBalanceHide)getTotalBalanceHide;

- (void)setTotalBalanceHide:(TotalBalanceHide)h;

- (void)setApiConfig:(ApiConfig) config;

- (ApiConfig)getApiConfig;

- (void)setUpdateCode:(NSInteger) updateCode;

- (NSInteger)getUpdateCode;

- (void)setIsObtainBccKey:(NSString *)key value:(NSString *)value;

- (BOOL)getIsObtainBccForKey:(NSString *)key;

@end
