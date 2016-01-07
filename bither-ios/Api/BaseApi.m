//  BaseApi.m
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

#import "BaseApi.h"


ErrorHandler errorHandler = ^(NSOperation *errorOp, NSError *error) {
    DLog(@"%@", [error localizedDescription]);
};

@interface BaseApi ()
@end

@implementation BaseApi

- (instancetype)init {
    self = [super init];
    return self;
}

#pragma mark-get

- (void)initEngine:(CompletedOperation)completedOperationParam andErrorCallback:(ErrorHandler)errorCallback {
    if ([[BitherEngine instance] getCookies].count == 0) {
        [self    getCookie:^(MKNetworkOperation *completedOperation) {
            if (completedOperationParam) {
                completedOperationParam(completedOperation);
            }
        } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
            if (errorCallback) {
                errorCallback(errorOp, error);
            }
        }];
    } else {
        if (completedOperationParam) {
            completedOperationParam(nil);
        }
    }

}
- (void)getBlockChainTx:(NSString *)url withParams:(NSDictionary *)params networkType:(BitherNetworkType)networkType
              completed:(CompletedOperation)completedOperationParam andErrorCallback:(ErrorHandler)errorCallback ssl:(BOOL)ssl{
    if (errorCallback == nil) {
        errorCallback = errorHandler;
    }
    [self execGetBlockChain:url withParams:params networkType:networkType completed:completedOperationParam andErrorCallback:errorCallback ssl:ssl];
    
}
- (void)getBlockChainBh:(NSString *)url withParams:(NSDictionary *)params networkType:(BitherNetworkType)networkType
              completed:(CompletedOperation)completedOperationParam andErrorCallback:(ErrorHandler)errorCallback ssl:(BOOL)ssl{
    if (errorCallback == nil) {
        errorCallback = errorHandler;
    }
    [self execGetBlockChain:url withParams:params networkType:networkType completed:completedOperationParam andErrorCallback:errorCallback ssl:ssl];
}

- (void)get:(NSString *)url withParams:(NSDictionary *)params networkType:(BitherNetworkType)networkType
  completed:(CompletedOperation)completedOperationParam andErrorCallback:(ErrorHandler)errorCallback; {
    [self get:url withParams:params networkType:networkType completed:completedOperationParam andErrorCallback:errorCallback ssl:NO];
}

- (void)get:(NSString *)url withParams:(NSDictionary *)params networkType:(BitherNetworkType)networkType
  completed:(CompletedOperation)completedOperationParam andErrorCallback:(ErrorHandler)errorCallback ssl:(BOOL)ssl {
    if (errorCallback == nil) {
        errorCallback = errorHandler;
    }
    [self   initEngine:^(MKNetworkOperation *completedOperation) {
        [self execGet:url withParams:params networkType:networkType completed:completedOperationParam andErrorCallback:errorCallback ssl:ssl];
    } andErrorCallback:^(NSOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp, error);
        }
    }];
}

- (void)execGet:(NSString *)url withParams:(NSDictionary *)params networkType:(BitherNetworkType)networkType completed:(CompletedOperation)completedOperationParam andErrorCallback:(ErrorHandler)errorCallback ssl:(BOOL)ssl {
    MKNetworkEngine *mkNetworkEngine = [self getNetworkEngine:networkType];
    MKNetworkOperation *get = [mkNetworkEngine operationWithPath:url params:params httpMethod:HTTP_GET ssl:ssl];
    [get addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        //DLog(@"%@", [completedOperation responseString]);
        completedOperationParam(completedOperation);
    }            errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        // NSLog(@"completedOperation:%@",completedOperation);
        if (completedOperation.HTTPStatusCode == 403) {
            [self    getCookie:^(MKNetworkOperation *completedOperation) {
            } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
            }];
        }
        if (errorCallback != nil) {
            errorCallback(completedOperation, error);
        }
    }];
    [mkNetworkEngine enqueueOperation:get];
}
#pragma mark - blockchain add queue
- (void)execGetBlockChain:(NSString *)url withParams:(NSDictionary *)params networkType:(BitherNetworkType)networkType completed:(CompletedOperation)completedOperationParam andErrorCallback:(ErrorHandler)errorCallback ssl:(BOOL)ssl{
    MKNetworkEngine *mkNetworkEngine = [self getNetworkEngine:networkType];
    MKNetworkOperation *get = [mkNetworkEngine operationWithPath:url params:params httpMethod:HTTP_GET ssl:ssl];
    [get addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        completedOperationParam(completedOperation);
    }            errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (errorCallback != nil) {
            errorCallback(completedOperation, error);
        }
    }];
    [mkNetworkEngine enqueueOperation:get];
    
    
}

#pragma mark-post

- (void)post:(NSString *)url withParams:(NSDictionary *)params networkType:(BitherNetworkType)networkType
   completed:(CompletedOperation)completedOperationParam andErrorCallBack:(ErrorHandler)errorCallback {
    [self post:url withParams:params networkType:networkType completed:completedOperationParam andErrorCallBack:errorCallback ssl:NO];
}

- (void)post:(NSString *)url withParams:(NSDictionary *)params networkType:(BitherNetworkType)networkType
   completed:(CompletedOperation)completedOperationParam andErrorCallBack:(ErrorHandler)errorCallback ssl:(BOOL)ssl {
    if (errorCallback == nil) {
        errorCallback = errorHandler;
    }
    [self   initEngine:^(MKNetworkOperation *completedOperation) {
        [self execPost:url withParams:params networkType:networkType completed:completedOperationParam andErrorCallBack:errorCallback ssl:ssl];
    } andErrorCallback:^(NSOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp, error);
        }
    }];
}

- (void)execPost:(NSString *)url withParams:(NSDictionary *)params networkType:(BitherNetworkType)networkType completed:(CompletedOperation)completedOperationParam andErrorCallBack:(ErrorHandler)errorCallback ssl:(BOOL)ssl {
    MKNetworkEngine *mkNetworkEngine = [self getNetworkEngine:networkType];
    MKNetworkOperation *post = [mkNetworkEngine operationWithPath:url params:params httpMethod:HTTP_POST ssl:ssl];
    [post addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        completedOperationParam(completedOperation);
    }             errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (completedOperation.HTTPStatusCode == 403) {
            [self    getCookie:^(MKNetworkOperation *completedOperation) {
            } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
            }];
        }
        if (errorCallback != nil) {
            errorCallback(completedOperation, error);
        }

    }];
    [mkNetworkEngine enqueueOperation:post];

}

- (void)getCookie:(CompletedOperation)completedOperationParam andErrorCallBack:(ErrorHandler)errorCallback {
    @synchronized (self) {
        if ([[BitherEngine instance] getCookies].count > 0) {
            completedOperationParam(nil);
            return;
        }
        long long timestmap = ((long long) [[NSDate date] timeIntervalSince1970]) * FORMAT_TIMESTAMP_INTERVAL + 215;
        NSMutableDictionary *md = [[NSMutableDictionary alloc] init];
        MKNetworkEngine *mkNetworkEngine = [self getNetworkEngine:BitherUser];
        [md setValue:[NSNumber numberWithLongLong:timestmap] forKey:TIME_STRING];
        MKNetworkOperation *post = [mkNetworkEngine operationWithPath:BITHER_GET_COOKIE_URL params:md httpMethod:HTTP_POST];
        [post addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            [[BitherEngine instance] setEngineCookie];
            if (completedOperationParam) {
                completedOperationParam(completedOperation);
            }
        }             errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            if (errorCallback) {
                errorCallback(completedOperation, error);
            }
        }];
        [mkNetworkEngine enqueueOperation:post];

    }

}

- (MKNetworkEngine *)getNetworkEngine:(BitherNetworkType)networkType {
    MKNetworkEngine *networkEngine;
    BitherEngine *bitherEngine = [BitherEngine instance];
    switch (networkType) {
        case BitherUser:
            networkEngine = [bitherEngine getUserNetworkEngine];
            break;
        case BitherBitcoin:
            networkEngine = [bitherEngine getBitcoinNetworkEngine];
            break;
        case BitherStats:
            networkEngine = [bitherEngine getStatsNetworkEngine];
            break;
        case BitherBC:
            networkEngine = [bitherEngine getBCNetworkEngine];
            break;
        case BitherHDM:
            networkEngine = [bitherEngine getHDMNetworkEngine];
            break;
        case BlockChain:
            networkEngine = [bitherEngine getBlockChainEngine];
            break;
        case ChainBtcCom:
            networkEngine = [bitherEngine getChainBtcComEngine];
            break;
        default:
            networkEngine = [bitherEngine getUserNetworkEngine];
            break;
    }
    return networkEngine;
}
@end
