//
//  SendUtil.h
//  bither-ios
//
//  Created by 韩珍 on 2020/1/14.
//  Copyright © 2020 Bither. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SendUtil : NSObject

+ (NSString *)isCanSend:(BOOL)isSyncComplete;

@end

NS_ASSUME_NONNULL_END
