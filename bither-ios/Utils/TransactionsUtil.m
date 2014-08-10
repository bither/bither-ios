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

#import "TransactionsUtil.h"
#import "BTTx.h"
#import "NSDictionary+Fromat.h"
#import "NSString+Base58.h"
#import "NSData+Hash.h"
#import "BTAddress.h"
#import "DateUtil.h"
#import "BitherApi.h"
#import "StringUtil.h"
#import "NSDictionary+Fromat.h"


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
+(void)checkAddress:(NSArray *) addressList callback:(IdResponseBlock)callback andErrorCallback:(ErrorBlock)errorBlcok{
    NSInteger index=0;
    [self getAddressState:addressList index:index callback:callback andErrorCallback:errorBlcok];
}
+(void)getAddressState:(NSArray *)addressList index:(NSInteger) index callback:(IdResponseBlock)callback andErrorCallback:(ErrorBlock)errorBlcok{
    if (index==addressList.count) {
        if (callback) {
            callback([NSNumber numberWithInt:AddressNormal]);
        }
    }else{
        NSString * address=[addressList objectAtIndex:index];
        index++;
        [[BitherApi instance]getMyTransactionApi:address  callback:^(NSDictionary *dict) {
            if ([[dict allKeys] containsObject:SPECIAL_TYPE]) {
                NSInteger specialType=[dict getIntFromDict:SPECIAL_TYPE];
                if (specialType==0) {
                    if (callback) {
                        callback([NSNumber numberWithInt:AddressSpecialAddress]);
                    }
                }else{
                    if (callback) {
                        callback([NSNumber numberWithInt:AddressTxTooMuch]);
                    }
                }
            }else{
                [self getAddressState:addressList index:index callback:callback andErrorCallback:errorBlcok];
            }
        } andErrorCallBack:^(MKNetworkOperation *errorOp, NSError *error) {
            if (errorBlcok) {
                errorBlcok(error);
            }
        }];
    }

}

+(NSArray *)getTransactions:(NSDictionary *) dict storeBlockHeight:(uint32_t) storeBlockHeigth{
    NSMutableArray *array=[NSMutableArray new];
    if ([[dict allKeys ] containsObject:TXS]) {
        NSArray * txs=[dict objectForKey:TXS];
        for(NSDictionary * txDict in  txs){
            BTTx * tx =[[BTTx alloc] init];
            //  NSData * blockHashData=[[[txDict getStringFromDict:BLOCK_HASH] hexToData] reverse];
            NSData *txHash=[[txDict getStringFromDict:TX_HASH] hexToData].reverse;
            uint32_t blockNo=[txDict getIntFromDict:BLOCK_NO];
            
            if (storeBlockHeigth>0&&blockNo>storeBlockHeigth) {
                continue;
            }
            int version=[txDict getIntFromDict:TX_VER andDefault:1];
            NSString * timeStr=[txDict getStringFromDict:TX_TIME];
            uint32_t time =[[DateUtil getDateFormStringWithTimeZone:timeStr] timeIntervalSince1970];
            [tx setTxHash:txHash];
            [tx setVersion:version];
            [tx setBlockHeight:blockNo];
            [tx setTxTime:time];
            if ([[txDict allKeys] containsObject:TX_OUT]) {
                NSArray * outArray=[txDict objectForKey:TX_OUT];
                for (NSDictionary * outDict in outArray) {
                    uint64_t value=[outDict getLongLongFromDict:VALUE];
                    //  NSString * address=[outDict getStringFromDict:TX_OUT_ADDRESS];
                    NSString * pubKey=[outDict getStringFromDict:SCRIPT_PUB_KEY];
                    [tx addOutputScript:[pubKey hexToData] amount:value];
                }
                
            }
            if ([[txDict allKeys] containsObject:TX_IN]) {
                NSArray * inArray=[txDict objectForKey:TX_IN];
                for( NSDictionary * inDict in inArray){
                    if ([[inDict allKeys] containsObject:TX_COINBASE]) {
                        int index=[inDict getIntFromDict:TX_SEQUENCE];
                        [tx addInputHash:@"".hexToData index:index script:nil];
                    }else{
                        NSData * prevOutHash=[[inDict getStringFromDict:PREV_TX_HASH] hexToData].reverse;
                        int index=[inDict getIntFromDict:PREV_OUTPUT_SN];
                        [tx addInputHash:prevOutHash index:index script:nil];
                    }
                    
                }
                
            }
            for(BTTx * temp in array){
                if (temp.blockHeight==tx.blockHeight) {
                    if ([[temp inputHashes] containsObject:tx.txHash]) {
                        [tx setTxTime:temp.txTime-1];
                    }else if([[tx inputHashes]containsObject:temp.txHash]){
                        [tx setTxTime:temp.txTime+1];
                    }
                }
            }
            [array addObject:tx];
            
        }
    }
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 blockHeight] > [obj2 blockHeight]) return NSOrderedDescending;
        if ([obj1 blockHeight] < [obj2 blockHeight]) return NSOrderedAscending;
        if ([obj1 txTime] >[obj2 txTime]) return NSOrderedDescending;
        if ([obj1 txTime] <[obj2 txTime]) return NSOrderedAscending;
        NSLog(@"NSOrderedSame");
        return NSOrderedSame;
    }];
    return array;
}

+(NSString *)getCompleteTxForError:(NSError *) error{
    NSString * msg=@"";
    switch (error.code) {
        case ERR_TX_DUST_OUT_CODE:
            msg=NSLocalizedString(@"Send failed. Sending coins this few will be igored.", nil);

            break;
        case ERR_TX_NOT_ENOUGH_MONEY_CODE:
             msg= [NSString stringWithFormat: NSLocalizedString(@"Send failed. Lack of %@ BTC.", nil),[StringUtil stringForAmount:[error.userInfo getLongLongFromDict:ERR_TX_NOT_ENOUGH_MONEY_LACK]]];
            break;
        
        case ERR_TX_WAIT_CONFIRM_CODE:
            msg=[NSString stringWithFormat:NSLocalizedString(@"%@ BTC to be confirmed.", nil),[StringUtil stringForAmount:[error.userInfo getLongLongFromDict:ERR_TX_WAIT_CONFIRM_AMOUNT]]];
            break;
        
        case ERR_TX_CAN_NOT_CALCULATE_CODE:
             msg=NSLocalizedString(@"Send failed. You don\'t have enough coins available.", nil);
            break;
            
        default:
            break;
    }
    return  msg;

}
@end
