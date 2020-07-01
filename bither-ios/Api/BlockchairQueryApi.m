//
//  BlockchairQueryApi.m
//  bither-ios
//
//  Created by 韩珍 on 2020/6/18.
//  Copyright © 2020 Bither. All rights reserved.
//

#import "BlockchairQueryApi.h"
#import "StringUtil.h"

@implementation BlockchairQueryApi

- (BOOL)dataIsError:(MKNetworkOperation *)completedOperation {
    if ([StringUtil isEmpty:completedOperation.responseString]) {
        return YES;
    }
    NSDictionary *data = completedOperation.responseJSON;
    if (!data || ![[data allKeys] containsObject:@"context"]) {
        return YES;
    }
    NSDictionary *context = data[@"context"];
    if (!context || ![[context allKeys] containsObject:@"code"]) {
        return YES;
    }
    int code = [context[@"code"] intValue];
    return code != 200;
}

- (void)handleError:(NSError *)error firstEngine:(MKNetworkEngine *)firstEngine requestCount:(int)requestCount retry:(RetryBlock)retry andErrorCallBack:(VoidBlock)errorCallback {
    if (requestCount > kTIMEOUT_REREQUEST_CNT) {
        if ([BitherEngine getNextBlockchairEngineWithFirstBlockchairEngine:firstEngine]) {
            if (retry) {
                retry(1);
            }
        } else{
            if (errorCallback) {
                errorCallback();
            }
        }
    } else {
        [NSThread sleepForTimeInterval:kTIMEOUT_REREQUEST_DELAY * requestCount];
        if (retry) {
            retry(requestCount + 1);
        }
    }
}

@end
