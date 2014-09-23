//
//  QRCodeTxTransport.m
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

#import "QRCodeTxTransport.h"
#import "BitherSetting.h"
#import "StringUtil.h"
#import "NSString+Base58.h"
#import "BTQRCodeUtil.h"

@implementation QRCodeTxTransport
+(QRCodeTxTransport*)formatQRCodeTransport:(NSString *)str{
    QRCodeTxTransport * qrCodeTx=[[QRCodeTxTransport alloc] init];
    NSArray * strArray=[BTQRCodeUtil splitQRCode:str];;
    if(strArray.count < 5){
        return nil;
    }
    NSString * address=[strArray objectAtIndex:0];
    if (![address isValidBitcoinAddress]) {
        return nil;
    }
    [qrCodeTx setMyAddress:address];
    [qrCodeTx setFee:[StringUtil hexToLong:[strArray objectAtIndex:1]]];
    [qrCodeTx setToAddress:[strArray objectAtIndex:2]];
    [qrCodeTx setTo:[StringUtil hexToLong:[strArray objectAtIndex:3]]];
    NSMutableArray *array=[NSMutableArray new];
    for (int i=4; i<strArray.count; i++) {
        NSString * hash=[strArray objectAtIndex:i];
        if (![StringUtil isEmpty:hash]) {
            [array addObject:hash];
        }
    }
    [qrCodeTx setHashList:array];
    return  qrCodeTx;
}
+(NSString *)getPreSignString:(QRCodeTxTransport *)qrCodeTx{
    NSString * preSignString=@"%@:%@:%@:%@:";
    preSignString=[NSString stringWithFormat:preSignString,[qrCodeTx myAddress],[StringUtil longToHex:[qrCodeTx fee]],[qrCodeTx toAddress],[StringUtil longToHex:[qrCodeTx to]]];
    NSArray * hashList=[qrCodeTx hashList];
    preSignString=[preSignString stringByAppendingString:[BTQRCodeUtil joinedQRCode:hashList]];
    return preSignString;
}
@end















