//
//  BlockchairQueryApi.h
//  bither-ios
//
//  Created by 韩珍 on 2020/6/18.
//  Copyright © 2020 Bither. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface BlockchairQueryApi : BaseApi

- (BOOL)dataIsError:(MKNetworkOperation *)completedOperation;

- (void)handleError:(NSError *)error firstEngine:(MKNetworkEngine *)firstEngine requestCount:(int)requestCount retry:(RetryBlock)retry andErrorCallBack:(VoidBlock)errorCallback;

@end

NS_ASSUME_NONNULL_END
