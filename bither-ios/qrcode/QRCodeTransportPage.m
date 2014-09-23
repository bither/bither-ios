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
#import "QRCodeEncodeUtil.h"
#import "BitherSetting.h"
#import "StringUtil.h"
#import "QRCodeEncodeUtil.h"

@implementation QRCodeTransportPage
+(QRCodeTransportPage *)formatQrCodeString:(NSString *)text{
    if (![QRCodeEncodeUtil verifyQrcodeTransport:text]) {
        return nil;
    }
    QRCodeTransportPage * qrCodePage=[[QRCodeTransportPage alloc] init];
    NSArray * strArray=[text componentsSeparatedByString:QR_CODE_SPLIT];
    if ([StringUtil isPureLongLong:[strArray objectAtIndex:0]]) {
        NSString * sumPageStr=strArray[0];
        NSString * currentPageStr=strArray[1];
        NSInteger length=sumPageStr.length +currentPageStr.length+2;
        [qrCodePage setSumPage:[sumPageStr intValue]+1];
        [qrCodePage setCurrentPage:[currentPageStr intValue]];
        [qrCodePage setContent:[text substringFromIndex:length]];
        
    }else{
        [qrCodePage setSumPage:1];
        [qrCodePage setContent:text];
    }
    return qrCodePage;

}
+(NSString *)formatQRCodeTran:(NSArray *)qrCodeTransportPages{
    NSString * transportString=@"";
    for(QRCodeTransportPage*  qrPage in qrCodeTransportPages){
        if (![StringUtil isEmpty:[qrPage content]]) {
           transportString= [transportString stringByAppendingString:[qrPage content]];
        }
    }
    return [QRCodeEncodeUtil decodeQrCodeString:transportString];
    
}

+(NSArray *) getQrCodeStringList:(NSString *)str{
    str=[QRCodeEncodeUtil encodeQrCodeString:str];
    NSMutableArray *array=[NSMutableArray new];
    NSInteger num=[QRCodeEncodeUtil getNumOfQrCodeString:str.length];
    NSInteger sumLength=str.length+num*6;
    NSInteger pageSize=sumLength/num;
    for (NSInteger i=0; i<num; i++) {
        NSInteger start=i*pageSize;
        NSInteger end=(i+1)*pageSize;
        if (start>str.length-1) {
            continue;
        }
        if (end>str.length) {
            end=str.length;
        }
        NSString * splitStr=[str substringWithRange:NSMakeRange(start, end-start)];
        NSString *pageString=@"";
        if (num>1) {
            pageString=[NSString stringWithFormat:@"%ld:%ld:",(num-1),i];
        }
        [array addObject:[pageString stringByAppendingString:splitStr]];
    }
    return  array;
}


-(BOOL)hasNextPage{
    return self.currentPage+1<self.sumPage;
}

@end

