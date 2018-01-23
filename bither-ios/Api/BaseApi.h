//  BaseApi.h
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
#import "BitherEngine.h"

#define kMKNetworkKitRequestTimeOutInSeconds 10

#define BITHER_GET_COOKIE_URL @"api/v1/cookie"
#define BITHER_GET_ONE_SPVBLOCK_API @"api/v2/block/spv/one"
#define BLOCKCHAIN_INFO_GET_LASTST_BLOCK @"latestblock"
#define BLOCKCHAIN_GET_ONE_SPVBLOCK_API @"block-height/%d?format=json"
#define BITHER_IN_SIGNATURES_API  @"api/v1/address/%@/insignature/%d"
#define SPLIT_BROADCAST @"https://bitpie.getcai.com/api/v1/%@/broadcast"

#define BCD_PREBLOCKHASH @"https://bitpie.getcai.com/api/v1/bcd/current/block/hash"

#define SPLIT_HAS_ADDRESS @"https://bitpie.getcai.com/api/v1/%@/has/address/%@"

#define BITHER_Q_MYTRANSACTIONS @"api/v1/address/%@/transaction"
#define BITHER_ERROR_API  @"api/v1/error"
#define BITHER_EXCHANGE_TICKER @"api/v1/exchange/ticker"
#define BITHER_KLINE_URL @"api/v1/exchange/%d/kline/%d"
#define BITHER_DEPTH_URL @"api/v1/exchange/%d/depth"
#define BITHER_TREND_URL @"api/v1/exchange/%d/trend"
#define BITHER_UPLOAD_AVATAR @"api/v1/avatar"
#define BITHER_DOWNLOAD_AVATAR @"api/v1/avatar"

#define BC_ADDRESS_TX_URL @"api/v2/address/%@/transaction/p/%d"
#define BC_ADDRESS_STAT_URL @"api/v2/address/%@/transaction/stat"
//limit=50 one Page can show 50 tx informations
#define BLOCK_INFO_ADDRESS_TX_URL @"rawaddr/%@/?offset=%d"
#define BLOCK_INFO_TX_INDEX_URL @"https://blockchain.info/rawtx/%@?format=hex"

@interface BaseApi : NSObject

#pragma mark-get

- (void)get:(NSString *)url withParams:(NSDictionary *)params networkType:(BitherNetworkType)networkType completed:(CompletedOperation)completedOperationParam andErrorCallback:(ErrorHandler)errorCallback;

- (void)get:(NSString *)url withParams:(NSDictionary *)params networkType:(BitherNetworkType)networkType completed:(CompletedOperation)completedOperationParam andErrorCallback:(ErrorHandler)errorCallback ssl:(BOOL)ssl;

- (void)execGetBlockChain:(NSString *)url withParams:(NSDictionary *)params networkType:(BitherNetworkType)networkType completed:(CompletedOperation)completedOperationParam andErrorCallback:(ErrorHandler)errorCallback ssl:(BOOL)ssl;

- (void)getBlockChainBh:(NSString *)url withParams:(NSDictionary *)params networkType:(BitherNetworkType)networkType completed:(CompletedOperation)completedOperationParam andErrorCallback:(ErrorHandler)errorCallback ssl:(BOOL)ssl;

- (void)getBlockChainTx:(NSString *)url withParams:(NSDictionary *)params networkType:(BitherNetworkType)networkType completed:(CompletedOperation)completedOperationParam andErrorCallback:(ErrorHandler)errorCallback ssl:(BOOL)ssl;

#pragma mark-post

- (void)post:(NSString *)url withParams:(NSDictionary *)params networkType:(BitherNetworkType)networkType completed:(CompletedOperation)completedOperationParam andErrorCallBack:(ErrorHandler)errorCallback;

- (void)post:(NSString *)url withParams:(NSDictionary *)params networkType:(BitherNetworkType)networkType completed:(CompletedOperation)completedOperationParam andErrorCallBack:(ErrorHandler)errorCallback ssl:(BOOL)ssl;


@end
