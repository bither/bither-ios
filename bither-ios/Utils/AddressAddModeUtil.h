//
//  AddressAddModeUtil.h
//  bither-ios
//
//  Created by 韩珍珍 on 2022/9/9.
//  Copyright © 2022 Bither. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddressAddModeUtil : NSObject

+ (NSString *)getImgRes:(AddressAddMode)addMode isFromXRandom:(BOOL)isFromXRandom isNormal:(BOOL)isNormal;

+ (NSString *)getDes:(AddressAddMode)addMode isFromXRandom:(BOOL)isFromXRandom;

@end

NS_ASSUME_NONNULL_END
