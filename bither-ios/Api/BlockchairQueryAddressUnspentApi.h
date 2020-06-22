//
//  BlockchairQueryAddressUnspentApi.h
//  bither-ios
//
//  Created by 韩珍 on 2020/6/18.
//  Copyright © 2020 Bither. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlockchairQueryApi.h"

#define BLOCKCHAIR_LAST_TX_ADDRESS @"last_tx_address"
#define BLOCKCHAIR_UTXO @"unspent_tx_out"
#define BLOCKCHAIR_HAS_TX_ADDRESSES @"has_tx_addresses"
#define BLOCKCHAIR_HAS_UTXO_ADDRESSES @"has_utxo_addresses"

NS_ASSUME_NONNULL_BEGIN

@interface BlockchairQueryAddressUnspentApi : BlockchairQueryApi

+ (BlockchairQueryAddressUnspentApi *)instance;

- (void)queryAddressUnspent:(NSString *)addressesStr callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

@end

NS_ASSUME_NONNULL_END
