//
//  KeychainUtil.h
//  bither-ios
//
//  Created by ZhouQi on 14/11/21.
//  Copyright (c) 2014年 ZhouQi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainUtil : NSObject

+ (BOOL)setKeychainData:(NSData *)data andKey:( NSString *)key andAuthenticated:(BOOL) authenticated;
+ (NSData *)getKeychainData:(NSString *)key;
+ (BOOL)setKeychainInt:(int64_t)i andKey:(NSString *) key andAuthenticated:(BOOL) authenticated;
+ (int64_t)getKeychainInt:(NSString *)key;
+ (BOOL)setKeychainString:(NSString *)s andKey:(NSString *)key andAuthenticated:(BOOL) authenticated;
+ (NSString *)getKeychainString:(NSString *) key;

@end
