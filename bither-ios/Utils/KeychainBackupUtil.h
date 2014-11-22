//
//  KeychainBackupUtil.h
//  bither-ios
//
//  Created by ZhouQi on 14/11/22.
//  Copyright (c) 2014年 ZhouQi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainBackupUtil : NSObject
- (NSArray *)getPrivAddressesFromKeychain;
- (NSArray *)getTrashAddressesFromKeychain;

- (void)storeToKeychainWithPrivAddresses:(NSArray *) privAddresses andTrashAddresses:(NSArray *) trashAddresses;
@end
