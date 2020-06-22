//
//  BlockchairUnspentTxsApi.m
//  bither-ios
//
//  Created by 韩珍 on 2020/6/19.
//  Copyright © 2020 Bither. All rights reserved.
//

#import "BlockchairUnspentTxsApi.h"

@implementation BlockchairUnspentTxsApi

+ (BlockchairUnspentTxsApi *)instance {
    return [[self alloc] init];
}

- (void)queryUnspentTxs:(NSString *)txHashs callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    NSString *url = [NSString stringWithFormat:BLOCKCHAIR_COM_ADDRESS_UNSPENT_TXS_URL, txHashs];
    [self queryUnspentTxs:url requestCount:1 callback:callback andErrorCallBack:errorCallback];
}

- (void)queryUnspentTxs:(NSString *)url requestCount:(int)requestCount callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    [self get:url withParams:nil networkType:Blockchair completed:^(MKNetworkOperation *completedOperation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if ([self dataIsError:completedOperation]) {
                NSError *error = [[NSError alloc] initWithDomain:@"blockchair data error" code:400 userInfo:NULL];
                [self handleError:error requestCount:requestCount retry:^(int requestCount) {
                    [self queryUnspentTxs:url requestCount:requestCount callback:callback andErrorCallBack:errorCallback];
                } andErrorCallBack:^{
                    if (errorCallback) {
                        errorCallback(error);
                    }
                }];
                return;
            }
            NSDictionary *dict = completedOperation.responseJSON;
            NSDictionary *dataJson = [dict objectForKey:@"data"];
            if (!dataJson || dataJson.count == 0) {
                NSError *error = [[NSError alloc] initWithDomain:@"blockchair data error" code:400 userInfo:NULL];
                [self handleError:error requestCount:requestCount retry:^(int requestCount) {
                    [self queryUnspentTxs:url requestCount:requestCount callback:callback andErrorCallBack:errorCallback];
                } andErrorCallBack:^{
                    if (errorCallback) {
                        errorCallback(error);
                    }
                }];
                return;
            }
            if (callback) {
                callback(dataJson);
            }
        });
    } andErrorCallback:^(NSError *error) {
        [self handleError:error requestCount:requestCount retry:^(int requestCount) {
            [self queryUnspentTxs:url requestCount:requestCount callback:callback andErrorCallBack:errorCallback];
        } andErrorCallBack:^{
            if (errorCallback) {
                errorCallback(error);
            }
        }];
    }];
    
}

@end
