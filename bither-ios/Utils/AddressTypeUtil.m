//
//  AddressTypeUtil.m
//  bither-ios
//
//  Created by 韩珍 on 2018/9/18.
//  Copyright © 2018年 Bither. All rights reserved.
//

#import "AddressTypeUtil.h"
#import "UserDefaultsUtil.h"

@implementation AddressTypeUtil

+ (NSString *)getAddressName:(AddrType)addressType {
    NSString *key;
    switch (addressType) {
        case MultisigAddrType:
            key = @"address_multisig";
            break;
        case P2SHP2WPKHAddrType:
            key = @"address_segwit";
            break;
        default:
            key = @"address_normal";
            break;
    }
    return NSLocalizedString(key, nil);
}

+ (NSString *)getAddressTypeName:(AddrType)addressType {
    NSString *key;
    switch (addressType) {
        case MultisigAddrType:
            key = @"address_multisig_type";
            break;
        case P2SHP2WPKHAddrType:
            key = @"address_segwit_type";
            break;
        default:
            key = @"address_normal_type";
            break;
    }
    return NSLocalizedString(key, nil);
}

+ (NSString *)getSwitchAddressTypeName:(AddrType)addressType {
    NSString *key;
    switch (addressType) {
        case P2SHP2WPKHAddrType:
            key = @"address_type_switch_to_segwit";
            break;
        default:
            key = @"address_type_switch_to_normal";
            break;
    }
    return NSLocalizedString(key, nil);
}

+ (NSString *)getSwitchAddressTypeTips:(AddrType)addressType {
    return [NSString stringWithFormat:NSLocalizedString(@"address_type_switch_tips", nil), [AddressTypeUtil getAddressTypeName:addressType]];
}

+ (BOOL)isSegwitAddressType {
    return [[UserDefaultsUtil instance] isSegwitAddressType];
}

+ (AddrType)getSwitchAddressType:(BOOL)isSegwit {
    if (isSegwit) {
        return NormalAddrType;
    } else {
        return P2SHP2WPKHAddrType;
    }
}

+ (AddrType)getCurrentAddressType {
    return [AddressTypeUtil isSegwitAddressType] ? P2SHP2WPKHAddrType : NormalAddrType;
}

+ (PathType)getCurrentAddressExternalPathType {
    return [AddressTypeUtil getAddressExternalPathType:[AddressTypeUtil isSegwitAddressType]];
}

+ (PathType)getAddressExternalPathType:(BOOL)isSegwit {
    return isSegwit ? EXTERNAL_BIP49_PATH : EXTERNAL_ROOT_PATH;
}

+ (PathType)getCurrentAddressInternalPathType {
    return [AddressTypeUtil getAddressInternalPathType:[AddressTypeUtil isSegwitAddressType]];
}

+ (PathType)getAddressInternalPathType:(BOOL)isSegwit {
    return isSegwit ? INTERNAL_BIP49_PATH : INTERNAL_ROOT_PATH;
}

@end
