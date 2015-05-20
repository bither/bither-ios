//
//  WatchApi.m
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
//
//  Created by songchenwen on 2015/2/27.
//

#import "WatchApi.h"
#import "GroupFileUtil.h"
#import "WatchStringUtil.h"
#import "WatchMarket.h"

static WatchApi *piApi;
@implementation WatchApi

+ (WatchApi *)instance {
    @synchronized (self) {
        if (piApi == nil) {
            piApi = [[self alloc] init];
        }
    }
    return piApi;
}

- (void)getExchangeTrend:(MarketType) marketType callback:(void (^)(NSArray *array)) callback andErrorCallBack:(void (^)(NSOperation *errorOp, NSError *error))errorCallback{
    NSString *url = [NSString stringWithFormat:BITHER_TREND_URL, [GroupUtil getMarketValue:marketType]];
    [self get:url withParams:nil networkType:BitherStats completed:^(MKNetworkOperation *completedOperation) {
        if (callback) {
            callback(completedOperation.responseJSON);
        }
        
    } andErrorCallback:^(NSOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp, error);
        }
    }];
}


- (void)getExchangeTicker:(void (^)(void))callback  andErrorCallBack:(void (^)(NSOperation *errorOp, NSError *error))errorCallback{
    [self get:BITHER_EXCHANGE_TICKER withParams:nil networkType:BitherStats completed:^(MKNetworkOperation *completedOperation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString * str=completedOperation.responseString;
            if (!(str==nil||str.length==0)) {
                [GroupFileUtil setTicker:str];
                NSDictionary *dict = completedOperation.responseJSON;
                NSDictionary *currencies_rate_dict = dict[@"currencies_rate"];
                currencies_rate_dict = [WatchMarket parseCurrenciesRate:currencies_rate_dict];
                [GroupFileUtil setCurrencyRate:[currencies_rate_dict jsonEncodedKeyValueString]];
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

@end
