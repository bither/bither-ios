//
//  DetectBccSelecctAddress.h
//  bither-ios
//
//  Created by LTQ on 2017/9/28.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "DialogCentered.h"

typedef enum {
    HDExternal = 0, HDInternal = 1
} BccAddressType;

@protocol DialogDetectBccSelectAddressDelegate

- (void) detectBccWithAddressType:(BccAddressType) bccAddressType;

@end

@interface DialogDetectBccSelecctAddress : DialogCentered
- (instancetype)initWithDelegate:(NSObject <DialogDetectBccSelectAddressDelegate> *)delegate;

@property(weak) NSObject <DialogDetectBccSelectAddressDelegate> *delegate;
@end
