//
//  PeerUtil.m
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

#import "PeerUtil.h"
#import "TransactionsUtil.h"
#import "BTAddressManager.h"
#import "BitherApi.h"
#import "BTBlockChain.h"
#import "BTPeerManager.h"
#import "BlockUtil.h"
#import "NetworkUtil.h"
#import "NSDictionary+Fromat.h"

#define BLOCK_COUNT  @"block_count"

static BOOL isRunning=NO;
static BOOL addObserver=NO;
static PeerUtil * peerUtil;

@implementation PeerUtil

+ (PeerUtil *)instance {
    @synchronized(self) {
        if (peerUtil == nil) {
            peerUtil = [[self alloc] init];
        }
    }
    return peerUtil;
}


-(void) syncWallet:(VoidBlock) voidBlock andErrorCallBack:(ErrorHandler)errorCallback{
    NSArray * addresses=[[BTAddressManager sharedInstance] allAddresses];
    if (addresses.count==0) {
        errorCallback(nil,nil);
        return;
    }
    if ([[BTAddressManager sharedInstance] allSyncComplete]) {
        if (voidBlock) {
            voidBlock();
        }
        return;
    }
    __block  NSInteger index=0;
    addresses=[addresses reverseObjectEnumerator].allObjects;
    [self getMyTx:addresses index:index callback:^{
        if (voidBlock) {
            voidBlock();
        }
    } andErrorCallBack:errorCallback];
    
}

-(void)getMyTx:(NSArray *)addresses  index:(NSInteger)index  callback:(VoidBlock)callback andErrorCallBack:(ErrorHandler)errorCallback{
    BTAddress * address=[addresses objectAtIndex:index];
    index=index+1;
    if (address.isSyncComplete) {
        if (index==addresses.count) {
            if (callback) {
                callback();
            }
        }else{
            [self getMyTx:addresses index:index callback:callback andErrorCallBack:errorCallback];
        }
    }else{
        uint32_t storeHeight=[[BTBlockChain instance] lastBlock].height;
        [[BitherApi instance] getMyTransactionApi:address.address callback:^(NSDictionary * dict) {
            NSArray *txs=[TransactionsUtil getTransactions:dict storeBlockHeight:storeHeight];
            uint32_t apiBlockCount=[dict getIntFromDict:BLOCK_COUNT];
            [address initTxs:txs];
            [address setIsSyncComplete:YES];
            [[BTAddressManager sharedInstance] updateAddressWithSyncTx:address];
            //TODO 100?
            if (apiBlockCount<storeHeight&&storeHeight-apiBlockCount<100) {
                [[BTBlockChain instance] rollbackBlock:apiBlockCount];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:BitherAddressNotification object:address.address];
            });
            if (index==addresses.count) {
                if (callback) {
                    callback();
                }
            }else{
                [self getMyTx:addresses index:index callback:callback andErrorCallBack:errorCallback];
            }
        } andErrorCallBack:^(MKNetworkOperation *errorOp, NSError *error) {
            NSLog(@"get my transcation api %@",errorOp.responseString);
            isRunning=NO;
        }];
    }
    
}

-(void)startPeer{
    if ([[BTSettings instance] getAppMode]!=COLD) {
        
        if ([[BlockUtil instance] syncSpvFinish]) {
            if ([[BTPeerManager sharedInstance] doneSyncFromSPV]) {
                [self syncSpvFromBitcoinDone];
            }else{
                if (![[BTPeerManager sharedInstance] connected]) {
                    [[BTPeerManager sharedInstance] connect];
                }
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncSpvFromBitcoinDone) name:BTPeerManagerSyncFromSPVFinishedNotification object:nil];
                addObserver=YES;
            }
            
        }else{
            [[BlockUtil instance] syncSpvBlock];
        }
    }
}
-(void) syncSpvFromBitcoinDone{
    if (addObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:BTPeerManagerSyncFromSPVFinishedNotification object:nil];
    }
    if ([[BTPeerManager sharedInstance] connected]) {
        [[BTPeerManager sharedInstance] disconnect];
    }
    if (!isRunning) {
        isRunning=YES;
        [self syncWallet:^{
            [self connectPeer];
        } andErrorCallBack:^(MKNetworkOperation *errorOp, NSError *error) {
            isRunning=NO;
        }];
    }
}

-(void) connectPeer{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
        BOOL hasAddress=[[BTAddressManager sharedInstance] allAddresses].count>0;
        BOOL downloadSpvFinish=[[UserDefaultsUtil instance ] getDownloadSpvFinish]&&[[BTPeerManager sharedInstance] doneSyncFromSPV];
        BOOL walletIsSyncComplete=[[BTAddressManager sharedInstance] allSyncComplete];
       // BOOL netWorkState=[NetworkUtil isEnableWIFI]||![[UserDefaultsUtil instance] getSyncBlockOnlyWifi];
        BTPeerManager * peerManager=[BTPeerManager sharedInstance];
        if (downloadSpvFinish && walletIsSyncComplete && hasAddress) {
            if (![peerManager connected]) {
                [peerManager connect];
            }
            
        }else{
            if ([peerManager connected]) {
                [peerManager disconnect];
            }
        }
        isRunning=NO;
    });
    
}





@end
