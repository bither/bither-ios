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
#import "UserDefaultsUtil.h"
#import "UIImage+ImageRenderToColor.h"
#import "NSData+MKBase64.h"



#define BTC         @"\xC9\x83"     // capital B with stroke (utf-8)
#define BITS        @"\xC6\x80"     // lowercase b with stroke (utf-8)
#define NARROW_NBSP @"\xE2\x80\xAF" // narrow no-break space (utf-8)
#define BIP21ADDRESS_REGEX  @"^bitcoin:([123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]{20,40})(\\?(.+))?$"
#define BIP21AMT_REGEX  @"^(.*)amount=([1-9]\\d*\\.\\d*|0\\.\\d*[1-9]\\d*)(.*)$"


@implementation StringUtil

+(NSString *)formatPrice:(double) value{
    NSString * symobl=[BitherSetting getExchangeSymbol:[[UserDefaultsUtil instance] getDefaultExchangeType]];
    return  [NSString stringWithFormat:@"%@%.2f",symobl, value];
}
+(NSString * )formatDouble:(double) value{
    return [NSString stringWithFormat:@"%.2f",value];
}
+ (int64_t)amountForString:(NSString *)string
{
    NSNumberFormatter* format =[self getBitcoinFromat];
    return ([[format numberFromString:string] doubleValue] + DBL_EPSILON)*
    pow(10.0, format.maximumFractionDigits);
}

+ (NSString *)stringForAmount:(int64_t)amount
{
    
    NSNumberFormatter* format =[self getBitcoinFromat];
    NSUInteger min = format.minimumFractionDigits;
    
    if (amount == 0) {
        format.minimumFractionDigits =
        format.maximumFractionDigits > 2 ? 2 : format.maximumFractionDigits;
    }
    
    NSString *r = [format stringFromNumber:@(amount/pow(10.0, format.maximumFractionDigits))];
    
    format.minimumFractionDigits = min;
    
    return r;
}

+(NSMutableAttributedString*)attributedStringForAmount:(int64_t)amout withFontSize:(CGFloat)size{
    NSString* str = [StringUtil stringForAmount:amout];
    NSUInteger pointLocation = [str rangeOfString:@"."].location;
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:size]}];
    if(pointLocation + 3 < str.length){
        [result addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:size * 0.85f] range:NSMakeRange(pointLocation + 3, str.length - pointLocation - 3)];
    }
    return result;
}

+(NSMutableAttributedString*)attributedStringWithSymbolForAmount:(int64_t)amount withFontSize:(CGFloat)size color:(UIColor*)color{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithAttributedString:[StringUtil attributedStringForAmount:amount withFontSize:size]];
    return [StringUtil addSymbol:attr withFontSize:size color:color];
}

+(NSMutableAttributedString*)stringWithSymbolForAmount:(int64_t)amount withFontSize:(CGFloat)size color:(UIColor*)color{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:[StringUtil stringForAmount:amount]];
    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:size] range:NSMakeRange(0, attr.length)];
    return [StringUtil addSymbol:attr withFontSize:size color:color];
}

+(void)stringWithSymbolForAmount:(int64_t)amount source:(NSMutableAttributedString*)str{
    [str replaceCharactersInRange:NSMakeRange(2, str.length - 2) withString:[StringUtil stringForAmount:amount]];
}

+(NSMutableAttributedString*)addSymbol:(NSMutableAttributedString*)attr withFontSize:(CGFloat)size color:(UIColor*)color{
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    UIImage* symbol = [[UIImage imageNamed:@"symbol_btc_slim"] renderToColor:color];
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

+(NSNumberFormatter *)getBitcoinFromat{
    NSNumberFormatter* format = [NSNumberFormatter new];
    format.lenient = YES;
    format.numberStyle = NSNumberFormatterCurrencyStyle;
    format.minimumFractionDigits = 0;
    format.negativeFormat = [format.positiveFormat
                             stringByReplacingCharactersInRange:[format.positiveFormat rangeOfString:@"#"]
                             withString:@"-#"];
    format.currencySymbol = @"";
    format.maximumFractionDigits = 8;
    format.maximum = @21000000.0;
    return format;
}



+(BOOL)isEmpty:(NSString *)str{
    return str==nil||str.length==0;
}
+(BOOL)validEmail:(NSString *)str{
    NSString * regex = @"(^[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})$)";
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return  [pred evaluateWithObject:str];
}
+(BOOL)validPassword:(NSString *)str{
    NSString * regex = @"[0-9,a-z,A-Z]{6,30}";
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return  [pred evaluateWithObject:str];
}
+(BOOL)validPartialPassword:(NSString *)str{
    NSString * regex = @"[0-9,a-z,A-Z]{0,30}";
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return  [pred evaluateWithObject:str];
}
//BIP21 https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki

+(BOOL)isValidBitcoinBIP21Address:(NSString *)str{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:BIP21ADDRESS_REGEX options:0 error:&error];
    NSArray * matchs= [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    return  matchs.count>0;
    
    
}
+(NSString*)getAddressFormBIP21Address:(NSString *)str{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:BIP21ADDRESS_REGEX options:0 error:&error];
    NSArray * matchs= [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    if (matchs.count>0) {
        NSTextCheckingResult *match =[matchs objectAtIndex:0];
        NSRange  range=[match rangeAtIndex:1];
        return  [str substringWithRange:range];
    }else{
        return @"";
    }
}
+(uint64_t)getAmtFormBIP21Address:(NSString *)str{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:BIP21AMT_REGEX options:0 error:&error];
    NSArray * matchs= [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    if (matchs.count>0) {
        NSTextCheckingResult *match =[matchs objectAtIndex:0];
        NSRange  range=[match rangeAtIndex:2];
        return  [StringUtil amountForString:[str substringWithRange:range]];
    }else{
        return -1;
    }
}


+(BOOL)isPureLongLong:(NSString *)string{
    NSScanner * scan=[NSScanner scannerWithString:string];
    long long val;
    return [scan scanLongLong:&val]&&[scan isAtEnd];
}
+(BOOL)isPureFloat:(NSString *)string{
    NSScanner * scan=[NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] &&[scan isAtEnd];
}


+(NSString *)intToString:(int)num{
    return [ NSString stringWithFormat:@"%d",num];
}
+(NSString *)longToString:(long)num{
    return  [NSString stringWithFormat:@"%ld",num];
}
+(BOOL)compareString:(NSString *)original compare:(NSString *)compare{
    if (original==nil) {
        if (compare==nil) {
            return YES;
        }else{
            return NO;
        }
    }else{
        if(compare==nil){
            return NO;
        }else{
            return [original isEqualToString:compare];
        }
    }
}

+(NSString *)shortenAddress:(NSString *)address{
    if (!address||address.length<=4) {
        return address;
    }else{
        return [[address substringToIndex:4] stringByAppendingString:@"..."];
    }
}
+(NSString *)formatAddress:(NSString *)address groupSize:(NSInteger)groupSize  lineSize:(NSInteger) lineSize{
    NSInteger len=address.length;
    NSString * result=@"";
    
    for (NSInteger i=0; i<len; i+=groupSize) {
        NSInteger end=groupSize;
        if (i+groupSize>len) {
            end=len-i;
        }
        NSString * part=[address substringWithRange:NSMakeRange(i,end)];
        result=[result stringByAppendingString:part];
        if (end<len) {
            BOOL endOfLine=lineSize>0&&(i+end)%lineSize==0;
            if (endOfLine) {
               result= [result stringByAppendingString:@"\n"];
            }else{
               result= [result stringByAppendingString:@" "];
            }
        }
    }
    return result;
}

+(NSString *)longToHex:(long long) value{
    NSNumber *number;
    NSString *hexString;
    number = [NSNumber numberWithLongLong:value];
    hexString = [NSString stringWithFormat:@"%qx", [number longLongValue]];
    return hexString;
    
}
+(long long)hexToLong:(NSString *)hex{
    NSScanner* pScanner = [NSScanner scannerWithString: hex];
    unsigned long long iValue;
    [pScanner scanHexLongLong: &iValue];
    return iValue;
}
+(NSData *)getUrlSaleBase64:(NSString *)str{
    str=[str stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    str=[str stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    return [NSData dataFromBase64String:str];
}

@end














