//
//  BlockchairUnspentTxsApi.h
//  bither-ios
//
//  Created by 韩珍 on 2020/6/19.
//  Copyright © 2020 Bither. All rights reserved.
//

#import "BlockchairQueryApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface BlockchairUnspentTxsApi : BlockchairQueryApi

+ (BlockchairUnspentTxsApi *)instance;

- (void)queryUnspentTxs:(NSString *)txHashs callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

@end

NS_ASSUME_NONNULL_END
