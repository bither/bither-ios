//
//  QRCodeEncodeUtil.m
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

#import "BTQRCodeEncodeUtil.h"

#define MAX_QRCODE_SIZE 328
#define QR_CODE_LETTER @"*"
#define QR_CODE_SPLIT @":"

@implementation BTQRCodeEncodeUtil

+(NSArray * )splitQRCode:(NSString * )content{
    return [content componentsSeparatedByString:QR_CODE_SPLIT];
}

+(NSString * )joinedQRCode:(NSArray * )array{
    return [array componentsJoinedByString:QR_CODE_SPLIT];
}

+(NSString *) encodeQrCodeString :(NSString* )text{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[A-Z]" options:0 error:&error];
    NSArray *matches = [regex matchesInString:text
                                      options:0
                                        range:NSMakeRange(0, [text length])];
    NSString * result=@"";
    NSInteger lastIndex=0;
    for (NSTextCheckingResult *match in matches) {
        NSRange range=[match rangeAtIndex:0];
        if (range.location>lastIndex&&lastIndex!=0) {
            result= [result stringByAppendingString:[text substringWithRange:NSMakeRange(lastIndex, range.location-lastIndex)]];
        }
        if (lastIndex==0) {
            if (range.location!=0) {
                result=[text substringToIndex:range.location];
            }
        }
        
        result=[result stringByAppendingFormat:@"*%@",[text substringWithRange:[match rangeAtIndex:0]]];
        lastIndex=range.location+range.length;
        
    }
    if (lastIndex<text.length) {
        result=[result stringByAppendingString:[text substringWithRange:NSMakeRange(lastIndex, text.length-lastIndex)]];
    }
    
    return [result uppercaseString];
}
+(NSString *)decodeQrCodeString:(NSString *)text{
    text=[text lowercaseString];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\*([a-z])" options:0 error:&error];
    NSArray *matches = [regex matchesInString:text
                                      options:0
                                        range:NSMakeRange(0, [text length])];
    NSString * result=@"";
    
    NSInteger lastIndex=0;
    
    for (NSTextCheckingResult *match in matches) {
        NSRange range = [match rangeAtIndex:0];
        if (range.location>lastIndex&&lastIndex!=0) {
            result= [result stringByAppendingString:[text substringWithRange:NSMakeRange(lastIndex, range.location-lastIndex)]];
        }
        if (lastIndex==0) {
            if (range.location!=0) {
                result=[text substringToIndex:range.location];
            }
        }
        result=[result stringByAppendingFormat:@"%@",[[text substringWithRange:[match rangeAtIndex:1]] uppercaseString]];
        
        lastIndex=range.location+range.length;
        
    }
    if (lastIndex<text.length) {
        result=[result stringByAppendingString:[text substringWithRange:NSMakeRange(lastIndex, text.length-lastIndex)]];
    }
    
    return result;
    
    
    
}
+(BOOL)verifyQrcodeTransport:(NSString *)text{
    NSError *error;
    NSString * regexStr = @"[^0-9A-Z\\*:]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:0 error:&error];
    NSArray *matches = [regex matchesInString:text
                                      options:0
                                        range:NSMakeRange(0, [text length])];
    return matches.count==0;
}

+(NSInteger)getNumOfQrCodeString:(NSInteger )length{
    if (length<MAX_QRCODE_SIZE) {
        return 1;
    }else if (length<=(MAX_QRCODE_SIZE-4)*10){
        return length/(MAX_QRCODE_SIZE-4)+1;
    }else if (length<=(MAX_QRCODE_SIZE-5)*100){
        return (length/(MAX_QRCODE_SIZE-5))+1;
    }else if (length <=(MAX_QRCODE_SIZE-6)*1000){
        return length/(MAX_QRCODE_SIZE-6)+1;
    }else{
        return 1000;
    }
}

@end
