//
//  BlockchairQueryAddressUnspentApi.m
//  bither-ios
//
//  Created by 韩珍 on 2020/6/18.
//  Copyright © 2020 Bither. All rights reserved.
//

#import "BlockchairQueryAddressUnspentApi.h"

@interface BlockchairQueryAddressUnspentApi () {
    NSString *_addressesStr;
    NSArray *_addressArr;
    int _offset;
    NSMutableDictionary *_result;
}
@end


@implementation BlockchairQueryAddressUnspentApi

+ (BlockchairQueryAddressUnspentApi *)instance {
    return [[self alloc] init];
}


- (void)queryAddressUnspent:(NSString *)addressesStr callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    _addressesStr = addressesStr;
    _addressArr = [addressesStr componentsSeparatedByString:@","];
    _offset = 0;
    _result = [NSMutableDictionary dictionary];
    _result[BLOCKCHAIR_LAST_TX_ADDRESS] = @"";
    _result[BLOCKCHAIR_HAS_TX_ADDRESSES] = @"";
    _result[BLOCKCHAIR_HAS_UTXO_ADDRESSES] = @"";
    NSString *url = [NSString stringWithFormat:BLOCKCHAIR_COM_Q_ADDRESSES_UNSPENT_URL, addressesStr, _offset];
    [self queryAddressUnspent:url firstEngine:[[BitherEngine instance] getBlockchairEngine] requestCount:1 callback:callback andErrorCallBack:errorCallback];
}

- (void)queryAddressUnspent:(NSString *)url firstEngine:(MKNetworkEngine *)firstEngine requestCount:(int)requestCount callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    [self get:url withParams:nil networkType:Blockchair completed:^(MKNetworkOperation *completedOperation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if ([self dataIsError:completedOperation]) {
                NSError *error = [[NSError alloc] initWithDomain:@"blockchair data error" code:400 userInfo:NULL];
                [self handleError:error firstEngine:firstEngine requestCount:requestCount retry:^(int requestCount) {
                    [self queryAddressUnspent:url firstEngine:firstEngine requestCount:requestCount callback:callback andErrorCallBack:errorCallback];
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
                if (callback) {
                    callback(_result);
                }
                return;
            }
            if (_offset == 0) {
                NSDictionary *addressesJson = [dataJson objectForKey:@"addresses"];
                if (!addressesJson || addressesJson.count == 0) {
                    if (callback) {
                        callback(_result);
                    }
                    return;
                }
                NSString *lastTxAddress = @"";
                NSString *hasTxAddresses = @"";
                for (NSString *address in _addressArr) {
                    if (![addressesJson.allKeys containsObject:address]) {
                        continue;
                    }
                    NSDictionary *addressJson = [addressesJson objectForKey:address];
                    if (!addressJson || ![[addressJson allKeys] containsObject:@"received"]) {
                        continue;
                    }
                    long received = [[addressJson objectForKey:@"received"] longValue];
                    if (received <= 0) {
                        continue;
                    }
                    if (hasTxAddresses.length == 0) {
                        hasTxAddresses = address;
                    } else if (![hasTxAddresses containsString:address]) {
                        hasTxAddresses = [NSString stringWithFormat:@"%@,%@", hasTxAddresses, address];
                    }
                    lastTxAddress = address;
                }
                _result[BLOCKCHAIR_LAST_TX_ADDRESS] = lastTxAddress;
                _result[BLOCKCHAIR_HAS_TX_ADDRESSES] = hasTxAddresses;
            }
            NSDictionary *setJson = [dataJson objectForKey:@"set"];
            if (!setJson) {
                if (callback) {
                    callback(_result);
                }
                return;
            }
            long unspentOutputCount = [[setJson objectForKey:@"unspent_output_count"] longValue];
            if (unspentOutputCount == 0) {
                if (callback) {
                    callback(_result);
                }
                return;
            }
            if (![[dataJson allKeys] containsObject:@"utxo"]) {
                if (callback) {
                    callback(_result);
                }
                return;
            }
            NSArray *utxoArr = [dataJson objectForKey:@"utxo"];
            if (!utxoArr || utxoArr.count == 0) {
                if (callback) {
                    callback(_result);
                }
                return;
            }
            NSMutableArray *lastUtxoArr = [[_result allKeys] containsObject:BLOCKCHAIR_UTXO] ? _result[BLOCKCHAIR_UTXO] : [NSMutableArray array];
            NSString *hasUtxoAddresses = [_result objectForKey:BLOCKCHAIR_HAS_UTXO_ADDRESSES];
            for (NSDictionary *utxoJson in utxoArr) {
                NSArray *allKeys = utxoJson.allKeys;
                if (![allKeys containsObject:@"transaction_hash"] || ![allKeys containsObject:@"address"] || ![allKeys containsObject:@"block_id"] || [[utxoJson objectForKey:@"block_id"] intValue] == -1) {
                    continue;
                }
                NSString *address = [utxoJson objectForKey:@"address"];
                if (hasUtxoAddresses.length == 0) {
                    hasUtxoAddresses = address;
                } else if (![hasUtxoAddresses containsString:address]) {
                    hasUtxoAddresses = [NSString stringWithFormat:@"%@,%@", hasUtxoAddresses, address];
                }
                [lastUtxoArr addObject:utxoJson];
            }
            _result[BLOCKCHAIR_HAS_UTXO_ADDRESSES] = hasUtxoAddresses;
            _result[BLOCKCHAIR_UTXO] = lastUtxoArr;
            long currentUnspentOutputCount = _offset == 0 ? utxoArr.count : _offset + utxoArr.count;
            if (currentUnspentOutputCount < unspentOutputCount) {
                _offset = _offset + 100;
                [self queryAddressUnspent:[NSString stringWithFormat:BLOCKCHAIR_COM_Q_ADDRESSES_UNSPENT_URL, _addressesStr, _offset] firstEngine:firstEngine requestCount:1 callback:callback andErrorCallBack:errorCallback];
                return;
            }
            if (callback) {
                callback(_result);
            }
        });
    } andErrorCallback:^(NSError *error) {
        if (error.code == 404) {
            if (callback) {
                callback(_result);
            }
            return;
        }
        [self handleError:error firstEngine:firstEngine requestCount:requestCount retry:^(int requestCount) {
            [self queryAddressUnspent:url firstEngine:firstEngine requestCount:requestCount callback:callback andErrorCallBack:errorCallback];
        } andErrorCallBack:^{
            if (errorCallback) {
                errorCallback(error);
            }
        }];
    }];
}

@end
