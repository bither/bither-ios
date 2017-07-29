//
//  Setting.h
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
#import "BitherSetting.h"

#define  SETTING_KEY @"key"
#define  SETTING_KEY_ATTRIBUTED @"key_attributed"
#define  SETTING_VALUE @"VALUE"
#define  SETTING_IS_DEFAULT @"default"

@interface Setting : NSObject

@property(nonatomic, strong) NSString *settingName;
@property(nonatomic, strong) UIImage *icon;


@property(nonatomic, strong) GetValueBlock getValueBlock;
@property(nonatomic, strong) GetArrayBlock getArrayBlock;
@property(nonatomic, strong) DictResponseBlock result;
@property(nonatomic, strong) ViewControllerBlock selectBlock;

- (instancetype)initWithName:(NSString *)name icon:(UIImage *)icon;

- (void)selection;

- (UIImage *)getIcon;

+ (Setting *)getMarketSetting;

+ (Setting *)getExchangeSetting;

+ (Setting *)getBitcoinUnitSetting;

+ (Setting *)getTransactionFeeSetting;

+ (Setting *)getCheckSetting;

+ (Setting *)getAdvanceSetting;

+ (Setting *)getColdMonitorSetting;

+ (Setting *)getTrashCanSetting;

+ (Setting *)getSwitchToColdSetting;

+ (Setting *)getKeychainSetting;

+ (Setting *)getTotalBalanceHideSetting;

+ (Setting *)getApiConfigSetting;

@end
