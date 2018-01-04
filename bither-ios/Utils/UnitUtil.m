//
//  UnitUtil.m
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

#import "UnitUtil.h"
#import "UserDefaultsUtil.h"
#import "UIImage+ImageRenderToColor.h"

@implementation UnitUtil

+ (int64_t)amountForString:(NSString *)string unit:(BitcoinUnit)unit {
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange minusRange = [string rangeOfString:@"-"];
    BOOL negative = NO;
    if (minusRange.location == 0 && minusRange.length == 1) {
        string = [string substringFromIndex:minusRange.location + minusRange.length];
        negative = YES;
    }
    NSRange pointRange = [string rangeOfString:@"."];
    int64_t satoshis = [UnitUtil satoshisForUnit:unit];
    
    int64_t whole;
    if (pointRange.length > 0) {
        whole = [string substringWithRange:NSMakeRange(0, pointRange.location)].intValue;
    } else {
        whole = string.integerValue;
    }
    whole = whole * satoshis;
    
    int64_t part = 0;
    if (pointRange.length > 0) {
        NSString *partStr = [string substringFromIndex:pointRange.location + pointRange.length];
        int64_t desiredLength = log10(satoshis);
        if (desiredLength < partStr.length) {
            partStr = [partStr substringToIndex:desiredLength];
        }
        int64_t lackLength = desiredLength - partStr.length;
        if (lackLength >= 0) {
            part = partStr.integerValue * pow(10, lackLength);
        }
    }
    if (negative) {
        return 0 - (whole + part);
    } else {
        return whole + part;
    }
}

+ (int64_t)amountForString:(NSString *)string {
    return [UnitUtil amountForString:string unit:[UnitUtil unit]];
}

+ (NSString *)stringForAmount:(int64_t)amount unit:(BitcoinUnit)unit {
    NSString *sign = amount >= 0 ? @"" : @"-";
    uint64_t absValue = amount >= 0 ? amount : 0 - amount;
    NSUInteger unitSatoshis = [UnitUtil satoshisForUnit:unit];
    uint64_t coins = absValue / unitSatoshis;
    uint64_t satoshis = absValue % unitSatoshis;
    
    NSString *strSatoshis = [[NSString stringWithFormat:@"%llu", satoshis + unitSatoshis] substringFromIndex:1];
    
    if (unitSatoshis > pow(10, 2)) {
        strSatoshis = [strSatoshis stringByReplacingOccurrencesOfRegex:[NSString stringWithFormat:@"[0]{1,%llu}$", (uint64_t) log10f(unitSatoshis) - 2] withString:@""];
    }
    
    NSString *point = strSatoshis.length > 0 ? @"." : @"";
    
    return [NSString stringWithFormat:@"%@%llu%@%@", sign, coins, point, strSatoshis];
}

+ (NSString *)stringForAmount:(int64_t)amount {
    return [UnitUtil stringForAmount:amount unit:[UnitUtil unit]];
}

+ (NSString *)stringForAmount:(int64_t)amount coin:(SplitCoin)coin{
    if(coin == None) {
        return [UnitUtil stringForAmount:amount unit:[UnitUtil unit]];
    }
    return [UnitUtil stringForAmount:amount unit:[SplitCoinUtil getBitcoinUnit:coin]];
}

+ (NSMutableAttributedString *)attributedStringForAmount:(int64_t)amout withFontSize:(CGFloat)size {
    NSString *str = [UnitUtil stringForAmount:amout];
    NSUInteger pointLocation = [str rangeOfString:@"."].location;
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:size]}];
    NSUInteger boldAfterDot = [UnitUtil boldAfterDot];
    if (pointLocation + boldAfterDot + 1 < str.length) {
        [result addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:size * 0.85f] range:NSMakeRange(pointLocation + boldAfterDot + 1, str.length - pointLocation - boldAfterDot - 1)];
    }
    return result;
}

+ (NSMutableAttributedString *)attributedStringForAmount:(int64_t)amout withFontSize:(CGFloat)size coin:(SplitCoin)coin {
    NSString *str = [UnitUtil stringForAmount:amout coin:coin];
    NSUInteger pointLocation = [str rangeOfString:@"."].location;
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:size]}];
    NSUInteger boldAfterDot = [UnitUtil boldAfterDot];
    if (pointLocation + boldAfterDot + 1 < str.length) {
        [result addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:size * 0.85f] range:NSMakeRange(pointLocation + boldAfterDot + 1, str.length - pointLocation - boldAfterDot - 1)];
    }
    return result;
}

+ (NSMutableAttributedString *)attributedStringForAmount:(int64_t)amout withFontSize:(CGFloat)size unit:(BitcoinUnit)unit {
    NSString *str = [UnitUtil stringForAmount:amout unit:unit];
    NSUInteger pointLocation = [str rangeOfString:@"."].location;
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:size]}];
    NSUInteger boldAfterDot = [UnitUtil boldAfterDot];
    if (pointLocation + boldAfterDot + 1 < str.length) {
        [result addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:size * 0.85f] range:NSMakeRange(pointLocation + boldAfterDot + 1, str.length - pointLocation - boldAfterDot - 1)];
    }
    return result;
}

+ (NSMutableAttributedString *)attributedStringWithSymbolForAmount:(int64_t)amount withFontSize:(CGFloat)size color:(UIColor *)color {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:[UnitUtil attributedStringForAmount:amount withFontSize:size]];
    return [UnitUtil addSymbol:attr withFontSize:size color:color];
}

+ (NSMutableAttributedString *)attributedStringWithSymbolForAmount:(int64_t)amount withFontSize:(CGFloat)size color:(UIColor *)color coin:(SplitCoin)coin {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:[UnitUtil attributedStringForAmount:amount withFontSize:size coin:coin]];
    if(coin == None) {
         return [UnitUtil addSymbol:attr withFontSize:size color:color];
    }else{
         return [UnitUtil addSymbol:attr withFontSize:size coinCode:[SplitCoinUtil getSplitCoinName:coin]];
    }
   
}

+ (NSMutableAttributedString *)attributedStringWithSymbolForAmount:(int64_t)amount withFontSize:(CGFloat)size color:(UIColor *)color unit:(BitcoinUnit)unit {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:[UnitUtil attributedStringForAmount:amount withFontSize:size unit:unit]];
    return [UnitUtil addSymbol:attr withFontSize:size color:color];
}

+ (NSMutableAttributedString *)stringWithSymbolForAmount:(int64_t)amount withFontSize:(CGFloat)size color:(UIColor *)color {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[UnitUtil stringForAmount:amount]];
    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:size] range:NSMakeRange(0, attr.length)];
    return [UnitUtil addSymbol:attr withFontSize:size color:color];
}

+ (void)stringWithSymbolForAmount:(int64_t)amount source:(NSMutableAttributedString *)str {
    [str replaceCharactersInRange:NSMakeRange(2, str.length - 2) withString:[UnitUtil stringForAmount:amount]];
}

+ (NSMutableAttributedString *)addSymbol:(NSMutableAttributedString *)attr withFontSize:(CGFloat)size color:(UIColor *)color {
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    UIImage *symbol = [[UIImage imageNamed:[UnitUtil imageNameSlim:[UnitUtil unit]]] renderToColor:color];
    attachment.image = symbol;
    CGRect bounds = attachment.bounds;
    bounds.size = CGSizeMake(symbol.size.width * size / symbol.size.height, size);
    attachment.bounds = bounds;
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    [attr insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:0];
    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:size * 0.7f] range:NSMakeRange(0, 1)];
    [attr insertAttributedString:attachmentString atIndex:0];
    [attr addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithFloat:-size * 0.09f] range:NSMakeRange(0, 1)];
    return attr;
}

+ (NSMutableAttributedString *)addSymbol:(NSMutableAttributedString *)attr withFontSize:(CGFloat)size coinCode:(NSString *)code{
    [attr insertAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@",code]] atIndex:attr.length];
//    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:size * 0.7f] range:NSMakeRange(0, 1)];
//    [attr addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithFloat:-size * 0.09f] range:NSMakeRange(0, 1)];
    return attr;
}

+ (NSUInteger)satoshisForUnit:(BitcoinUnit)unit {
    switch (unit) {
        case Unitbits:
            return 100;
        case UnitBTW:
            return 10000;
        case UnitBCD:
            return 10000000;
        case UnitBTC:
        default:
            return 100000000;
    }
}

+ (NSUInteger)satoshis {
    return [UnitUtil satoshisForUnit:[UnitUtil unit]];
}

+ (NSUInteger)boldAfterDot:(BitcoinUnit)unit {
    switch (unit) {
        case Unitbits:
            return 0;
        case UnitBTC:
        default:
            return 2;
    }
}

+ (NSUInteger)boldAfterDot {
    return [UnitUtil boldAfterDot:[UnitUtil unit]];
}

+ (NSString *)unitName:(BitcoinUnit)unit {
    switch (unit) {
        case Unitbits:
            return @"bits";
        case UnitBTW:
            return @"BTW";
        case UnitBCD:
            return @"BCD";
        case UnitBTC:
        default:
            return @"BTC";
    }
}

+ (NSString *)unitName {
    return [UnitUtil unitName:[UnitUtil unit]];
}

+ (BitcoinUnit)unit {
    return [[UserDefaultsUtil instance] getBitcoinUnit];
}

+ (NSString *)imageName:(BitcoinUnit)unit {
    switch (unit) {
        case Unitbits:
            return @"symbol_bits";
        case UnitBTC:
        default:
            return @"symbol_btc";
    }
}

+ (NSString *)imageName {
    return [UnitUtil imageName:[UnitUtil unit]];
}

+ (NSString *)imageNameSlim:(BitcoinUnit)unit {
    switch (unit) {
        case Unitbits:
            return @"symbol_bits_slim";
        case UnitBTC:
        default:
            return @"symbol_btc_slim";
    }
}

+ (NSString *)imageNameSlim {
    return [UnitUtil imageNameSlim:[UnitUtil unit]];
}

@end
