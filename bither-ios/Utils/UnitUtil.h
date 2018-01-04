//
//  UnitUtil.h
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
#import "SplitCoinUtil.h"

@interface UnitUtil : NSObject

+ (NSString *)unitName:(BitcoinUnit)unit;

+ (NSString *)unitName;

+ (NSUInteger)satoshisForUnit:(BitcoinUnit)unit;

+ (NSUInteger)satoshis;

+ (NSUInteger)boldAfterDot:(BitcoinUnit)unit;

+ (NSUInteger)boldAfterDot;

+ (NSString *)imageName:(BitcoinUnit)unit;

+ (NSString *)imageName;

+ (NSString *)imageNameSlim:(BitcoinUnit)unit;

+ (NSString *)imageNameSlim;

+ (int64_t)amountForString:(NSString *)string;

+ (int64_t)amountForString:(NSString *)string unit:(BitcoinUnit)unit;

+ (NSString *)stringForAmount:(int64_t)amount;

+ (NSString *)stringForAmount:(int64_t)amount unit:(BitcoinUnit)unit;

+ (NSMutableAttributedString *)attributedStringForAmount:(int64_t)amout withFontSize:(CGFloat)size;

+ (NSMutableAttributedString *)attributedStringForAmount:(int64_t)amout withFontSize:(CGFloat)size unit:(BitcoinUnit)unit;

+ (NSMutableAttributedString *)attributedStringWithSymbolForAmount:(int64_t)amount withFontSize:(CGFloat)size color:(UIColor *)color;

+ (NSMutableAttributedString *)attributedStringWithSymbolForAmount:(int64_t)amount withFontSize:(CGFloat)size color:(UIColor *)color coin:(SplitCoin)coin;

+ (NSMutableAttributedString *)attributedStringWithSymbolForAmount:(int64_t)amount withFontSize:(CGFloat)size color:(UIColor *)color unit:(BitcoinUnit)unit;

+ (NSMutableAttributedString *)stringWithSymbolForAmount:(int64_t)amount withFontSize:(CGFloat)size color:(UIColor *)color;

+ (void)stringWithSymbolForAmount:(int64_t)amount source:(NSMutableAttributedString *)str;

+ (BitcoinUnit)unit;

@end
