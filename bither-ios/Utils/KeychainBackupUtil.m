//
//  KeychainBackupUtil.m
//  bither-ios
//
//  Created by ZhouQi on 14/11/22.
//  Copyright (c) 2014年 ZhouQi. All rights reserved.
//

#import "KeychainBackupUtil.h"
#import "UserDefaultsUtil.h"
#import <SimpleKeychain/A0SimpleKeychain.h>
#import "BTAddressManager.h"

#define KEYCHAIN_KEY @"key"
#define KEYCHAIN_TRASH @"trash"

@interface KeychainBackupUtil()

@property (nonatomic, strong) NSArray *localKeys;
@property (nonatomic, strong) NSArray *localTrashs;
@property (nonatomic, strong) NSArray *keychainKeys;
@property (nonatomic, strong) NSArray *keychainTrashes;

@end

@implementation KeychainBackupUtil

- (void)updateLocal; {
    self.localKeys = [self getLocalKeys];
    self.localTrashs = [self getLocalTrashes];
}

- (void)updateKeychain; {
    self.keychainKeys = [self getKeychainKeys];
    self.keychainTrashes = [self getKeychainTrashes];
}

- (NSArray *)checkWithKeychain; {
    NSString *key = [[A0SimpleKeychain keychain] stringForKey:KEYCHAIN_KEY];
    NSString *pub = [[A0SimpleKeychain keychain] stringForKey:KEYCHAIN_TRASH];
//    NSString *content = [NSString stringWithFormat:@"%@:%@:%lld%@", [NSString hexWithData:self.pubKey], [self getSyncCompleteString],self.sortTime,[self getXRandomString]];
//    NSString *privateKeyFullFileName = [NSString stringWithFormat:PRIVATE_KEY_FILE_NAME, [BTUtils getPrivDir], self.address];
    return nil;
}

- (NSArray *)getLocalKeys; {
    NSMutableArray *keys = [NSMutableArray new];
    for (BTAddress *address in [BTAddressManager instance].privKeyAddresses) {
        [keys addObject:[NSString stringWithFormat:@"%@/%@", [NSString hexWithData:address.pubKey], address.encryptPrivKey]];
    }
    return keys;
}

- (NSArray *)getLocalTrashes; {
    NSMutableArray *trashes = [NSMutableArray new];
    for (BTAddress *address in [BTAddressManager instance].trashAddresses) {
        [trashes addObject:[NSString hexWithData:address.pubKey]];
    }
    return trashes;
}

- (NSArray *)getKeychainKeys; {
    NSString *key = [[A0SimpleKeychain keychain] stringForKey:KEYCHAIN_KEY];
    if (key != nil) {
        return [key componentsSeparatedByString:@";"];
    } else {
        return [NSArray array];
    }
}

- (NSArray *)getKeychainTrashes; {
    NSString *pub = [[A0SimpleKeychain keychain] stringForKey:KEYCHAIN_TRASH];
    if (pub != nil) {
        return [pub componentsSeparatedByString:@";"];
    } else {
        return [NSArray array];
    }
}

- (BOOL)isKeysSame; {
    if (self.localKeys.count != self.keychainKeys.count) {
        return NO;
    }
    for (NSString *key in self.localKeys) {
        if (![self.keychainKeys containsObject:key]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)existKeySame; {
    for (NSString *key in self.localKeys) {
        if ([self.keychainKeys containsObject:key]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)keysDiff; {
    NSMutableArray *diff = [NSMutableArray new];
    NSMutableArray *localPubKeys = [NSMutableArray new];
    for (NSString *key in self.localKeys) {
        [localPubKeys addObject:[key componentsSeparatedByString:@"/"][0]];
    }
    NSMutableArray *keychainPubKeys = [NSMutableArray new];
    for (NSString *key in keychainPubKeys) {
        [keychainPubKeys addObject:[key componentsSeparatedByString:@"/"][0]];
    }
    for (NSString *pubKey in keychainPubKeys) {
        if (![localPubKeys containsObject:pubKey]) {
            [diff addObject:@[pubKey, @(AddFromKeychain)]];
        }
    }
    for (NSString *pubKey in localPubKeys) {
        if (![keychainPubKeys containsObject:pubKey]) {
            [diff addObject:@[pubKey, @(AddFromLocal)]];
        }
    }
    return diff;
}

- (BOOL)isTrashesSame; {
    if (self.localTrashs.count != self.keychainTrashes.count) {
        return NO;
    }
    for (NSString *pubKey in self.localTrashs) {
        if (![self.keychainTrashes containsObject:pubKey]) {
            return NO;
        }
    }
    return YES;
}

- (NSArray *)trashesDiff; {
    NSMutableArray *diff = [NSMutableArray new];
    for (NSString *pubKey in self.keychainTrashes) {
        if (![self.localTrashs containsObject:pubKey]) {
            [diff addObject:@[pubKey, @(TrashFromKeychain)]];
        }
    }
    for (NSString *pubKey in self.localTrashs) {
        if (![self.keychainTrashes containsObject:pubKey]) {
            [diff addObject:@[pubKey, @(TrashFromLocal)]];
        }
    }
    return diff;
}

- (BOOL)syncWithKeychain:(NSArray *) changes; {
    NSString *jwt = @"";
    [[A0SimpleKeychain keychain] setString:jwt forKey:@""];
    return YES;
}

- (BOOL)canSync; {
    if ([[UserDefaultsUtil instance] getKeychainMode] == Off) {
        return YES;
    } else {
        return NO;
    }
}

- (void)syncKeys; {
    // logic
    if ([self isKeysSame]) {
        return;
    } else if ([self existKeySame]) {
        // the password is the same
        // stop peer manager
//        BTAddress *address = [BTAddress alloc] initWithAddress:<#(NSString *)#> pubKey:<#(NSData *)#> hasPrivKey:<#(BOOL)#> isXRandom:<#(BOOL)#>
//        [BTAddressManager instance] addAddress:<#(BTAddress *)#>
    } else {
        // get the two password
        
    }
}

//- (NSArray *)getPrivAddressesFromKeychain;
//- (NSArray *)getTrashAddressesFromKeychain;
//
//- (void)storeToKeychainWithPrivAddresses:(NSArray *) privAddresses andTrashAddresses:(NSArray *) trashAddresses;


@end
