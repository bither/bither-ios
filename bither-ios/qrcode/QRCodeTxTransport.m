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
#import "BTUtils.h"
#import "StringUtil.h"

@implementation QRCodeTxTransport

+(QRCodeTxTransport *)formatQRCodeTransport:(NSString *)str{
    QRCodeTxTransport * qrCodeTx;
    NSArray * strArray=[BTQRCodeUtil splitQRCode:str];;
    if(strArray.count < 5){
        return nil;
    }
    long long changeAmt=[StringUtil hexToLong:strArray[1]];
    if (changeAmt>0) {
        qrCodeTx=[QRCodeTxTransport changeFormatQRCodeTransport:strArray];
        
    }else{
        qrCodeTx=[QRCodeTxTransport noChangeFormatQRCodeTransport:strArray];
    }
    
    return  qrCodeTx;
}
+(QRCodeTxTransport * )changeFormatQRCodeTransport:(NSArray *)strArray{
    QRCodeTxTransport * qrCodeTx=[[QRCodeTxTransport alloc] init];
    if(strArray.count < 5){
        return nil;
    }
    NSString * address=[[strArray objectAtIndex:0] hexToBase58check];
    if (![address isValidBitcoinAddress]) {
        return nil;
    }
    
    [qrCodeTx setMyAddress:address];
    [qrCodeTx setFee:[StringUtil hexToLong:[strArray objectAtIndex:1]]];
    [qrCodeTx setToAddress:[[strArray objectAtIndex:2] hexToBase58check]];
    [qrCodeTx setTo:[StringUtil hexToLong:[strArray objectAtIndex:3]]];
    NSMutableArray *array=[NSMutableArray new];
    for (int i=4; i<strArray.count; i++) {
        NSString * hash=[strArray objectAtIndex:i];
        if (![StringUtil isEmpty:hash]) {
            [array addObject:hash];
        }
    }
    [qrCodeTx setHashList:array];
    return qrCodeTx;
    

}
+(QRCodeTxTransport *)noChangeFormatQRCodeTransport:(NSArray *)strArray{
    
    QRCodeTxTransport * qrCodeTx=[[QRCodeTxTransport alloc] init];
    if(strArray.count < 5){
        return nil;
    }

    NSString * address=[[strArray objectAtIndex:0] hexToBase58check];
    if (![address isValidBitcoinAddress]) {
        return nil;
    }
    
    [qrCodeTx setMyAddress:address];
    [qrCodeTx setFee:[StringUtil hexToLong:[strArray objectAtIndex:1]]];
    [qrCodeTx setToAddress:[[strArray objectAtIndex:2] hexToBase58check]];
    [qrCodeTx setTo:[StringUtil hexToLong:[strArray objectAtIndex:3]]];
    NSMutableArray *array=[NSMutableArray new];
    for (int i=4; i<strArray.count; i++) {
        NSString * hash=[strArray objectAtIndex:i];
        if (![StringUtil isEmpty:hash]) {
            [array addObject:hash];
        }
    }
    [qrCodeTx setHashList:array];
    return qrCodeTx;
    
}


+(NSString *)getPreSignString:(QRCodeTxTransport *)qrCodeTx{
    NSMutableArray * array=[NSMutableArray new];
    [array addObject:[[qrCodeTx myAddress] base58checkToHex]];
    if (qrCodeTx.changeAmt!=0) {
        [array addObject:[qrCodeTx.changeAddress base58checkToHex]];
        [array addObject:[StringUtil longToHex:qrCodeTx.changeAmt]];
    }
    [array addObject:[StringUtil longToHex:[qrCodeTx fee]]];
    [array addObject:[[qrCodeTx toAddress] base58checkToHex]];
    [array addObject:[StringUtil longToHex:[qrCodeTx to]]];
    for(NSString * hash in qrCodeTx.hashList){
        [array addObject:hash];
    }
    NSString * preSignString=[BTQRCodeUtil joinedQRCode:array];
    return preSignString;
}

+(NSString *)oldGetPreSignString:(QRCodeTxTransport *)qrCodeTx{
    NSMutableArray * array=[[NSMutableArray alloc] initWithObjects:[qrCodeTx myAddress],[StringUtil longToHex:[qrCodeTx fee]],[qrCodeTx toAddress],[StringUtil longToHex:[qrCodeTx to]], nil];
    for(NSString * hash in qrCodeTx.hashList){
        [array addObject:hash];
    }
    NSString * preSignString=[BTQRCodeUtil oldJoinedQRCode:array];

    return preSignString;
}
@end















