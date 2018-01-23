//  BlockUtil.m
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


#import "BlockUtil.h"
#import "NSDictionary+Fromat.h"
#import "BTBlockChain.h"
#import "BitherSetting.h"
#import "BitherApi.h"
#import "BTPeerManager.h"


#define VER  @"ver"
#define PREV_BLOCK  @"prev_block"
#define MRKL_ROOT  @"mrkl_root"
#define TIME  @"time"
#define BITS  @"bits"
#define NONCE  @"nonce"
#define BLOCK_NO  @"block_no"
#define HEIGHT @"height"
@interface BlockUtil ()

@property(nonatomic, strong) BTBlockChain *blockChain;

@end

@implementation BlockUtil

static BlockUtil *blockUtil;

+ (BlockUtil *)instance {
    @synchronized (self) {
        if (blockUtil == nil) {
            blockUtil = [[self alloc] init];

        }
    }
    return blockUtil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.blockChain = [BTBlockChain instance];
    }
    return self;
}

+ (BTBlock *)formatBlcok:(NSDictionary *)dict {
    uint32_t ver = [dict getIntFromDict:VER andDefault:1];
    NSData *pevBlock = [[[dict getStringFromDict:PREV_BLOCK] hexToData] reverse];
    NSLog(@"pevBlock : %s", [[NSString hexWithData:pevBlock] UTF8String]);
    NSData *mrklRoot = [[[dict getStringFromDict:MRKL_ROOT] hexToData] reverse];
    NSLog(@"mrklRoot : %s", [[NSString hexWithData:mrklRoot] UTF8String]);
    uint32_t time = [dict getIntFromDict:TIME];
    uint32_t bits = [dict getIntFromDict:BITS];
    uint32_t nonce = [dict getIntFromDict:NONCE];
    int blockNo = [dict getIntFromDict:BLOCK_NO];
    BTBlock *block = [[BTBlock alloc] initWithVersion:ver prevBlock:pevBlock merkleRoot:mrklRoot timestamp:time target:bits nonce:nonce height:blockNo];
    return block;

}

+ (BTBlock *)formatBlcokChainBlock:(NSDictionary *)dict {
    uint32_t ver = [dict getIntFromDict:VER andDefault:1];
    NSData *pevBlock = [[[dict getStringFromDict:PREV_BLOCK] hexToData] reverse];
    NSLog(@"pevBlock : %s", [[NSString hexWithData:pevBlock] UTF8String]);
    NSData *mrklRoot = [[[dict getStringFromDict:MRKL_ROOT] hexToData] reverse];
    NSLog(@"mrklRoot : %s", [[NSString hexWithData:mrklRoot] UTF8String]);
    uint32_t time = [dict getIntFromDict:TIME];
    uint32_t bits = [dict getIntFromDict:BITS];
    uint32_t nonce = [dict getIntFromDict:NONCE];
    int blockNo = [dict getIntFromDict:HEIGHT];
    BTBlock *block = [[BTBlock alloc] initWithVersion:ver prevBlock:pevBlock merkleRoot:mrklRoot timestamp:time target:bits nonce:nonce height:blockNo];
    return block;
}

- (void)syncSpvBlock {
    [self dowloadSpvBlock:^{
        if ([[BTPeerManager instance] doneSyncFromSPV]) {
            if ([self.delegate respondsToSelector:@selector(success)]) {
                [self.delegate success];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(success)]) {
                [self.delegate success];
            }
        }
    }];

}

- (void)dowloadSpvBlock:(VoidBlock)callback {
    if ([[UserDefaultsUtil instance] getDownloadSpvFinish]) {
        if (callback) {
            callback();
        }
    } else {
        [[BitherApi instance] getSpvBlock:^(NSDictionary *dict) {
            BTBlock *block = [BlockUtil formatBlcok:dict];
            if (block.blockNo % 2016 != 0) {
                if ([self.delegate respondsToSelector:@selector(error)]) {
                    [self.delegate error];
                }
            } else {
                [[UserDefaultsUtil instance] setDownloadSpvFinish:true];
                [self.blockChain addSPVBlock:block];
                if (callback) {
                    callback();
                }
            }
        } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
            [[BitherApi instance] getSpvBlockByBlockChain:^(NSDictionary *dict) {
                BTBlock *block = [BlockUtil formatBlcokChainBlock:dict];
                if (block.blockNo % 2016 != 0) {
                    if ([self.delegate respondsToSelector:@selector(error)]) {
                        [self.delegate error];
                    }
                } else {
                    [[UserDefaultsUtil instance] setDownloadSpvFinish:true];
                    [self.blockChain addSPVBlock:block];
                    if (callback) {
                        callback();
                    }
                }
            } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
                if ([self.delegate respondsToSelector:@selector(error)]) {
                    [self.delegate error];
                }
            }];
        }];
    }

}

- (BOOL)syncSpvFinish {
    return [[UserDefaultsUtil instance] getDownloadSpvFinish];
}


@end
