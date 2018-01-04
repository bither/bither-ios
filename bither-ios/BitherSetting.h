//
//  BitherSetting.h
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
#import "MKNetworkEngine.h"
#import "BTSettings.h"
#import "GroupUtil.h"

#define BitherMarketUpdateNotification  @"BitherMarketUpdateNotification"
#define BitherAddressNotification  @"BitherAddressNotification"
#define DONATE_ADDRESS  @"1BitherUnNvB2NsfxMnbS35kS3DTPr7PW5"
#define DONATE_AMOUNT (100000)


#define PRIVATE_KEY_OF_HOT_COUNT_LIMIT (50)
#define PRIVATE_KEY_OF_COLD_COUNT_LIMIT (150)
#define WATCH_ONLY_COUNT_LIMIT (150)
#define HDM_ADDRESS_PER_SEED_COUNT_LIMIT (100)
#define HDM_ADDRESS_PER_SEED_PREPARE_COUNT (100)


#define FORMAT_TIMESTAMP_INTERVAL 1000

#define ColorTextGray1 [UIColor colorWithWhite:0.78 alpha:1.0]
#define ColorTextGray2 [UIColor colorWithWhite:0.42 alpha:1.0]
#define ColorUserName [UIColor colorWithRed:100.0/255 green:129.0/255 blue:157.0/255 alpha:1.0]
#define ColorAmt [UIColor colorWithRed:1 green:133.0 / 255 blue:44.0 /255 alpha:1]
#define ColorTableHeader [UIColor colorWithRed:241.0/255 green:241.0/255 blue:241.0/255 alpha:0.9]
#define ColorBg [UIColor colorWithRed:66.0/255 green:94.0/255 blue:122.0/255 alpha:1.0]
#define ColorProgress [UIColor colorWithRed:29.0/255 green:86.0/255 blue:119.0/255 alpha:1.0]
#define ColorDivide [UIColor colorWithWhite:0.86 alpha:1.0]
#define ColorButton [UIColor colorWithRed:50.0/255 green:79.0/255 blue:133.0/255 alpha:1.0]

#define ColorAmtIncoming [UIColor colorWithRed:117.0/255.0 green:193.0 / 255.0 blue:27.0 /255.0 alpha:1]
#define ColorAmtOutgoing [UIColor colorWithRed:254.0/255.0 green:118.0 / 255.0 blue:18.0 /255.0 alpha:1]

#define CardMargin 10.0f
#define CardTopOffset 9.0f
#define CardBottomOffset 5.0f
#define CardCornerRedius 8.0f

#define ColorTextGray1 [UIColor colorWithWhite:0.78 alpha:1.0]
#define ColorTextGray2 [UIColor colorWithWhite:0.42 alpha:1.0]
#define ColorUserName [UIColor colorWithRed:100.0/255 green:129.0/255 blue:157.0/255 alpha:1.0]
#define ColorAmt [UIColor colorWithRed:1 green:133.0 / 255 blue:44.0 /255 alpha:1]
#define ColorTableHeader [UIColor colorWithRed:241.0/255 green:241.0/255 blue:241.0/255 alpha:0.9]
#define ColorProgress [UIColor colorWithRed:29.0/255 green:86.0/255 blue:119.0/255 alpha:1.0]
#define ColorDivide [UIColor colorWithWhite:0.86 alpha:1.0]
#define ColorButton [UIColor colorWithRed:50.0/255 green:79.0/255 blue:133.0/255 alpha:1.0]

#define CardMargin 10.0f
#define CardTopOffset 9.0f
#define CardBottomOffset 5.0f
#define CardCornerRedius 8.0f

#define ImageCompressionQuality 0.445

#define NavHeight 44.0f
#define TabBarHeight 44.0f

#define SMALL_IMAGE_WIDTH  150
#define IMAGE_WIDTH 612

#define CFBundleShortVersionString @"CFBundleShortVersionString"

#define ERR_API_400_DOMAIN @"http400"
#define ERR_API_500_DOMAIN @"http500"

#define HDMBID_IS_ALREADY_EXISTS 1001
#define MESSAGE_SIGNATURE_IS_WRONG 1002
#define HDMBID_SHOULD_BIND_TO_AN_ADDRESS 1003
#define HDMBID_IS_NOT_EXIST 1004
#define HDMBID_PASSWORD_WRONG 1005
#define HDM_PUBKEY_IS_EXISTS 1006
#define HDM_SIGNATURE_FAILED 1007
#define HDSEED_IS_NOT_EXIST 2001
#define HDM_SERVICE_SIGNATURE_FAILED 2002

typedef void (^DictResponseBlock)(NSDictionary *dict);

typedef void (^IdResponseBlock)(id response);

typedef void (^ArrayResponseBlock)(NSArray *array);

typedef void (^ImageResponseBlock)(UIImage *image, NSURL *url);

typedef void (^ErrorHandler)(NSOperation *errorOp, NSError *error);

typedef void (^CompletedOperation)(MKNetworkOperation *completedOperation);

typedef void (^ResponseFormat)(MKNetworkOperation *completedOperation);

typedef void (^LongResponseBlock)(long long num);

typedef void (^StringBlock)(NSString *string);

typedef void (^VoidBlock)(void);

typedef void (^ErrorBlock)(NSError *error);

typedef void (^ViewControllerBlock)(UIViewController *controller);

typedef NSObject *(^GetValueBlock)(void);

typedef NSArray *(^GetArrayBlock)(void);


typedef enum {
    ONE_MINUTE = 1, FIVE_MINUTES = 5, ONE_HOUR = 60, ONE_DAY = 1440
} KLineTimeType;

typedef enum {
    Normal = 10000, High = 20000, Higher = 50000, TenX = 100000, TwentyX = 200000
} TransactionFeeMode;

typedef enum {
    USD, CNY, EUR, GBP, JPY, KRW, CAD, AUD
} Currency;

typedef enum {
    UnitBTC, Unitbits, UnitBTW, UnitBCD
} BitcoinUnit;

typedef enum {
    AddressNormal, AddressTxTooMuch, AddressSpecialAddress
} AddressType;

#define CustomErrorDomain @"www.bither.net"
typedef enum {

    PasswordError = -1000,

} CustomErrorFailed;

typedef enum {
    Text, Encrypted, Decrypetd, BIP38
} PrivateKeyQrCodeType;

typedef enum {
    Off = 0, On = 1
} KeychainMode;

@interface BitherSetting : NSObject


+ (NSString *)getCurrencySymbol:(Currency)currency;

+ (NSString *)getCurrencyName:(Currency)currency;

+ (Currency)getCurrencyFromName:(NSString *)currencyName;

+ (NSString *)getTransactionFeeMode:(TransactionFeeMode)transactionFee;

+ (NSString *)getTransactionFee:(TransactionFeeMode)transactionFee;

+ (NSString *)getKeychainMode:(KeychainMode)keychainMode;

+ (BOOL)isUnitTest;

+ (void)setIsUnitTest:(BOOL)isUnitTest;

@end
