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
#import "NetworkUtil.h"
#import "UserDefaultsUtil.h"


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


-(void)startPeer{
    if ([[BTSettings instance] getAppMode]!=COLD) {
    
        if ([[BlockUtil instance] syncSpvFinish]) {
            if ([[BTPeerManager instance] doneSyncFromSPV]) {
                [self syncSpvFromBitcoinDone];
            }else{
                BOOL networkIsAvailable=![[UserDefaultsUtil instance] getSyncBlockOnlyWifi]||[NetworkUtil isEnableWIFI];
                if (networkIsAvailable) {
                    if (![[BTPeerManager instance] connected]) {
                        [[BTPeerManager instance] start];
                    }
                }else{
                    [self stopPeer];
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
    if ([[BTPeerManager instance] connected]) {
        [[BTPeerManager instance] stop];
    }
    if (!isRunning) {
        isRunning=YES;
        [TransactionsUtil syncWallet:^{
            [self connectPeer];
            isRunning=NO;
        } andErrorCallBack:^(MKNetworkOperation *errorOp, NSError *error) {
            isRunning=NO;
        }];
    }
}

-(void) connectPeer{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
       
        BOOL downloadSpvFinish=[[UserDefaultsUtil instance ] getDownloadSpvFinish]&&[[BTPeerManager instance] doneSyncFromSPV];
        BOOL walletIsSyncComplete=[[BTAddressManager instance] allSyncComplete];
       // BOOL netWorkState=[NetworkUtil isEnableWIFI]||![[UserDefaultsUtil instance] getSyncBlockOnlyWifi];
        BTPeerManager * peerManager=[BTPeerManager instance];
        if (downloadSpvFinish && walletIsSyncComplete ) {
            if (![peerManager connected]) {
                [peerManager start];
            }
            
        }else{
            if ([peerManager connected]) {
                [peerManager stop];
            }
        }
        
    });
    
}


-(void)stopPeer{
    [[BTPeerManager instance] stop];
}




@end
