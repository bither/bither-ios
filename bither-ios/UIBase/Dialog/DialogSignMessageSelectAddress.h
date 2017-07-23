//
//  DialogSignMessageSelectAddress.h
//  bither-ios
//
//  Created by 宋辰文 on 14/12/26.
//  Copyright (c) 2014年 宋辰文. All rights reserved.
//

#import "DialogCentered.h"
#import "BTAddressManager.h"

typedef enum {
    HDExternal = 0, HDInternal = 1, Private = 2
} SignAddressType;

@protocol DialogSignMessageSelectAddressDelegate

- (void)signMessageWithSignAddressType:(SignAddressType)signAddressType;

@end

@interface DialogSignMessageSelectAddress : DialogCentered

- (instancetype)initWithDelegate:(NSObject <DialogSignMessageSelectAddressDelegate> *)delegate;

@property(weak) NSObject <DialogSignMessageSelectAddressDelegate> *delegate;

@end
