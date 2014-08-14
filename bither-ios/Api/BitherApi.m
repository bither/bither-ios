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
#import "TransactionsUtil.h"
#import "NSDictionary+Fromat.h"
#import "ExchangeUtil.h"
#import "Ticker.h"
#import "MarketUtil.h"
#import "BitherSetting.h"
#import "BTUtils.h"
#import "CacheUtil.h"

static BitherApi *piApi;
@implementation BitherApi

+ (BitherApi *)instance {
    @synchronized(self) {
        if (piApi == nil) {
            piApi = [[self alloc] init];
        }
    }
    return piApi;
}
-(void)getSpvBlock:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback{
    [self get:BITHER_GET_ONE_SPVBLOCK_API withParams:nil networkType:BitherBitcoin completed:^(MKNetworkOperation *completedOperation) {
        if (![StringUtil isEmpty:completedOperation.responseString]) {
            NSLog(@"spv: %s",[completedOperation.responseString UTF8String]);
            NSDictionary *dict = [completedOperation responseJSON];
            if (callback) {
                callback(dict);
            }
        }
    } andErrorCallback:^(MKNetworkOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp ,error);
        }
        
    }];

}
-(void)getExchangeTrend:(MarketType) marketType callback:(ArrayResponseBlock) callback andErrorCallBack:(ErrorHandler)errorCallback{
    NSString  *url=[NSString stringWithFormat:BITHER_TREND_URL ,marketType];
    [self get:url withParams:nil networkType:BitherStats completed:^(MKNetworkOperation *completedOperation) {
        if (callback) {
            callback(completedOperation.responseJSON);
        }
        
    } andErrorCallback:^(MKNetworkOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp,error);
        }
    }];
}
-(void)getExchangeDepth:(MarketType) marketType callback:(ArrayResponseBlock) callback andErrorCallBack:(ErrorHandler)errorCallback{
    //[];
}
-(void)getMyTransactionApi:(NSString *)address callback:(DictResponseBlock) callback andErrorCallBack:(ErrorHandler)errorCallback{
    NSString  *url=[NSString stringWithFormat:BITHER_Q_MYTRANSACTIONS ,address];
    [self get:url withParams:nil networkType:BitherBitcoin  completed:^(MKNetworkOperation *completedOperation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
            NSLog(@"%@",completedOperation.responseString);
            if (![StringUtil isEmpty:completedOperation.responseString]) {
                NSDictionary *dict=completedOperation.responseJSON;
                if (callback) {
                    callback(dict);
                }
            }
        });
        
    } andErrorCallback:^(MKNetworkOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp,error);
        }
    }];
}

-(void)getExchangeTicker:(VoidBlock) callback andErrorCallBack:(ErrorHandler)errorCallback{
    [self get:BITHER_EXCHANGE_TICKER withParams:nil networkType:BitherStats completed:^(MKNetworkOperation *completedOperation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
            if (![StringUtil isEmpty:completedOperation.responseString]) {
                [BTUtils writeFile:[CacheUtil getTickerFile] content:completedOperation.responseString];
                NSDictionary *dict=completedOperation.responseJSON;
                [MarketUtil handlerResult:dict];
             
                if (callback) {
                    callback();
                }
            }
            
        });
    } andErrorCallback:^(MKNetworkOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp,error);
        }
        
    }];
    
}

- (void)uploadCrash:(NSString *)data callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    NSMutableDictionary *dict=[NSMutableDictionary new];
    [dict setObject:data forKey:@"error_msg"];
    [self post:BITHER_ERROR_API withParams:dict networkType:BitherUser completed:^(MKNetworkOperation *completedOperation) {
        if (callback) {
            callback(nil);
        }
    } andErrorCallBack:^(MKNetworkOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp,error);
        }
    }];
}




@end
