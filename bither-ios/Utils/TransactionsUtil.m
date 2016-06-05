//  TransactionsUtil.m
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

#import <Bitheri/BTHDAccountAddressProvider.h>
#import "TransactionsUtil.h"
#import "NSDictionary+Fromat.h"
#import "DateUtil.h"
#import "BitherApi.h"
#import "BTAddressManager.h"
#import "BTBlockChain.h"
#import "BTIn.h"
#import "UnitUtil.h"

#define BLOCK_COUNT  @"block_count"

#define TX_VER @"ver"
#define TX_IN @"in"
#define TX_OUT @"out"

#define TX_OUT_ADDRESS @"address"
#define TX_COINBASE @"coinbase"
#define TX_SEQUENCE @"sequence"
#define TX_TIME @"time"

#define TXS @"txs"
#define BLOCK_HASH @"block_hash"
#define TX_HASH @"tx_hash"
#define BLOCK_NO @"block_no"
#define VALUE @"val"
#define PREV_TX_HASH @"prev"
#define PREV_OUTPUT_SN @"n"
#define SCRIPT_PUB_KEY @"script"

#define SPECIAL_TYPE @"special_type"


@implementation TransactionsUtil

+ (void)getAddressState:(NSArray *)addressList index:(NSInteger)index callback:(IdResponseBlock)callback andErrorCallback:(ErrorBlock)errorBlcok {
    if (index == addressList.count) {
        if (callback) {
            callback([NSNumber numberWithInt:AddressNormal]);
        }
    } else {
        NSString *address = [addressList objectAtIndex:index];
        index++;
        [[BitherApi instance] getMyTransactionApi:address callback:^(NSDictionary *dict) {
            if ([[dict allKeys] containsObject:SPECIAL_TYPE]) {
                NSInteger specialType = [dict getIntFromDict:SPECIAL_TYPE];
                if (specialType == 0) {
                    if (callback) {
                        callback([NSNumber numberWithInt:AddressSpecialAddress]);
                    }
                } else {
                    if (callback) {
                        callback([NSNumber numberWithInt:AddressTxTooMuch]);
                    }
                }
            } else {
                [self getAddressState:addressList index:index callback:callback andErrorCallback:errorBlcok];
            }
        }                        andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
            if (errorBlcok) {
                errorBlcok(error);
            }
        }];
    }

}

+ (NSArray *)getTransactions:(NSDictionary *)dict storeBlockHeight:(uint32_t)storeBlockHeigth {
    NSMutableArray *array = [NSMutableArray new];
    if ([[dict allKeys] containsObject:TXS]) {
        NSArray *txs = [dict objectForKey:TXS];
        for (NSDictionary *txDict in  txs) {
            BTTx *tx = [[BTTx alloc] init];
            //  NSData * blockHashData=[[[txDict getStringFromDict:BLOCK_HASH] hexToData] reverse];
            NSData *txHash = [[txDict getStringFromDict:TX_HASH] hexToData].reverse;
            uint32_t blockNo = [txDict getIntFromDict:BLOCK_NO];

            if (storeBlockHeigth > 0 && blockNo > storeBlockHeigth) {
                continue;
            }
            int version = [txDict getIntFromDict:TX_VER andDefault:1];
            NSString *timeStr = [txDict getStringFromDict:TX_TIME];
            uint32_t time = [[DateUtil getDateFormStringWithTimeZone:timeStr] timeIntervalSince1970];
            [tx setTxHash:txHash];
            [tx setTxVer:version];
            [tx setBlockNo:blockNo];
            [tx setTxTime:time];
            if ([[txDict allKeys] containsObject:TX_OUT]) {
                NSArray *outArray = [txDict objectForKey:TX_OUT];
                for (NSDictionary *outDict in outArray) {
                    uint64_t value = [outDict getLongLongFromDict:VALUE];
                    //  NSString * address=[outDict getStringFromDict:TX_OUT_ADDRESS];
                    NSString *pubKey = [outDict getStringFromDict:SCRIPT_PUB_KEY];
                    [tx addOutputScript:[pubKey hexToData] amount:value];
                }

            }
            if ([[txDict allKeys] containsObject:TX_IN]) {
                NSArray *inArray = [txDict objectForKey:TX_IN];
                for (NSDictionary *inDict in inArray) {
                    if ([[inDict allKeys] containsObject:TX_COINBASE]) {
                        int index = [inDict getIntFromDict:TX_SEQUENCE];
                        [tx addInputHash:@"".hexToData index:index script:nil];
                    } else {
                        NSData *prevOutHash = [[inDict getStringFromDict:PREV_TX_HASH] hexToData].reverse;
                        int index = [inDict getIntFromDict:PREV_OUTPUT_SN];
                        [tx addInputHash:prevOutHash index:index script:nil];
                    }

                }

            }
            NSMutableArray *txInputHashes = [NSMutableArray new];
            for (BTIn *btIn in tx.ins) {
                [txInputHashes addObject:btIn.prevTxHash];
            }
            for (BTTx *temp in array) {
                if (temp.blockNo == tx.blockNo) {
                    NSMutableArray *tempInputHashes = [NSMutableArray new];
                    for (BTIn *btIn in temp.ins) {
                        [tempInputHashes addObject:btIn.prevTxHash];
                    }
                    if ([tempInputHashes containsObject:tx.txHash]) {
                        [tx setTxTime:temp.txTime - 1];
                    } else if ([txInputHashes containsObject:temp.txHash]) {
                        [tx setTxTime:temp.txTime + 1];
                    }
                }
            }
            [array addObject:tx];

        }
    }
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 blockNo] > [obj2 blockNo]) return NSOrderedDescending;
        if ([obj1 blockNo] < [obj2 blockNo]) return NSOrderedAscending;
        if ([obj1 txTime] > [obj2 txTime]) return NSOrderedDescending;
        if ([obj1 txTime] < [obj2 txTime]) return NSOrderedAscending;
        NSLog(@"NSOrderedSame");
        return NSOrderedSame;
    }];
    return array;
}
#pragma mark - syncWallet From blockChain.info
+ (void)syncWalletFrom_blockChain:(VoidBlock)voidBlock andErrorCallBack:(ErrorHandler)errorCallback{
    NSArray *addresses = [[BTAddressManager instance] allAddresses];
    if ([[BTAddressManager instance] allSyncComplete]) {
        if (voidBlock) {
            voidBlock();
        }
        return;
    }
    addresses = [addresses reverseObjectEnumerator].allObjects;
    __block int completeCount = 0;
    int needCompleteCount = addresses.count + [[BTAddressManager instance] hasHDAccountHot] + [[BTAddressManager instance] hasHDAccountMonitored];
    //遍历所有的地址
    for (BTAddress *address in addresses) {
        //通过每个地址获取交易
        [TransactionsUtil getTxsFromBlockChain:address callback:^{
            completeCount +=1;
            if (completeCount == needCompleteCount) {
                if (voidBlock) {
                    voidBlock();
                }
            }
        } andErrorCallBack:errorCallback];
    }
    
    
    
    NSMutableArray *hdAccounts = [NSMutableArray new];
    if ([[BTAddressManager instance] hasHDAccountHot]) {
        [hdAccounts addObject:[[BTAddressManager instance] hdAccountHot]];
    }
    if ([[BTAddressManager instance] hasHDAccountMonitored]) {
        [hdAccounts addObject:[[BTAddressManager instance] hdAccountMonitored]];
    }
    for (BTHDAccount *account in hdAccounts) {
        [TransactionsUtil getMyTxFromBlockChainForHDAccount:account.getHDAccountId callback:^{
            completeCount += 1;
            if (completeCount == needCompleteCount) {
                if (voidBlock) {
                    voidBlock();
                }
            }
        } andErrorCallBack:errorCallback];
    }
    
    
}
#pragma mark - syncwallet from bither.net
+ (void)syncWallet:(VoidBlock)voidBlock andErrorCallBack:(ErrorHandler)errorCallback {
    NSArray *addresses = [[BTAddressManager instance] allAddresses];
    if ([[BTAddressManager instance] allSyncComplete]) {
        if (voidBlock) {
            voidBlock();
        }
        return;
    }
    addresses = [addresses reverseObjectEnumerator].allObjects;
    __block int completeCount = 0;
    int needCompleteCount = addresses.count + [[BTAddressManager instance] hasHDAccountHot] + [[BTAddressManager instance] hasHDAccountMonitored];
    for (BTAddress *address in addresses) {
        [TransactionsUtil getTxs:address callback:^{
            completeCount += 1;
            if (completeCount == needCompleteCount) {
                if (voidBlock) {
                    voidBlock();
                }
            }
        } andErrorCallBack:errorCallback];
    }

    NSMutableArray *hdAccounts = [NSMutableArray new];
    if ([[BTAddressManager instance] hasHDAccountHot]) {
        [hdAccounts addObject:[[BTAddressManager instance] hdAccountHot]];
    }
    if ([[BTAddressManager instance] hasHDAccountMonitored]) {
        [hdAccounts addObject:[[BTAddressManager instance] hdAccountMonitored]];
    }
    for (BTHDAccount *account in hdAccounts) {
        [TransactionsUtil getMyTxForHDAccount:account.getHDAccountId callback:^{
            completeCount += 1;
            if (completeCount == needCompleteCount) {
                if (voidBlock) {
                    voidBlock();
                }
            }
        } andErrorCallBack:errorCallback];
    }
}
#pragma mark - getMyTxFromBlockChainForHDAccount
+ (void)getMyTxFromBlockChainForHDAccount:(int)hdAccountId callback:(VoidBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    NSMutableArray *pathArray = [NSMutableArray new];
    [pathArray addObject:@(EXTERNAL_ROOT_PATH)];
    [pathArray addObject:@(INTERNAL_ROOT_PATH)];
    __block int completeCount = 0;
    int needCompleteCount = pathArray.count;
    for (NSNumber *pathType in pathArray){
        __block int index = 0;
        [TransactionsUtil getMyTxFromBlockChainForHDAccount:hdAccountId pathType:(PathType) [pathType intValue] index:index callback:^{
            completeCount += 1;
            if (completeCount == needCompleteCount) {
                if (callback) {
                    callback();
                }
            }
        } andErrorCallBack:errorCallback];
    }
}

+ (void)getMyTxFromBlockChainForHDAccount:(int)hdAccountId pathType:(PathType)pathType index:(int)index callback:(VoidBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    int unSyncedCount = [[BTHDAccountAddressProvider instance] getUnSyncedAddressCountByHDAccountId:hdAccountId pathType:pathType];
    BTHDAccountAddress *address = [[BTHDAccountAddressProvider instance] getAddressByHDAccountId:hdAccountId path:pathType index:index];
    if (unSyncedCount == 0) {
        if (callback) {
            callback();
        }
    } else {
        int nextIndex = index + 1;
        [TransactionsUtil getTxFromBlockChainForHDAccountAddress:address callback:^(void) {
            int unSyncedCountInBlock = [[BTHDAccountAddressProvider instance] getUnSyncedAddressCountByHDAccountId:hdAccountId pathType:pathType];
            if (unSyncedCountInBlock == 0) {
                if (callback) {
                    callback();
                }
            } else {
                [TransactionsUtil getMyTxFromBlockChainForHDAccount:hdAccountId pathType:pathType index:nextIndex
                                                           callback:callback andErrorCallBack:errorCallback];
            }
        }                         andErrorCallBack:errorCallback];
    }
}
+ (void)getTxFromBlockChainForHDAccountAddress:(BTHDAccountAddress *)address
                                      callback:(VoidBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    __block int page = 0;
    if (address.isSyncedComplete) {
        if (callback) {
            callback();
        }
        return;
    }
    ErrorHandler errorHandler = ^(NSOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp, error);
        }
        NSLog(@"get my transcation api %@", errorOp);
    };
    __block DictResponseBlock nextPageBlock = ^(NSDictionary *dict) {
        int txCnt = [dict[@"n_tx"] intValue];
        NSArray *txs = [TransactionsUtil getTxsFromBlockChain:dict];
        [[[BTAddressManager instance] getHDAccountByHDAccountId:address.hdAccountId] initTxs:[[BTAddressManager instance] compressTxsForApi:txs andAddress:address.address]];
        if (txCnt > txs.count && txs.count != 0) {
            page += 1;
            [[BitherApi instance] getTransactionApiFromBlockChain:address.address withPage:page*50 callback:nextPageBlock andErrorCallBack:errorHandler];
        }
        else {
            nextPageBlock = nil;
            [[BitherApi instance]getblockHeightApiFromBlockChain:address.address callback:^(NSDictionary *dict) {
                int blockCount = [dict[@"height"] intValue];
                uint32_t storeHeight = [[BTBlockChain instance] lastBlock].blockNo;
                if (blockCount < storeHeight && storeHeight - blockCount < 100) {
                    [[BTBlockChain instance] rollbackBlock:(uint32_t) blockCount];
                }
                
                [address setIsSyncedComplete:YES];
                [[BTHDAccountAddressProvider instance] updateSyncedCompleteByHDAccountId:address.hdAccountId address:address];
                
                if (txCnt > 0) {
                    [[[BTAddressManager instance] getHDAccountByHDAccountId:address.hdAccountId] updateIssuedIndex:address.pathType index:address.index - 1];
                    [[[BTAddressManager instance] getHDAccountByHDAccountId:address.hdAccountId] supplyEnoughKeys:NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kHDAccountPaymentAddressChangedNotification object:[[BTAddressManager instance] getHDAccountByHDAccountId:address.hdAccountId].address userInfo:@{kHDAccountPaymentAddressChangedNotificationFirstAdding : @(NO)}];
                }
                else {
                    int addressCount = kHDAccountMaxUnusedNewAddressCount;
                    if (![[BTHDAccountAddressProvider instance] hasHDAccount:address.hdAccountId pathType:address.pathType receiveTxInAddressCount:addressCount]) {
                        [[BTHDAccountAddressProvider instance] updateSyncedByHDAccountId:address.hdAccountId pathType:address.pathType index:address.index];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:BitherAddressNotification object:address.address];
                });
                if (callback) {
                    callback();
                }
            } andErrorCallBack:errorHandler];
        }
    };
    [[BitherApi instance] getTransactionApiFromBlockChain:address.address withPage:page*50 callback:nextPageBlock andErrorCallBack:errorHandler];
}
#pragma mark - getMyTxFromBlockChainForHDAccount
+ (void)getMyTxForHDAccount:(int)hdAccountId callback:(VoidBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    NSMutableArray *pathArray = [NSMutableArray new];
    [pathArray addObject:@(EXTERNAL_ROOT_PATH)];
    [pathArray addObject:@(INTERNAL_ROOT_PATH)];
    __block int completeCount = 0;
    int needCompleteCount = pathArray.count;
    for (NSNumber *pathType in pathArray){
        __block int index = 0;
        [TransactionsUtil getMyTxForHDAccount:hdAccountId pathType:(PathType) [pathType intValue] index:index callback:^{
            completeCount += 1;
            if (completeCount == needCompleteCount) {
                if (callback) {
                    callback();
                }
            }
        } andErrorCallBack:errorCallback];
    }
}

+ (void)getMyTxForHDAccount:(int)hdAccountId pathType:(PathType)pathType index:(int)index
                   callback:(VoidBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    int unSyncedCount = [[BTHDAccountAddressProvider instance] getUnSyncedAddressCountByHDAccountId:hdAccountId pathType:pathType];
    BTHDAccountAddress *address = [[BTHDAccountAddressProvider instance] getAddressByHDAccountId:hdAccountId path:pathType index:index];
    index++;
    if (unSyncedCount == 0) {
        if (callback) {
            callback();
        }
    } else {
        [TransactionsUtil getTxForHDAccountAddress:address callback:^(void) {
            int unSyncedCountInBlock = [[BTHDAccountAddressProvider instance] getUnSyncedAddressCountByHDAccountId:hdAccountId pathType:pathType];
            if (unSyncedCountInBlock == 0) {
                if (callback) {
                    callback();
                }
            } else {
                [TransactionsUtil getMyTxForHDAccount:hdAccountId pathType:pathType index:index
                                             callback:callback andErrorCallBack:errorCallback];
            }
        }                         andErrorCallBack:errorCallback];
    }


}

+ (void)getTxForHDAccountAddress:(BTHDAccountAddress *)address
                        callback:(VoidBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    __block int page = 1;
    if (address.isSyncedComplete) {
        if (callback) {
            callback();
        }
        return;
    }
    ErrorHandler errorHandler = ^(NSOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp, error);
        }
        NSLog(@"get my transcation api %@", errorOp);
    };

    __block DictResponseBlock nextPageBlock = ^(NSDictionary *dict) {
        int txCnt = [dict[@"tx_cnt"] intValue];
        NSArray *txs = [TransactionsUtil getTxs:dict];

        [[[BTAddressManager instance] getHDAccountByHDAccountId:address.hdAccountId] initTxs:[[BTAddressManager instance] compressTxsForApi:txs andAddress:address.address]];
        if (txCnt > txs.count && txs.count != 0) {
            page += 1;
            [[BitherApi instance] getTransactionApi:address.address withPage:page callback:nextPageBlock andErrorCallBack:errorHandler];
        } else {
            nextPageBlock = nil;

            int blockCount = [dict[@"block_count"] intValue];
            uint32_t storeHeight = [[BTBlockChain instance] lastBlock].blockNo;
            if (blockCount < storeHeight && storeHeight - blockCount < 100) {
                [[BTBlockChain instance] rollbackBlock:(uint32_t) blockCount];
            }

            [address setIsSyncedComplete:YES];
            [[BTHDAccountAddressProvider instance] updateSyncedCompleteByHDAccountId:address.hdAccountId address:address];

            if (txCnt > 0) {
                [[[BTAddressManager instance] getHDAccountByHDAccountId:address.hdAccountId] updateIssuedIndex:address.pathType index:address.index - 1];
                [[[BTAddressManager instance] getHDAccountByHDAccountId:address.hdAccountId] supplyEnoughKeys:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:kHDAccountPaymentAddressChangedNotification object:[[BTAddressManager instance] getHDAccountByHDAccountId:address.hdAccountId].address userInfo:@{kHDAccountPaymentAddressChangedNotificationFirstAdding : @(NO)}];
            } else {
                int addressCount = kHDAccountMaxUnusedNewAddressCount;
                if (![[BTHDAccountAddressProvider instance] hasHDAccount:address.hdAccountId pathType:address.pathType receiveTxInAddressCount:addressCount]) {
                    [[BTHDAccountAddressProvider instance] updateSyncedByHDAccountId:address.hdAccountId pathType:address.pathType index:address.index];
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:BitherAddressNotification object:address.address];
            });
            if (callback) {
                callback();
            }
        }
    };
    [[BitherApi instance] getTransactionApi:address.address withPage:page callback:nextPageBlock andErrorCallBack:errorHandler];
}
#pragma mark - getTx(from_blockChain.info)

+ (void)getTxsFromBlockChain:(BTAddress *)address callback:(VoidBlock)callback andErrorCallBack:(ErrorHandler)errorCallback{
    __block int page = 0;
    
    ErrorHandler errorHandler = ^(NSOperation *errOp,NSError *error){
        if (errorCallback) {
            errorCallback(errOp,error);
        }
        NSLog(@"get my transcation Api %@",errOp);
    };
    __block DictResponseBlock nextPageBlock = ^(NSDictionary *dict) {
        int txCnt = [dict[@"n_tx"] intValue];
        //获得存放交易的数组
        NSArray *txs = [TransactionsUtil getTxsFromBlockChain:dict];
        
        [address initTxs:[[BTAddressManager instance] compressTxsForApi:txs andAddress:address.address]];
        if (txCnt > txs.count && txs.count != 0) {
            page += 1;
            [[BitherApi instance] getTransactionApiFromBlockChain:address.address withPage:page*50 callback:nextPageBlock andErrorCallBack:errorHandler];
        }
        else{
            nextPageBlock = nil;
            [[BitherApi instance] getblockHeightApiFromBlockChain:address.address callback:^(NSDictionary *dict){
                int blockCount = [dict[@"height"] intValue];
                uint32_t storeHeight = [[BTBlockChain instance] lastBlock].blockNo;
                if (blockCount < storeHeight && storeHeight - blockCount < 100) {
                    [[BTBlockChain instance] rollbackBlock:(uint32_t) blockCount];
                }
                
                [address setIsSyncComplete:YES];
                [address updateSyncComplete];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:BitherAddressNotification object:address.address];
                });
                if (callback) {
                    callback();
                }
                
            } andErrorCallBack:errorHandler];
        }
    };
    [[BitherApi instance] getTransactionApiFromBlockChain:address.address withPage:page*50 callback:nextPageBlock andErrorCallBack:errorHandler];
}
#pragma mark - getTxsFrom bither.net
+ (void)getTxs:(BTAddress *)address callback:(VoidBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    __block int page = 1;

    ErrorHandler errorHandler = ^(NSOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp, error);
        }
        NSLog(@"get my transcation api %@", errorOp);
    };

    __block DictResponseBlock nextPageBlock = ^(NSDictionary *dict) {
        int txCnt = [dict[@"tx_cnt"] intValue];
        NSArray *txs = [TransactionsUtil getTxs:dict];

        [address initTxs:[[BTAddressManager instance] compressTxsForApi:txs andAddress:address.address]];
        if (txCnt > txs.count && txs.count != 0) {
            page += 1;
            [[BitherApi instance] getTransactionApi:address.address withPage:page callback:nextPageBlock andErrorCallBack:errorHandler];
        } else {
            nextPageBlock = nil;

            int blockCount = [dict[@"block_count"] intValue];
            uint32_t storeHeight = [[BTBlockChain instance] lastBlock].blockNo;
            if (blockCount < storeHeight && storeHeight - blockCount < 100) {
                [[BTBlockChain instance] rollbackBlock:(uint32_t) blockCount];
            }

            [address setIsSyncComplete:YES];
            [address updateSyncComplete];

            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:BitherAddressNotification object:address.address];
            });
            if (callback) {
                callback();
            }
        }
    };

    [[BitherApi instance] getTransactionApi:address.address withPage:page callback:nextPageBlock andErrorCallBack:errorHandler];
}

#pragma mark - getTxsFromBlockchain.info
+ (NSMutableArray *)getTxsFromBlockChain:(NSDictionary *)dict{
    NSArray *array = [[BTBlockChain instance] getAllBlocks];
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    BTBlock *minBlock = array[array.count - 1];
    uint32_t minBlockNo = minBlock.blockNo;
    for (BTBlock *block in array) {
        if (block.blockNo < minBlockNo) {
            minBlockNo = block.blockNo;
        }
        dictionary[@(block.blockNo)] = block;
    }
    NSMutableArray *txs = [NSMutableArray new];
    for (NSDictionary *each in dict[@"txs"]) {
        NSString * txIndex = each[@"tx_index"];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:BLOCK_INFO_TX_INDEX_URL,txIndex]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        //NSLog(@"%@",url);
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    BTTx *tx = [[BTTx alloc] initWithMessage:[aString hexToData]];
    tx.blockNo = (uint32_t) [each[@"block_height"] intValue];
    BTBlock *block;
        if (tx.blockNo < minBlockNo) {
            block = dictionary[@(minBlockNo)];
        } else {
        block = dictionary[@(tx.blockNo)];
        }
        tx.txTime = (uint32_t)[each[@"time"]intValue];
        [txs addObject:tx];

    }
    return txs;
}
#pragma mark - getTxsFromBither.net
+ (NSArray *)getTxs:(NSDictionary *)dict; {
    NSArray *array = [[BTBlockChain instance] getAllBlocks];
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    BTBlock *minBlock = array[array.count - 1];
    uint32_t minBlockNo = minBlock.blockNo;
    for (BTBlock *block in array) {
        if (block.blockNo < minBlockNo) {
            minBlockNo = block.blockNo;
        }
        dictionary[@(block.blockNo)] = block;
    };
    NSMutableArray *txs = [NSMutableArray new];
    for (NSArray *each in dict[@"tx"]) {
        BTTx *tx = [[BTTx alloc] initWithMessage:[NSData dataFromBase64String:each[1]]];
        tx.blockNo = (uint32_t) [each[0] intValue];
        BTBlock *block;
        if (tx.blockNo < minBlockNo) {
            block = dictionary[@(minBlockNo)];
        } else {
            block = dictionary[@(tx.blockNo)];
        }

        [tx setTxTime:block.blockTime];
        [txs addObject:tx];
    }
    return txs;
}

+ (NSString *)getCompleteTxForError:(NSError *)error {
    NSString *msg = @"";
    switch (error.code) {
        case ERR_TX_DUST_OUT_CODE:
            msg = NSLocalizedString(@"Send failed. Sending coins this few will be igored.", nil);
            break;
        case ERR_TX_NOT_ENOUGH_MONEY_CODE:
            msg = [NSString stringWithFormat:NSLocalizedString(@"Send failed. Lack of %@ %@.", nil), [UnitUtil stringForAmount:[error.userInfo getLongLongFromDict:ERR_TX_NOT_ENOUGH_MONEY_LACK]], [UnitUtil unitName]];
            break;
        case ERR_TX_WAIT_CONFIRM_CODE:
            msg = [NSString stringWithFormat:NSLocalizedString(@"%@ %@ to be confirmed.", nil), [UnitUtil stringForAmount:[error.userInfo getLongLongFromDict:ERR_TX_WAIT_CONFIRM_AMOUNT]], [UnitUtil unitName]];
            break;
        case ERR_TX_CAN_NOT_CALCULATE_CODE:
            msg = NSLocalizedString(@"Send failed. You don\'t have enough coins available.", nil);
            break;
        case ERR_TX_MAX_SIZE_CODE:
            msg = NSLocalizedString(@"Send failed. Transaction size is to large.", nil);
            break;
        default:
            break;
    }
    return msg;
}

+ (void)completeInputsForAddressForApi:(BTAddress *)address fromBlock:(uint32_t)fromBlock callback:(VoidBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    if (fromBlock <= 0) {
        if (callback) {
            callback();
        }
        return;
    }
    [[BitherApi instance] getInSignaturesApi:address.address fromBlock:fromBlock callback:^(id response) {
        NSArray *ins = [TransactionsUtil getInSignature:response];
        [address completeInSignature:ins];
        uint32_t newFromBlock = [address needCompleteInSignature];
        if (newFromBlock <= 0) {
            if (callback) {
                callback();
            }
        } else {
            [TransactionsUtil completeInputsForAddressForApi:address fromBlock:newFromBlock callback:callback andErrorCallBack:errorCallback];
        }

    }                       andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
        if (errorCallback) {
            errorCallback(errorOp, error);
        }

    }];

}

+ (NSArray *)getInSignature:(NSString *)result {
    NSMutableArray *resultList = [NSMutableArray new];
    if (![StringUtil isEmpty:result]) {
        NSArray *txs = [result componentsSeparatedByString:@";"];
        for (NSString *tx in txs) {
            NSArray *ins = [tx componentsSeparatedByString:@":"];
            NSString *inStr = ins[0];
            NSData *txHash = [[StringUtil getUrlSaleBase64:inStr] reverse];
            for (int i = 1; i < ins.count; i++) {
                NSArray *array = [ins[i] componentsSeparatedByString:@","];
                int inSn = [array[0] intValue];
                NSData *inSignature = [StringUtil getUrlSaleBase64:array[1]];
                BTIn *btIn = [[BTIn alloc] init];
                [btIn setTxHash:txHash];
                btIn.inSn = inSn;
                [btIn setInSignature:inSignature];
                [resultList addObject:btIn];

            }
        }
    }
    return resultList;

}
@end
