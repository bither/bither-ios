//
//  AddressTypeUtil.h
//  bither-ios
//
//  Created by 韩珍 on 2018/9/18.
//  Copyright © 2018年 Bither. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTHDAccountAddress.h"

typedef enum {
    NormalAddrType = 0, MultisigAddrType = 1, P2SHP2WPKHAddrType = 2
} AddrType;

@interface AddressTypeUtil : NSObject

+ (NSString *)getAddressName:(AddrType)addressType;

+ (NSString *)getAddressTypeName:(AddrType)addressType;

+ (NSString *)getSwitchAddressTypeName:(AddrType)addressType;

+ (NSString *)getSwitchAddressTypeTips:(AddrType)addressType;

+ (BOOL)isSegwitAddressType;

+ (AddrType)getSwitchAddressType:(BOOL)isSegwit;

+ (AddrType)getCurrentAddressType;

+ (PathType)getCurrentAddressExternalPathType;

+ (PathType)getAddressExternalPathType:(BOOL)isSegwit;

+ (PathType)getCurrentAddressInternalPathType;

+ (PathType)getAddressInternalPathType:(BOOL)isSegwit;

@end
