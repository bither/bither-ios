//
//  DialogHDMServerUnsignedQRCode.h
//  bither-ios
//
//  Created by 宋辰文 on 15/2/2.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import "DialogBlackQrCode.h"

@interface DialogHDMServerUnsignedQRCode : DialogBlackQrCode
- (instancetype)initWithContent:(NSString *)content andAction:(void (^)())block;

- (instancetype)initWithContent:(NSString *)content action:(void (^)())block andCancel:(void (^)())cancel;
@end
