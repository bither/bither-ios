//
//  AddressAddModeUtil.m
//  bither-ios
//
//  Created by 韩珍珍 on 2022/9/9.
//  Copyright © 2022 Bither. All rights reserved.
//

#import "AddressAddModeUtil.h"

@implementation AddressAddModeUtil

+ (NSString *)getImgRes:(AddressAddMode)addMode isFromXRandom:(BOOL)isFromXRandom isNormal:(BOOL)isNormal {
    switch (addMode) {
        case Create:
        case DiceCreate:
        case BinaryCreate:
            return isNormal ? @"address_add_mode_bither_create" : @"address_add_mode_bither_create_press";
        case Import:
            return isNormal ? @"address_add_mode_import" : @"address_add_mode_import_press";
        case Clone:
            return isNormal ? @"address_add_mode_clone" : @"address_add_mode_clone_press";
        default:
            if (isFromXRandom) {
                return isNormal ? @"address_add_mode_bither_create" : @"address_add_mode_bither_create_press";
            } else {
                return isNormal ? @"address_add_mode_other" : @"address_add_mode_other_press";
            }
    }
}

+ (NSString *)getDes:(AddressAddMode)addMode isFromXRandom:(BOOL)isFromXRandom {
    switch (addMode) {
        case Create:
            return NSLocalizedString(@"address_add_mode_create_des", nil);
        case DiceCreate:
            return NSLocalizedString(@"address_add_mode_dice_create_des", nil);
        case BinaryCreate:
            return NSLocalizedString(@"address_add_mode_binary_create_des", nil);
        case Import:
            return NSLocalizedString(@"address_add_mode_import_des", nil);
        case Clone:
            return NSLocalizedString(@"address_add_mode_clone_des", nil);
        default:
            if (isFromXRandom) {
                return NSLocalizedString(@"address_add_mode_create_des", nil);
            } else {
                return NSLocalizedString(@"address_add_mode_other_des", nil);
            }
    }
}

@end
