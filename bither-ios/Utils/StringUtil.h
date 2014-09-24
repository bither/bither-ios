//  StringUtil.h
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
#import "RegexKitLite.h"
#import <CoreLocation/CoreLocation.h>

@interface StringUtil : NSObject{
    
}

+(NSString *)formatPrice:(double) value;
+(NSString * )formatDouble:(double) value;

+ (int64_t)amountForString:(NSString *)string;
+ (NSString *)stringForAmount:(int64_t)amount;
+(NSMutableAttributedString*)attributedStringForAmount:(int64_t)amout withFontSize:(CGFloat)size;
+(NSMutableAttributedString*)attributedStringWithSymbolForAmount:(int64_t)amount withFontSize:(CGFloat)size color:(UIColor*)color;
+(NSMutableAttributedString*)stringWithSymbolForAmount:(int64_t)amount withFontSize:(CGFloat)size color:(UIColor*)color;
+(void)stringWithSymbolForAmount:(int64_t)amount source:(NSMutableAttributedString*)str;
+(BOOL) isEmpty:(NSString *) str;
+(BOOL)validEmail:(NSString*)str;
+(BOOL)validPassword:(NSString *)str;
+(BOOL)validPartialPassword:(NSString *)str;
+(NSString *) intToString:(int) num;
+(NSString *)longToString:(long) num;
+(BOOL)isPureLongLong:(NSString *)string;
+(BOOL)isPureFloat:(NSString *)string;

+(BOOL)compareString:(NSString *) original compare:(NSString *)compare;+(NSString *)shortenAddress:(NSString *)address;
+(NSString *)formatAddress:(NSString *)address groupSize:(NSInteger)groupSize  lineSize:(NSInteger) lineSize;
+(NSString *)longToHex:(long long) value;
+(long long)hexToLong:(NSString *)hex;

@end
