//  BitherApi.m
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

#import "BitherApi.h"
#import "MarketUtil.h"
#import "GroupFileUtil.h"

static BitherApi *piApi;

@implementation BitherApi

+ (BitherApi *)instance {
    @synchronized (self) {
        if (piApi == nil) {
            piApi = [[self alloc] init];
        }
    }
    return piApi;
}

- (void)getSpvBlock:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    [self          get:BITHER_GET_ONE_SPVBLOCK_API withParams:nil networkType:BitherBC completed:^(MKNetworkOperation *completedOperation) {
        if (![StringUtil isEmpty:completedOperation.responseString]) {
            NSLog(@"spv: %s", [completedOperation.responseString UTF8String]);
            NSDictionary *dict = [completedOperation responseJSON];
            if (callback) {
                callback(dict);
            }
        }
    } andErrorCallback:^(NSOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp, error);
        }

    }];

}

- (void)getInSignaturesApi:(NSString *)address fromBlock:(int)blockNo callback:(IdResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    NSString *url = [NSString stringWithFormat:BITHER_IN_SIGNATURES_API, address, blockNo];
    [self          get:url withParams:nil networkType:BitherBitcoin completed:^(MKNetworkOperation *completedOperation) {
        if (callback) {
            callback(completedOperation.responseString);
        }

    } andErrorCallback:^(NSOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp, error);
        }
    }];

}

- (void)getExchangeTrend:(MarketType)marketType callback:(ArrayResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    NSString *url = [NSString stringWithFormat:BITHER_TREND_URL, [GroupUtil getMarketValue:marketType]];
    [self          get:url withParams:nil networkType:BitherStats completed:^(MKNetworkOperation *completedOperation) {
        if (callback) {
            callback(completedOperation.responseJSON);
        }

    } andErrorCallback:^(NSOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp, error);
        }
    }];
}

- (void)getExchangeDepth:(MarketType)marketType callback:(ArrayResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    //[];
}
#pragma mark - getTransactionApiFromBlockChain
- (void)getTransactionApiFromBlockChain:(NSString *)address withPage:(int)page callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback{
    NSString *singeTxUrl = [NSString stringWithFormat:BLOCK_INFO_ADDRESS_TX_URL,address,page];
    //NSLog(@"%@",singeTxUrl);
    [self getBlockChainTx:singeTxUrl withParams:nil networkType:BlockChain completed:^(MKNetworkOperation *completedOperation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            DDLogDebug(@"api response:%@", completedOperation.responseString);
            if (![StringUtil isEmpty:completedOperation.responseString]) {
                NSDictionary *dict = completedOperation.responseJSON;
                if (callback) {
                    callback(dict);
                }
            }
        });
        
    } andErrorCallback:^(NSOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp, error);
        }
        
    } ssl:NO];
    
}
#pragma mark - getblockHeightApiFromBlockChain
- (void)getblockHeightApiFromBlockChain:(NSString *)address  callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback{
    //NSLog(@"ever Address :%@",address);
    NSString *blockHeightUrl = @"latestblock";
    [self getBlockChainBh:blockHeightUrl withParams:@{@"address": address} networkType:BlockChain completed:^(MKNetworkOperation *completedOperation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            DDLogDebug(@"api response:%@", completedOperation.responseString);
            if (![StringUtil isEmpty:completedOperation.responseString]) {
                NSDictionary *dict = completedOperation.responseJSON;
                if (callback) {
                    callback(dict);
                }
            }
        });
        
    } andErrorCallback:^(NSOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp, error);
        }
        
        
    } ssl:NO];
    
}
#pragma mark - getTransactionApiFrom bither.net
- (void)getTransactionApi:(NSString *)address withPage:(int)page callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback; {
    DDLogDebug(@"get %@ tx page %d from api", address, page);
    NSString *url = [NSString stringWithFormat:BC_ADDRESS_TX_URL, address, page];
    [self          get:url withParams:nil networkType:BitherBC completed:^(MKNetworkOperation *completedOperation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            DDLogDebug(@"api response:%@", completedOperation.responseString);
            if (![StringUtil isEmpty:completedOperation.responseString]) {
                NSDictionary *dict = completedOperation.responseJSON;
                if (callback) {
                    callback(dict);
                }
            }
        });
    } andErrorCallback:^(NSOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp, error);
        }
    }];
}

- (void)getMyTransactionApi:(NSString *)address callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    NSString *url = [NSString stringWithFormat:BC_ADDRESS_STAT_URL, address];
    [self          get:url withParams:nil networkType:BitherBC completed:^(MKNetworkOperation *completedOperation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            DDLogDebug(@"api response:%@", completedOperation.responseString);
            if (![StringUtil isEmpty:completedOperation.responseString]) {
                NSDictionary *dict = completedOperation.responseJSON;
                if (callback) {
                    callback(dict);
                }
            }
        });

    } andErrorCallback:^(NSOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp, error);
        }
    }];
}

- (void)getExchangeTicker:(VoidBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    [self          get:BITHER_EXCHANGE_TICKER withParams:nil networkType:BitherStats completed:^(MKNetworkOperation *completedOperation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (![StringUtil isEmpty:completedOperation.responseString]) {
                [GroupFileUtil setTicker:completedOperation.responseString];
                NSDictionary *dict = completedOperation.responseJSON;
                [MarketUtil handlerResult:dict];

                if (callback) {
                    callback();
                }
            }

        });
    } andErrorCallback:^(NSOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp, error);
        }

    }];

}

- (void)uploadCrash:(NSString *)data callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"error_msg"] = data;
    [self         post:BITHER_ERROR_API withParams:dict networkType:BitherUser completed:^(MKNetworkOperation *completedOperation) {
        if (callback) {
            callback(nil);
        }
    } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp, error);
        }
    }];
}

//#pragma mark - hdm api
//- (void)getHDMPasswordRandomWithHDMBid:(NSString *) hdmBid callback:(IdResponseBlock) callback andErrorCallBack:(ErrorHandler)errorCallback;{
//    [self get:[NSString stringWithFormat:@"api/v1/%@/hdm/password", hdmBid] withParams:nil networkType:BitherHDM completed:^(MKNetworkOperation *completedOperation) {
//        NSNumber *random = @([completedOperation.responseString longLongValue]);
//        NSLog(@"hdm password random:%@", random);
//        if (callback != nil) {
//            callback(random);
//        }
//    } andErrorCallback:^(NSOperation *errorOp, NSError *error) {
//        if (errorCallback) {
//            errorCallback(errorOp, error);
//        }
//    } ssl:YES];
//}
//
////- (void)changeHDMPasswordWithHDMBid:(NSString *)hdmBid andPassword:(NSString *)password
////                       andSignature:(NSString *)signature andHotAddress:(NSString *)hotAddress
////                           callback:(VoidResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback; {
////    NSDictionary *params = @{@"password" : [[password hexToData] base64EncodedString], @"signature" : signature,
////            @"hot_address" : hotAddress};
////    [self post:[NSString stringWithFormat:@"api/v1/%@/hdm/password",hdmBid] withParams:params networkType:BitherHDM completed:^(MKNetworkOperation *completedOperation) {
////        NSDictionary *dict = completedOperation.responseJSON;
////        if ([dict[@"result"] isEqualToString:@"ok"] && callback != nil) {
////            callback();
////        }
////    } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
////        if (errorCallback) {
////            errorCallback(errorOp, error);
////        }
////    } ssl:YES];
////};
////
////- (void)createHDMAddressWithHDMBid:(NSString *)hdmBid andPassword:(NSString *)password start:(int)start end:(int)end
////                           pubHots:(NSArray *) pubHots pubColds:(NSArray *)pubColds
////                          callback:(ArrayResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback; {
////    NSDictionary *params = @{@"password" : [[password hexToData] base64EncodedString], @"start" : @(start), @"end": @(end),
////            @"pub_hot": [self connect:pubHots], @"pub_cold": [self connect:pubColds]};
////    [self post:[NSString stringWithFormat:@"api/v1/%@/hdm/address/create", hdmBid] withParams:params networkType:BitherHDM completed:^(MKNetworkOperation *completedOperation) {
////        NSArray *pubRemotes = [self split:completedOperation.responseString];
////        if (callback != nil) {
////            callback(pubRemotes);
////        }
////    } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
////        if (errorCallback) {
////            errorCallback(errorOp, error);
////        }
////    } ssl:YES];
////}
////
////- (void)signatureByRemoteWithHDMBid:(NSString *)hdmBid andPassword:(NSString *)password andUnsignHash:(NSData *)unsignHash
////                           callback:(IdResponseBlock) callback andErrorCallBack:(ErrorHandler)errorCallback;{
////    NSDictionary *params = @{@"password" : [[password hexToData] base64EncodedString], @"unsign": [unsignHash base64EncodedString]};
////    [self post:[NSString stringWithFormat:@""] withParams:params networkType:BitherHDM completed:^(MKNetworkOperation *completedOperation) {
////        if (callback != nil) {
////            callback(completedOperation.responseString);
////        }
////    } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
////        if (errorCallback) {
////            errorCallback(errorOp, error);
////        }
////    } ssl:YES];
////}
////
////- (void)recoverHDMAddressWithHDMBid:(NSString *)hdmBid andPassword:(NSString *)password andSignature:(NSString *)signature
////                           callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback; {
////    NSDictionary *params = @{@"password" : [[password hexToData] base64EncodedString], @"signature" : signature};
////    [self post:[NSString stringWithFormat:@""] withParams:params networkType:BitherHDM completed:^(MKNetworkOperation *completedOperation) {
////        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:completedOperation.responseJSON];
////        dict[@"pub_hot"] = [self split:dict[@"pub_hot"]];
////        dict[@"pub_cold"] = [self split:dict[@"pub_cold"]];
////        dict[@"pub_server"] = [self split:dict[@"pub_server"]];
////        if (callback != nil) {
////            callback(dict);
////        }
////    } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
////        if (errorCallback) {
////            errorCallback(errorOp, error);
////        }
////    } ssl:YES];
////}

//- (NSString *)connect:(NSArray *)dataList;{
//    NSMutableData *result = [NSMutableData secureData];
//    for (NSData *each in dataList) {
//        [result appendUInt8:(uint8_t) each.length];
//        [result appendData:each];
//    }
//    return [result base64EncodedString];
//}
//
//- (NSArray *)split:(NSString *)str; {
//    NSData *data = [NSData dataFromBase64String:str];
//    NSMutableArray *result = [NSMutableArray new];
//    NSUInteger index = 0;
//    while (str.length > index) {
//        uint8_t l = [data UInt8AtOffset:index];
//        NSData *each = [data dataAtOffset:index + 1 length:&l];
//        index += l + 1;
//        [result addObject:each];
//    }
//    return result;
//}
//
//- (NSError *)formatHDMErrorWithOP:(MKNetworkOperation *)errorOp andError:(NSError *)error;{
//    return nil;
//}
@end
