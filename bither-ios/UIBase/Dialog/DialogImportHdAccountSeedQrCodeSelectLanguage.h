//
//  DialogImportHdAccountSeedQrCodeSelectLanguage.h
//  bither-ios
//
//  Created by 韩珍珍 on 2022/9/26.
//  Copyright © 2022 Bither. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DialogCentered.h"

@protocol DialogImportHdAccountSeedQrCodeSelectLanguageDelegate

- (void)selectLanguage:(NSString *)hdWordList;

@end

@interface DialogImportHdAccountSeedQrCodeSelectLanguage : DialogCentered

- (instancetype)initWithDelegate:(NSObject <DialogImportHdAccountSeedQrCodeSelectLanguageDelegate> *)delegate;

@property(weak) NSObject <DialogImportHdAccountSeedQrCodeSelectLanguageDelegate> *delegate;

@end
