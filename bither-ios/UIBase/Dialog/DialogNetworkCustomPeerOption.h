//
//  DialogNetworkCustomPeerOption.h
//  bither-ios
//
//  Created by 韩珍珍 on 2022/6/2.
//  Copyright © 2022 Bither. All rights reserved.
//

#import "DialogCentered.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DialogNetworkCustomPeerOptionDelegate <NSObject>

- (void)clearPeer;

@end

@interface DialogNetworkCustomPeerOption : DialogCentered

- (instancetype)initWithDelegate:(NSObject <DialogNetworkCustomPeerOptionDelegate> *)delegate;

@property(weak) NSObject <DialogNetworkCustomPeerOptionDelegate> *delegate;

@end

NS_ASSUME_NONNULL_END
