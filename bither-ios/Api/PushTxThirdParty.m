//
//  PushTxThirdParty.m
//  bither-ios
//
//  Created by 宋辰文 on 16/5/10.
//  Copyright © 2016年 Bither. All rights reserved.
//

#import "PushTxThirdParty.h"
#import <Bitheri/NSString+Base58.h>
#import "AFHTTPSessionManager.h"

static PushTxThirdParty* instance;

@implementation PushTxThirdParty {
    AFHTTPSessionManager* manager;
}

+(instancetype)instance {
    if(!instance){
        instance = [[PushTxThirdParty alloc]init];
    }
    return instance;
}

-(instancetype)init {
    if (!(self = [super init])) return nil;
    manager = [AFHTTPSessionManager manager];
    return self;
}

-(void)pushTx:(BTTx *)tx {
    NSString* raw = [NSString hexWithData:tx.toData];
    [self pushToChianBtcCom:raw];
    [self pushToBlockChainInfo:raw];
    [self pushToBtcCom:raw];
    [self pushToChainQuery:raw];
    [self pushToBlockr:raw];
    [self pushToBlockExplorer:raw];
}

-(void)pushToUrl:(NSString*)url key:(NSString*)key rawTx:(NSString*)rawTx tag:(NSString*)tag {
    NSLog(@"begin push tx to %@", tag);
    [manager POST:url parameters:@{key: rawTx} headers:NULL progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"push tx to %@ success", tag);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"push tx to %@ failed", tag);
    }];
}

-(void)pushToBlockChainInfo:(NSString *)raw {
    [self pushToUrl:@"https://blockchain.info/pushtx" key:@"tx" rawTx:raw tag:@"blockchain.info"];
}

-(void)pushToBtcCom:(NSString *)raw {
    [self pushToUrl:@"https://btc.com/api/v1/tx/publish" key:@"hex" rawTx:raw tag:@"BTC.com"];
}

-(void)pushToChianBtcCom:(NSString *)raw {
    [self pushToUrl:@"https://chain.api.btc.com/v3/tools/tx-publish" key:@"rawhex" rawTx:raw tag:@"ChianBTC.com"];
}

-(void)pushToChainQuery:(NSString *)raw {
    [self pushToUrl:@"https://chainquery.com/bitcoin-api/sendrawtransaction" key:@"transaction" rawTx:raw tag:@"ChainQuery.com"];
}

-(void)pushToBlockr:(NSString *)raw {
    [self pushToUrl:@"https://blockr.io/api/v1/tx/push" key:@"hex" rawTx:raw tag:@"blockr.io"];
}

-(void)pushToBlockExplorer:(NSString *)raw {
    [self pushToUrl:@"https://blockexplorer.com/api/tx/send" key:@"rawtx" rawTx:raw tag:@"BlockExplorer"];
}

@end
