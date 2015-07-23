//
//  GroupFileUtil.m
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
//
//  Created by songchenwen on 2015/2/27.
//

#import "GroupFileUtil.h"
#import "CacheUtil.h"

#define CURRENCIES_RATE (@"currencies_rate")
#define MARKET_CACHE_DIR (@"market")
#define EXCAHNGE_TICKER_NAME (@"exchange.ticker")
#define TOTAL_BALANCE (@"total_balance")

@implementation GroupFileUtil

+ (void)setTotalBalanceWithHD:(int64_t)hd hdMonitored:(int64_t)hdMonitored hot:(int64_t)hot andCold:(int64_t)cold HDM:(int64_t)hdm {
    NSDictionary *dict = @{@"hd" : @(hd), @"hdMonitored" : @(hdMonitored), @"hdm" : @(hdm), @"hot" : @(hot), @"cold" : @(cold)};

    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (error) {
        NSLog(@"JSON Writing Error: %@", error);
        return;
    }
    [GroupFileUtil writeFile:[GroupFileUtil totalBalanceFile] content:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}

+ (NSDictionary *)totalBalance {
    NSString *s = [GroupFileUtil readFile:[GroupFileUtil totalBalanceFile]];
    if (s) {
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[s dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if (error) {
            NSLog(@"JSON Parsing Error: %@", error);
            return @{@"hd" : @(0), @"hdMonitored" : @(0), @"hdm" : @(0), @"hot" : @(0), @"cold" : @(0)};
        } else {
            return dict;
        }
    } else {
        return @{@"hd" : @(0), @"hdMonitored" : @(0), @"hdm" : @(0), @"hot" : @(0), @"cold" : @(0)};
    }
}

+ (void)setTicker:(NSString *)content {
    if ([GroupFileUtil supported]) {
        [GroupFileUtil writeFile:[GroupFileUtil tickerFile] content:content];
    } else {
        [CacheUtil writeFile:[CacheUtil getTickerFile] content:content];
    }
}

+ (NSString *)getTicker {
    if ([GroupFileUtil supported]) {
        return [GroupFileUtil readFile:[GroupFileUtil tickerFile]];
    } else {
        return [CacheUtil readFile:[CacheUtil getTickerFile]];
    }
}

+ (void)setCurrencyRate:(NSString *)currencyRate {
    if ([GroupFileUtil supported]) {
        [GroupFileUtil writeFile:[GroupFileUtil currencyRateFile] content:currencyRate];
    } else {
        [CacheUtil writeFile:[CacheUtil getCurrenciesRateFile] content:currencyRate];
    }
}

+ (NSString *)getCurrencyRate {
    if ([GroupFileUtil supported]) {
        return [GroupFileUtil readFile:[GroupFileUtil currencyRateFile]];
    } else {
        return [CacheUtil readFile:[CacheUtil getCurrenciesRateFile]];
    }
}

+ (NSURL *)currencyRateFile {
    return [[GroupFileUtil documents] URLByAppendingPathComponent:CURRENCIES_RATE];
}

+ (NSURL *)tickerFile {
    NSURL *dir = [[GroupFileUtil documents] URLByAppendingPathComponent:MARKET_CACHE_DIR];

    NSError *error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:dir withIntermediateDirectories:YES attributes:nil error:&error];

    if (success) {
        return [dir URLByAppendingPathComponent:EXCAHNGE_TICKER_NAME];
    } else {
        NSLog(@"Shared market cache dir error: %@", error.localizedDescription);
        abort();
    }
}

+ (NSURL *)totalBalanceFile {
    return [[GroupFileUtil documents] URLByAppendingPathComponent:TOTAL_BALANCE];
}

+ (NSString *)readFile:(NSURL *)url {
    NSCondition *c = [NSCondition new];
    __block NSString *result = nil;
    [GroupFileUtil readFromURL:url withCompletion:^(NSData *data, NSError *error) {
        if (data) {
            result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        } else {
            NSLog(@"group read error %@", error.debugDescription);
        }
        [c lock];
        [c signal];
        [c unlock];
    }];
    [c lock];
    [c wait];
    [c unlock];
    return result;
}

+ (BOOL)writeFile:(NSURL *)url content:(NSString *)content {
    NSCondition *c = [NSCondition new];
    __block BOOL result = YES;
    [GroupFileUtil writeToURL:url withData:[content dataUsingEncoding:NSUTF8StringEncoding] withCompletion:^(NSError *error) {
        if (error) {
            NSLog(@"group write error %@", error.debugDescription);
            result = NO;
        }
        [c lock];
        [c signal];
        [c unlock];
    }];
    [c lock];
    [c wait];
    [c unlock];
    return result;
}

+ (void)readFromURL:(NSURL *)url withCompletion:(void (^)(NSData *data, NSError *error))completion {
    if (![GroupFileUtil supported]) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:@"group.net.bither" code:0 userInfo:nil]);
        }
        return;
    }
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];

    BOOL successfulSecurityScopedResourceAccess = [url startAccessingSecurityScopedResource];

    NSFileAccessIntent *readingIntent = [NSFileAccessIntent readingIntentWithURL:url options:NSFileCoordinatorReadingWithoutChanges];

    [fileCoordinator coordinateAccessWithIntents:@[readingIntent] queue:[GroupFileUtil queue] byAccessor:^(NSError *accessError) {
        if (accessError) {
            if (successfulSecurityScopedResourceAccess) {
                [url stopAccessingSecurityScopedResource];
            }

            if (completion) {
                completion(nil, accessError);
            }
            return;
        }

        NSError *readError;
        NSData *contents = [NSData dataWithContentsOfURL:readingIntent.URL options:NSDataReadingUncached error:&readError];
        if (successfulSecurityScopedResourceAccess) {
            [url stopAccessingSecurityScopedResource];
        }

        if (completion) {
            completion(contents, readError);
        }
    }];
}

+ (void)writeToURL:(NSURL *)url withData:(NSData *)data withCompletion:(void (^)(NSError *error))completion {
    if (![GroupFileUtil supported]) {
        if (completion) {
            completion([NSError errorWithDomain:@"group.net.bither" code:0 userInfo:nil]);
        }
        return;
    }

    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];

    BOOL successfulSecurityScopedResourceAccess = [url startAccessingSecurityScopedResource];

    NSFileAccessIntent *writingIntent = [NSFileAccessIntent writingIntentWithURL:url options:NSFileCoordinatorWritingForReplacing];

    [fileCoordinator coordinateAccessWithIntents:@[writingIntent] queue:[GroupFileUtil queue] byAccessor:^(NSError *accessError) {
        if (accessError) {
            if (successfulSecurityScopedResourceAccess) {
                [url stopAccessingSecurityScopedResource];
            }

            if (completion) {
                completion(accessError);
            }
            return;
        }


        NSError *error;
        BOOL success = [data writeToURL:writingIntent.URL options:NSDataWritingAtomic error:&error];

        if (successfulSecurityScopedResourceAccess) {
            [url stopAccessingSecurityScopedResource];
        }

        if (completion) {
            completion(error);
        }
    }];
}

+ (NSURL *)groupContainer {
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kBitherGroupName];
    return containerURL;
}

+ (NSURL *)documents {
    NSURL *documentsURL = [[GroupFileUtil groupContainer] URLByAppendingPathComponent:@"Documents" isDirectory:YES];

    NSError *error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:documentsURL withIntermediateDirectories:YES attributes:nil error:&error];

    if (success) {
        return documentsURL;
    } else {
        NSLog(@"The shared application group documents directory doesn't exist and could not be created. Error: %@", error.localizedDescription);
        abort();
    }
}

+ (NSOperationQueue *)queue {
    static NSOperationQueue *queue;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc] init];
    });

    return queue;
}

+ (BOOL)supported {
    return [[[NSFileCoordinator alloc] init] respondsToSelector:@selector(coordinateAccessWithIntents:queue:byAccessor:)];
}

+ (BOOL)localeIsChina {
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    return [language isEqualToString:@"zh-Hans"];
}

@end
