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
#define KEYCHAIN_KEY_SEP @";"
#define KEYCHAIN_KEY_CONTENT_SEP @"/"

@interface KeychainBackupUtil()

@property (nonatomic, strong) NSArray *localKeys;
@property (nonatomic, strong) NSArray *localTrashs;
@property (nonatomic, strong) NSArray *keychainKeys;
@property (nonatomic, strong) NSArray *keychainTrashes;

@end

@implementation KeychainBackupUtil

+ (instancetype)instance; {
    static id singleton = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        singleton = [self new];
    });
    
    return singleton;
}

- (void)update; {
    [self updateLocal];
    [self updateKeychain];
}

- (void)updateLocal; {
    self.localKeys = [self getLocalKeys];
    self.localTrashs = [self getLocalTrashes];
}

- (void)updateKeychain; {
    self.keychainKeys = [self getKeychainKeys];
    self.keychainTrashes = [self getKeychainTrashes];
}

- (NSArray *)checkWithKeychain; {
    NSMutableArray *result = [NSMutableArray new];
    [result addObjectsFromArray:[self keysDiff]];
    [result addObjectsFromArray:[self trashesDiff]];
    return result;
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
        return [key componentsSeparatedByString:KEYCHAIN_KEY_SEP];
    } else {
        return [NSArray array];
    }
}

- (NSArray *)getKeychainTrashes; {
    NSString *pub = [[A0SimpleKeychain keychain] stringForKey:KEYCHAIN_TRASH];
    if (pub != nil) {
        return [pub componentsSeparatedByString:KEYCHAIN_KEY_SEP];
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
        [localPubKeys addObject:[key componentsSeparatedByString:KEYCHAIN_KEY_CONTENT_SEP][0]];
    }
    NSMutableArray *keychainPubKeys = [NSMutableArray new];
    for (NSString *key in keychainPubKeys) {
        [keychainPubKeys addObject:[key componentsSeparatedByString:KEYCHAIN_KEY_CONTENT_SEP][0]];
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

- (BOOL)canSync; {
    if ([[UserDefaultsUtil instance] getKeychainMode] == Off) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)syncKeysWithoutPassword; {
    if ([self isKeysSame]) {
        return YES;
    } else if ([self existKeySame]) {
        // the password is the same
        // stop peer manager
        // add key to local
        NSMutableArray *localPubKeys = [NSMutableArray new];
        for (NSString *key in self.localKeys) {
            [localPubKeys addObject:[key componentsSeparatedByString:KEYCHAIN_KEY_CONTENT_SEP][0]];
        }
        for (NSString *key in self.keychainKeys) {
            NSArray *array = [key componentsSeparatedByString:KEYCHAIN_KEY_CONTENT_SEP];
            if (![localPubKeys containsObject:array[0]]) {
                BTAddress *address = [[BTAddress alloc] initWithWithPubKey:array[0] encryptPrivKey:[[array subarrayWithRange:NSMakeRange(1, 3)] componentsJoinedByString:KEYCHAIN_KEY_CONTENT_SEP]];
                [[BTAddressManager instance] addAddress:address];
            }
        }
        
        // add key to keychain
        NSMutableArray *keychainPubKeys = [NSMutableArray new];
        for (NSString *key in keychainPubKeys) {
            [keychainPubKeys addObject:[key componentsSeparatedByString:KEYCHAIN_KEY_CONTENT_SEP][0]];
        }
        NSMutableArray *allKeys = [NSMutableArray arrayWithArray:self.keychainKeys];
        for (NSString *key in self.localKeys) {
            NSArray *array = [key componentsSeparatedByString:KEYCHAIN_KEY_CONTENT_SEP];
            if (![keychainPubKeys containsObject:array[0]]) {
                [allKeys addObject:key];
            }
        }
        [[A0SimpleKeychain keychain] setString:[allKeys componentsJoinedByString:KEYCHAIN_KEY_SEP] forKey:KEYCHAIN_KEY];
        return YES;
    } else {
        // get the two password
        // check new & old password
        return NO;
    }
}

- (BOOL)syncKeysWithKeychainPassword:(NSString *)keychainPassword andLocalPassword:(NSString *)localPassword; {
    // need check password before call this
    if ([self isKeysSame]) {
        return YES;
    }

    if ([keychainPassword isEqualToString:localPassword]) {
        [self syncKeysWithoutPassword];
    } else {
        // check all keychain password
        for (NSString *key in self.keychainKeys) {
            NSArray *array = [key componentsSeparatedByString:KEYCHAIN_KEY_CONTENT_SEP];
            BTAddress *address = [[BTAddress alloc] initWithWithPubKey:array[0] encryptPrivKey:[[array subarrayWithRange:NSMakeRange(1, 3)] componentsJoinedByString:KEYCHAIN_KEY_CONTENT_SEP]];
            BTPasswordSeed *seed = [[BTPasswordSeed alloc] initWithBTAddress:address];
            if (![seed checkPassword:keychainPassword]) {
                return NO;
            }
        }
        
        NSMutableArray *localPubKeys = [NSMutableArray new];
        for (NSString *key in self.localKeys) {
            [localPubKeys addObject:[key componentsSeparatedByString:KEYCHAIN_KEY_CONTENT_SEP][0]];
        }
        NSMutableArray *needUpdateAddress = [NSMutableArray new];
        NSMutableArray *needAddAddress = [NSMutableArray new];
        for (NSString *key in self.keychainKeys) {
            NSArray *array = [key componentsSeparatedByString:KEYCHAIN_KEY_CONTENT_SEP];
            BTAddress *address = [[BTAddress alloc] initWithWithPubKey:array[0] encryptPrivKey:[[array subarrayWithRange:NSMakeRange(1, 3)] componentsJoinedByString:KEYCHAIN_KEY_CONTENT_SEP]];
            if ([localPubKeys containsObject:array[0]]) {
                [needUpdateAddress addObject:address];
            } else {
                [needAddAddress addObject:address];
            }
        }
        
        // add key to keychain
        NSMutableArray *keychainPubKeys = [NSMutableArray new];
        for (NSString *key in keychainPubKeys) {
            [keychainPubKeys addObject:[key componentsSeparatedByString:KEYCHAIN_KEY_CONTENT_SEP][0]];
        }
        NSMutableArray *allKeys = [NSMutableArray arrayWithArray:self.keychainKeys];
        for (NSString *key in self.localKeys) {
            NSArray *array = [key componentsSeparatedByString:KEYCHAIN_KEY_CONTENT_SEP];
            if (![keychainPubKeys containsObject:array[0]]) {
                BTAddress *address = [[BTAddress alloc] initWithWithPubKey:array[0] encryptPrivKey:[[array subarrayWithRange:NSMakeRange(1, 3)] componentsJoinedByString:KEYCHAIN_KEY_CONTENT_SEP]];
                address.encryptPrivKey = [address reEncryptPrivKeyWithOldPassphrase:localPassword andNewPassphrase:keychainPassword];
                [allKeys addObject:[@[array[0], address.encryptPrivKey] componentsJoinedByString:KEYCHAIN_KEY_CONTENT_SEP]];
                [needUpdateAddress addObject:address];
            }
        }
        
        for (BTAddress *address in needUpdateAddress) {
            [address savePrivate];
        }
        for (BTAddress *address in needAddAddress) {
            [[BTAddressManager instance] addAddress:address];
        }
        if ([BTAddressManager instance].privKeyAddresses.count > 0) {
            [[UserDefaultsUtil instance]setPasswordSeed:[[BTPasswordSeed alloc] initWithBTAddress:[BTAddressManager instance].privKeyAddresses[0]]];
        } else if ([BTAddressManager instance].trashAddresses.count > 0) {
            [[UserDefaultsUtil instance]setPasswordSeed:[[BTPasswordSeed alloc] initWithBTAddress:[BTAddressManager instance].trashAddresses[0]]];
        }
        [[A0SimpleKeychain keychain] setString:[allKeys componentsJoinedByString:KEYCHAIN_KEY_SEP] forKey:KEYCHAIN_KEY];
    }
    return YES;
}

//- (NSArray *)getPrivAddressesFromKeychain;
//- (NSArray *)getTrashAddressesFromKeychain;
//
//- (void)storeToKeychainWithPrivAddresses:(NSArray *) privAddresses andTrashAddresses:(NSArray *) trashAddresses;


@end
