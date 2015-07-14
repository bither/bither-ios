//
//  QRCodeTxTransport.h
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

#define NO_HDM_INDEX  -1
#define TX_TRANSPORT_VERSION (@"V")

typedef enum {
    TxTransportTypeNormalPrivateKey = 1,
    TxTransportTypeServiceHDM = 2,
    TxTransportTypeColdHDM = 3,
    TxTransportTypeDesktopHDM = 4,
    TxTransportTypeColdHD = 5
} TxTransportType;

@interface QRCodeTxTransport : NSObject
@property(nonatomic, strong) NSArray *hashList;
@property(nonatomic, strong) NSString *myAddress;
@property(nonatomic, strong) NSString *toAddress;
@property(nonatomic, strong) NSString *changeAddress;
@property(nonatomic, readwrite) long long to;
@property(nonatomic, readwrite) long long fee;
@property(nonatomic, readwrite) long long changeAmt;
@property(nonatomic, readwrite) int hdmIndex;
@property(nonatomic, readwrite) TxTransportType txTransportType;
@property(nonatomic, readwrite) NSArray *pathTypeIndexes;


+ (NSString *)getPreSignString:(QRCodeTxTransport *)qrCodeTransport;

+ (NSString *)oldGetPreSignString:(QRCodeTxTransport *)qrCodeTx;

+ (QRCodeTxTransport *)formatQRCodeTransport:(NSString *)str;


@end
