//
//  KeychainBackupUtil.h
//  bither-ios
//
//  Created by ZhouQi on 14/11/22.
//  Copyright (c) 2014年 ZhouQi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    AddFromKeychain = 0, AddFromLocal = 1, TrashFromKeychain = 2, TrashFromLocal = 3
} BackupChangeType;

@interface KeychainBackupUtil : NSObject

+ (instancetype)instance;

- (void)update;
- (NSArray *)checkWithKeychain;
- (BOOL)canSync;
- (BOOL)syncKeysWithoutPassword;
- (BOOL)syncKeysWithKeychainPassword:(NSString *)keychainPassword andLocalPassword:(NSString *)localPassword;

- (BOOL)existKeySame;

@end
