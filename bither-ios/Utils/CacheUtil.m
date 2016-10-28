//
//  CacheUtil.m
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

#import "CacheUtil.h"

#define BITHER_BACKUP_SDCARD_DIR @"BitherBackup"
#define BITHER_BACKUP_ROM_DIR @"backup"

#define BITHER_BACKUP_HOT_FILE_NAME @"keys"

#define WALLET_SEQUENCE_WATCH_ONLY @"sequence_watch_only"
#define WALLET_SEQUENCE_PRIVATE @"sequence_private"

#define EXCAHNGE_TICKER_NAME @"exchange.ticker"
#define EXCHANGE_KLINE_NAME @"exchange.kline"
#define EXCHANGE_DEPTH_NAME @"exchange.depth"
#define PRICE_ALERT @"price.alert"
#define ADDRESS_LIST @"address_list"

#define EXCHANGERATE @"exchangerate"
#define CURRENCIES_RATE @"currencies_rate"
#define MARKET_CAHER @"mark"

#define IMAGE_CACHE_DIR @"image"
#define IMAGE_SHARE_FILE_NAME @"share.jpg"

#define IMAGE_CACHE_UPLOAD =@"image/upload"
#define IMAGE_CACHE_612 = @"image/612"
#define IMAGE_CACHE_150 = @"image/150"


@implementation CacheUtil
+ (NSString *)getExchangeFile {
    NSString *cacheDir = [CacheUtil cachePathForFileName:@""];
    return [cacheDir stringByAppendingPathComponent:EXCHANGERATE];
}

+ (NSString *)getCurrenciesRateFile {
    NSString *cacheDir = [CacheUtil cachePathForFileName:@""];
    return [cacheDir stringByAppendingPathComponent:CURRENCIES_RATE];
}

+ (NSString *)getTickerFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *marketDir = [CacheUtil cachePathForFileName:MARKET_CAHER];
    if (![fileManager fileExistsAtPath:marketDir]) {
        BOOL fileExists = [fileManager fileExistsAtPath:marketDir];
        if (!fileExists) {
            [fileManager createDirectoryAtPath:marketDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return [marketDir stringByAppendingPathComponent:EXCAHNGE_TICKER_NAME];
}

+ (void)writeFile:(NSString *)fileName content:(NSString *)content {
    [content writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (NSString *)readFile:(NSString *)fileName {
    NSData *data = [NSData dataWithContentsOfFile:[CacheUtil getTickerFile]];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSString *)cachePathForFileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:fileName];
}


@end
