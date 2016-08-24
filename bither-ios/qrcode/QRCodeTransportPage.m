//
//  QRCodeTransportPage.m
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

#import "QRCodeTransportPage.h"
#import "BTQRCodeUtil.h"
#import "StringUtil.h"

@implementation QRCodeTransportPage
+ (QRCodeTransportPage *)formatQrCodeString:(NSString *)text {
    if (![BTQRCodeUtil verifyQrcodeTransport:text]) {
        return nil;
    }
    QRCodeTransportPage *qrCodePage = [[QRCodeTransportPage alloc] init];
    NSArray *strArray = [BTQRCodeUtil splitQRCode:text];;
    if ([StringUtil isPureLongLong:[strArray objectAtIndex:0]] && [StringUtil isPureLongLong:[strArray objectAtIndex:1]]) {
        NSString *sumPageStr = strArray[0];
        NSString *currentPageStr = strArray[1];
        NSInteger length = sumPageStr.length + currentPageStr.length + 2;
        [qrCodePage setSumPage:[sumPageStr intValue] + 1];
        [qrCodePage setCurrentPage:[currentPageStr intValue]];
        [qrCodePage setContent:[text substringFromIndex:length]];

    } else {
        [qrCodePage setSumPage:1];
        [qrCodePage setContent:text];
    }
    return qrCodePage;

}

+ (NSString *)formatQRCodeTran:(NSArray *)qrCodeTransportPages {
    NSString *transportString = @"";
    for (QRCodeTransportPage *qrPage in qrCodeTransportPages) {
        if (![StringUtil isEmpty:[qrPage content]]) {
            transportString = [transportString stringByAppendingString:[qrPage content]];
        }
    }
    return [BTQRCodeUtil decodeQrCodeString:transportString];

}

+ (NSArray *)getQrCodeStringList:(NSString *)str {
    str = [BTQRCodeUtil encodeQrCodeString:str];
    NSMutableArray *array = [NSMutableArray new];
    NSInteger num = [BTQRCodeUtil getNumOfQrCodeString:str.length];
    NSInteger sumLength = str.length + num * 6;
    NSInteger pageSize = sumLength / num;
    for (NSInteger i = 0; i < num; i++) {
        NSInteger start = i * pageSize;
        NSInteger end = (i + 1) * pageSize;
        if (start > str.length - 1) {
            continue;
        }
        if (end > str.length) {
            end = str.length;
        }
        NSString *splitStr = [str substringWithRange:NSMakeRange(start, end - start)];
        NSString *pageString = @"";
        NSArray *a = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%ld", num - 1], [NSString stringWithFormat:@"%ld", (long)i], @"", nil];
        pageString = [BTQRCodeUtil joinedQRCode:a];
        [array addObject:[pageString stringByAppendingString:splitStr]];
    }
    return array;
}

+ (NSArray *)oldGetQrCodeStringList:(NSString *)str {
    str = [BTQRCodeUtil oldEncodeQrCodeString:str];
    NSMutableArray *array = [NSMutableArray new];
    NSInteger num = [BTQRCodeUtil getNumOfQrCodeString:str.length];
    NSInteger sumLength = str.length + num * 6;
    NSInteger pageSize = sumLength / num;
    for (NSInteger i = 0; i < num; i++) {
        NSInteger start = i * pageSize;
        NSInteger end = (i + 1) * pageSize;
        if (start > str.length - 1) {
            continue;
        }
        if (end > str.length) {
            end = str.length;
        }
        NSString *splitStr = [str substringWithRange:NSMakeRange(start, end - start)];
        NSString *pageString = @"";
        if (num > 1) {
            NSArray *array = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%ld", num - 1], [NSString stringWithFormat:@"%ld", (long)i], @"", nil];
            pageString = [BTQRCodeUtil oldJoinedQRCode:array];
        }
        [array addObject:[pageString stringByAppendingString:splitStr]];
    }
    return array;
}


- (BOOL)hasNextPage {
    return self.currentPage + 1 < self.sumPage;
}

@end

