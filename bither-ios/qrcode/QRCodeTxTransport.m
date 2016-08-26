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
#import "StringUtil.h"
#import "NSString+Base58.h"
#import "BTQRCodeUtil.h"
#import "BTHDAccountAddress.h"

@implementation QRCodeTxTransport

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hdmIndex = NO_HDM_INDEX;
    }
    return self;
}

+ (QRCodeTxTransport *)formatQRCodeTransport:(NSString *)str {
    QRCodeTxTransport *qrCodeTx;
    TxTransportType txTransportType = -1;
    NSArray *strArray = [BTQRCodeUtil splitQRCode:str];
    int hdmIndex = NO_HDM_INDEX;
    NSString *str1 = strArray[0];
    if ([QRCodeTxTransport hasVersion:str1]) {
        NSString *versionStr = [str1 stringByReplacingOccurrencesOfString:TX_TRANSPORT_VERSION withString:@""];
        int version = versionStr.intValue;
        txTransportType = [QRCodeTxTransport getTxTransportType:version];
        str = [str substringFromIndex:str1.length + 1];
        strArray = [BTQRCodeUtil splitQRCode:str];
    }
    BOOL isHDM = ![QRCodeTxTransport isAddressHex:strArray[0]];
    if (isHDM) {
        hdmIndex = (int) [StringUtil hexToLong:strArray[0]];
        str = [str substringFromIndex:([strArray[0] length] + 1)];
        strArray = [BTQRCodeUtil splitQRCode:str];
    }
    if (strArray.count < 5) {
        return nil;
    }
    if ([QRCodeTxTransport isAddressHex:strArray[1]]) {
        qrCodeTx = [QRCodeTxTransport changeFormatQRCodeTransport:strArray];
    } else {

        if ([BTQRCodeUtil isOldQRCodeVerion:str]) {
            qrCodeTx = [QRCodeTxTransport oldFormatQRCodeTransport:str];
        } else {
            qrCodeTx = [QRCodeTxTransport noChangeFormatQRCodeTransport:strArray];
        }
    }
    qrCodeTx.hdmIndex = hdmIndex;
    qrCodeTx.txTransportType = txTransportType;
    if (txTransportType == TxTransportTypeColdHD) {
        NSArray *strs = qrCodeTx.hashList;
        NSMutableArray *hashes = [NSMutableArray new];
        NSMutableArray *paths = [NSMutableArray new];
        for (NSString *s in strs) {
            NSArray *hs = [s componentsSeparatedByString:QR_CODE_SECONDARY_SPLIT];
            PathTypeIndex *path = [PathTypeIndex new];
            path.pathType = ((NSString *) hs[0]).intValue;
            path.index = ((NSString *) hs[1]).intValue;
            [paths addObject:path];
            [hashes addObject:hs[2]];
        }
        qrCodeTx.hashList = hashes;
        qrCodeTx.pathTypeIndexes = paths;
    }
    return qrCodeTx;
}

+ (BOOL)hasVersion:(NSString *)str {
    NSString *regexStr = @"[V][\\d{1,3}]";
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:0 error:&error];
    NSArray *matches = [regex matchesInString:str
                                      options:0
                                        range:NSMakeRange(0, [str length])];
    return matches.count > 0;
}

+ (BOOL)isAddressHex:(NSString *)str {
    BOOL isAddress = NO;
    if (str.length % 2 == 0) {
        NSString *changeAddress = [str hexToBase58check];
        isAddress = [changeAddress isValidBitcoinAddress];
    }
    return isAddress;
}

+ (QRCodeTxTransport *)changeFormatQRCodeTransport:(NSArray *)strArray {
    QRCodeTxTransport *qrCodeTx = [[QRCodeTxTransport alloc] init];
    if (strArray.count < 5) {
        return nil;
    }
    NSString *address = [[strArray objectAtIndex:0] hexToBase58check];
    if (![address isValidBitcoinAddress]) {
        return nil;
    }
    NSString *changeAddress = [[strArray objectAtIndex:1] hexToBase58check];
    if (![changeAddress isValidBitcoinAddress]) {
        return nil;
    }

    [qrCodeTx setMyAddress:address];
    [qrCodeTx setChangeAddress:changeAddress];
    [qrCodeTx setChangeAmt:[StringUtil hexToLong:[strArray objectAtIndex:2]]];
    [qrCodeTx setFee:[StringUtil hexToLong:[strArray objectAtIndex:3]]];
    [qrCodeTx setToAddress:[[strArray objectAtIndex:4] hexToBase58check]];
    [qrCodeTx setTo:[StringUtil hexToLong:[strArray objectAtIndex:5]]];
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 6; i < strArray.count; i++) {
        NSString *hash = [strArray objectAtIndex:i];
        if (![StringUtil isEmpty:hash]) {
            [array addObject:hash];
        }
    }
    [qrCodeTx setHashList:array];
    return qrCodeTx;


}

+ (QRCodeTxTransport *)noChangeFormatQRCodeTransport:(NSArray *)strArray {

    QRCodeTxTransport *qrCodeTx = [[QRCodeTxTransport alloc] init];
    if (strArray.count < 5) {
        return nil;
    }

    NSString *address = [[strArray objectAtIndex:0] hexToBase58check];
    if (![address isValidBitcoinAddress]) {
        return nil;
    }

    [qrCodeTx setMyAddress:address];
    [qrCodeTx setFee:[StringUtil hexToLong:[strArray objectAtIndex:1]]];
    [qrCodeTx setToAddress:[[strArray objectAtIndex:2] hexToBase58check]];
    [qrCodeTx setTo:[StringUtil hexToLong:[strArray objectAtIndex:3]]];
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 4; i < strArray.count; i++) {
        NSString *hash = [strArray objectAtIndex:i];
        if (![StringUtil isEmpty:hash]) {
            [array addObject:hash];
        }
    }
    [qrCodeTx setHashList:array];
    return qrCodeTx;

}


+ (NSString *)getPreSignString:(QRCodeTxTransport *)qrCodeTx {
    NSMutableArray *array = [NSMutableArray new];
    if (qrCodeTx.txTransportType > 0 && qrCodeTx.txTransportType < 6) {
        NSString *versionStr = [NSString stringWithFormat:@"%@%d", TX_TRANSPORT_VERSION, qrCodeTx.txTransportType];
        [array addObject:versionStr];
    }
    if (qrCodeTx.hdmIndex != NO_HDM_INDEX) {
        [array addObject:[StringUtil longToHex:qrCodeTx.hdmIndex]];
    }
    [array addObject:[[qrCodeTx myAddress] base58checkToHex]];
    if (qrCodeTx.changeAmt != 0) {
        [array addObject:[qrCodeTx.changeAddress base58checkToHex]];
        [array addObject:[StringUtil longToHex:qrCodeTx.changeAmt]];
    }
    [array addObject:[StringUtil longToHex:[qrCodeTx fee]]];
    [array addObject:[[qrCodeTx toAddress] base58checkToHex]];
    [array addObject:[StringUtil longToHex:[qrCodeTx to]]];
    if (qrCodeTx.txTransportType == TxTransportTypeColdHD) {
        assert(qrCodeTx.hashList.count == qrCodeTx.pathTypeIndexes.count);
        for (NSUInteger i = 0; i < qrCodeTx.hashList.count; i++) {
            PathTypeIndex *path = qrCodeTx.pathTypeIndexes[i];
            NSString *hash = qrCodeTx.hashList[i];
            [array addObject:[NSString stringWithFormat:@"%d%@%lu%@%@", path.pathType, QR_CODE_SECONDARY_SPLIT, (unsigned long)path.index, QR_CODE_SECONDARY_SPLIT, hash]];
        }
    } else {
        for (NSString *hash in qrCodeTx.hashList) {
            [array addObject:hash];
        }
    }
    NSString *preSignString = [BTQRCodeUtil joinedQRCode:array];
    return preSignString;
}

+ (NSString *)oldGetPreSignString:(QRCodeTxTransport *)qrCodeTx {
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:[qrCodeTx myAddress], [StringUtil longToHex:[qrCodeTx fee]], [qrCodeTx toAddress], [StringUtil longToHex:[qrCodeTx to]], nil];
    for (NSString *hash in qrCodeTx.hashList) {
        [array addObject:hash];
    }
    NSString *preSignString = [BTQRCodeUtil oldJoinedQRCode:array];

    return preSignString;
}

+ (QRCodeTxTransport *)oldFormatQRCodeTransport:(NSString *)str {
    QRCodeTxTransport *qrCodeTx = [[QRCodeTxTransport alloc] init];
    NSArray *strArray = [BTQRCodeUtil splitQRCode:str];;
    if (strArray.count < 5) {
        return nil;
    }
    NSString *address = [strArray objectAtIndex:0];
    if (![address isValidBitcoinAddress]) {
        return nil;
    }
    [qrCodeTx setMyAddress:address];
    [qrCodeTx setFee:[StringUtil hexToLong:[strArray objectAtIndex:1]]];
    [qrCodeTx setToAddress:[strArray objectAtIndex:2]];
    [qrCodeTx setTo:[StringUtil hexToLong:[strArray objectAtIndex:3]]];
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 4; i < strArray.count; i++) {
        NSString *hash = [strArray objectAtIndex:i];
        if (![StringUtil isEmpty:hash]) {
            [array addObject:hash];
        }
    }
    [qrCodeTx setHashList:array];
    return qrCodeTx;
}

+ (TxTransportType)getTxTransportType:(int)type {
    if (type > 0 && type < 6) {
        return type;
    }
    return TxTransportTypeNormalPrivateKey;
}
@end
