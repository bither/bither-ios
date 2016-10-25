//  StringUtil.m
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

#import "StringUtil.h"
#import "BitherSetting.h"
#import "UnitUtil.h"
#import "UserDefaultsUtil.h"


#define BTC         @"\xC9\x83"     // capital B with stroke (utf-8)
#define BITS        @"\xC6\x80"     // lowercase b with stroke (utf-8)
#define NARROW_NBSP @"\xE2\x80\xAF" // narrow no-break space (utf-8)
#define BIP21ADDRESS_REGEX  @"^bitcoin:(\\/\\/)?([123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]{20,40})(\\?(.+))?$"
#define BIP21AMT_REGEX  @"^(.*)amount=([1-9]\\d*\\.\\d*|0\\.\\d*[1-9]\\d*)(.*)$"


@implementation StringUtil

+ (NSString *)formatPrice:(double)value {
    NSString *symobl = [BitherSetting getCurrencySymbol:[[UserDefaultsUtil instance] getDefaultCurrency]];
    return [NSString stringWithFormat:@"%@%.2f", symobl, value];
}

+ (NSString *)formatDouble:(double)value {
    return [NSString stringWithFormat:@"%.2f", value];
}

+ (BOOL)isEmpty:(NSString *)str {
    return str == nil || str.length == 0;
}

+ (BOOL)validEmail:(NSString *)str {
    NSString *regex = @"(^[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})$)";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:str];
}

+ (BOOL)validPassword:(NSString *)str {
    NSString *regex = @"[0-9a-zA-Z`~!@#$%^&*()_\\-+=|{}':;',\\[\\].\\\"\\\\<>/?]{6,43}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:str];
}

+ (BOOL)validPartialPassword:(NSString *)str {
    NSString *regex = @"[0-9a-zA-Z`~!@#$%^&*()_\\-+=|{}':;',\\[\\].\\\"\\\\<>/?]{0,43}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:str];
}


//BIP21 https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki

+ (BOOL)isValidBitcoinBIP21Address:(NSString *)str {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:BIP21ADDRESS_REGEX options:0 error:&error];
    NSArray *matchs = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    return matchs.count > 0;


}

+ (NSString *)getAddressFormBIP21Address:(NSString *)str {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:BIP21ADDRESS_REGEX options:0 error:&error];
    NSArray *matchs = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    if (matchs.count > 0) {
        NSTextCheckingResult *match = [matchs objectAtIndex:0];
        NSRange range = [match rangeAtIndex:2];
        return [str substringWithRange:range];
    } else {
        return @"";
    }
}

+ (uint64_t)getAmtFormBIP21Address:(NSString *)str {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:BIP21AMT_REGEX options:0 error:&error];
    NSArray *matchs = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    if (matchs.count > 0) {
        NSTextCheckingResult *match = [matchs objectAtIndex:0];
        NSRange range = [match rangeAtIndex:2];
        return [UnitUtil amountForString:[str substringWithRange:range] unit:UnitBTC];
    } else {
        return -1;
    }
}


+ (BOOL)isPureLongLong:(NSString *)string {
    NSScanner *scan = [NSScanner scannerWithString:string];
    long long val;
    return [scan scanLongLong:&val] && [scan isAtEnd];
}

+ (BOOL)isPureFloat:(NSString *)string {
    NSScanner *scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}


+ (NSString *)intToString:(int)num {
    return [NSString stringWithFormat:@"%d", num];
}

+ (NSString *)longToString:(long)num {
    return [NSString stringWithFormat:@"%ld", num];
}

+ (BOOL)compareString:(NSString *)original compare:(NSString *)compare {
    if (original == nil) {
        if (compare == nil) {
            return YES;
        } else {
            return NO;
        }
    } else {
        if (compare == nil) {
            return NO;
        } else {
            return [original isEqualToString:compare];
        }
    }
}

+ (NSString *)shortenAddress:(NSString *)address {
    if (!address || address.length <= 4) {
        return address;
    } else {
        return [[address substringToIndex:4] stringByAppendingString:@"..."];
    }
}

+ (NSString *)formatAddress:(NSString *)address groupSize:(NSInteger)groupSize lineSize:(NSInteger)lineSize {
    NSInteger len = address.length;
    NSString *result = @"";

    for (NSInteger i = 0; i < len; i += groupSize) {
        NSInteger end = groupSize;
        if (i + groupSize > len) {
            end = len - i;
        }
        NSString *part = [address substringWithRange:NSMakeRange(i, end)];
        result = [result stringByAppendingString:part];
        if (end < len) {
            BOOL endOfLine = lineSize > 0 && (i + end) % lineSize == 0;
            if (endOfLine) {
                result = [result stringByAppendingString:@"\n"];
            } else {
                result = [result stringByAppendingString:@" "];
            }
        }
    }
    return result;
}

+ (NSString *)longToHex:(long long)value {
    NSNumber *number;
    NSString *hexString;
    number = [NSNumber numberWithLongLong:value];
    hexString = [NSString stringWithFormat:@"%qx", [number longLongValue]];
    return hexString;

}

+ (long long)hexToLong:(NSString *)hex {
    NSScanner *pScanner = [NSScanner scannerWithString:hex];
    unsigned long long iValue;
    [pScanner scanHexLongLong:&iValue];
    return iValue;
}

+ (NSData *)getUrlSaleBase64:(NSString *)str {
    str = [str stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    str = [str stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    return [NSData dataFromBase64String:str];
}

+ (NSString *)removeBlankSpaceString:(NSString *)str {
    return [str stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@end














