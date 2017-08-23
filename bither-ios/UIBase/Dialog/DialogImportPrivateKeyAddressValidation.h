//
//  DialogImportPrivateKeyAddressValidation.h
//  bither-ios
//
//  Created by 韩珍 on 2017/8/14.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "DialogCentered.h"
#import "BTKey.h"

typedef void (^OnImportEntered)(BTKey *key);

@interface DialogImportPrivateKeyAddressValidation : DialogCentered

- (instancetype)initWithCompressedKey:(BTKey *)compressedKey uncompressedKey:(BTKey *)uncompressedKey isCompressedKeyRecommended:(BOOL)isCompressedKeyRecommended onImportEntered:(OnImportEntered)onImportEntered;

@end
