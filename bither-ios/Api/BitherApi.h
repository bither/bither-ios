//  BitherApi.h
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
#import "BaseApi.h"
#import "StringUtil.h"
#import "UserDefaultsUtil.h"
#import "BTTx.h"
#import "SplitCoinUtil.h"

///@description   API
@interface BitherApi : BaseApi {
    int version;
}

+ (BitherApi *)instance;

- (void)getSpvBlock:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

- (void)getSpvBlockByBlockChain:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

- (void)getInSignaturesApi:(NSString *)address fromBlock:(int)blockNo callback:(IdResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;
//blockchain-api
- (void)getTransactionApiFromBlockChain:(NSString *)address withPage:(int)page callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

- (void)getblockHeightApiFromBlockChain:(NSString *)address  callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

// Don't know why I didn't use
/*
- (void)getTransactionApiFromBtcCom:(NSString *)address withPage:(int)page callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

- (void)getblockHeightApiFromBtcCom:(NSString *)address  callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;
 */

- (void)getTransactionApi:(NSString *)address withPage:(int)page callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

- (void)getMyTransactionApi:(NSString *)address callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

- (void)getExchangeTicker:(VoidBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

- (void)uploadCrash:(NSString *)data callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

- (void)getExchangeTrend:(MarketType)marketType callback:(ArrayResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

- (void)getAdApi;

- (void)getHasSplitCoinAddress:(NSString *)address splitCoin:(SplitCoin)splitCoin callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

- (void)getBcdPreBlockHashCallback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

- (void)postSplitCoinBroadcast:(BTTx *)tx splitCoin:(SplitCoin)splitCoin callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;



//#pragma mark - hdm api
//- (void)getHDMPasswordRandomWithHDMBid:(NSString *) hdmBid callback:(IdResponseBlock) callback andErrorCallBack:(ErrorHandler)errorCallback;
//- (void)changeHDMPasswordWithHDMBid:(NSString *)hdmBid andPassword:(NSString *)password
//                       andSignature:(NSString *)signature andHotAddress:(NSString *)hotAddress
//                           callback:(VoidResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;
//- (void)createHDMAddressWithHDMBid:(NSString *)hdmBid andPassword:(NSString *)password start:(int)start end:(int)end
//                           pubHots:(NSArray *) pubHots pubColds:(NSArray *)pubColds
//                          callback:(ArrayResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;
//- (void)signatureByRemoteWithHDMBid:(NSString *)hdmBid andPassword:(NSString *)password andUnsignHash:(NSData *)unsignHash
//                           callback:(IdResponseBlock) callback andErrorCallBack:(ErrorHandler)errorCallback;
//- (void)recoverHDMAddressWithHDMBid:(NSString *)hdmBid andPassword:(NSString *)password andSignature:(NSString *)signature
//                           callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;
//
//- (NSError *)formatHDMErrorWithOP:(MKNetworkOperation *)errorOp andError:(NSError *)error;
@end
