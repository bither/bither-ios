//
//  KeychainUtil.m
//  bither-ios
//
//  Created by ZhouQi on 14/11/21.
//  Copyright (c) 2014年 ZhouQi. All rights reserved.
//

#define SEC_ATTR_SERVICE @"net.bither.bither-ios"

#import "KeychainUtil.h"
@import LocalAuthentication;
@import Security;

static BOOL isPasscodeEnabled()
{
    NSError *error = nil;
    
    if (! [LAContext class]) return YES; // we can only check for passcode on iOS 8 and above
    if ([[LAContext new] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) return YES;
    return (error && error.code == LAErrorPasscodeNotSet) ? NO : YES;
}

static BOOL setKeychainData(NSData *data, NSString *key, BOOL authenticated)
{
    if (! key) return NO;
    
    id accessible = (authenticated) ? (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly :
    (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
    NSDictionary *query = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService:SEC_ATTR_SERVICE,
                            (__bridge id)kSecAttrAccount:key};
    
    if (SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL) == errSecItemNotFound) {
        if (! data) return YES;
        
        NSDictionary *item = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                               (__bridge id)kSecAttrService:SEC_ATTR_SERVICE,
                               (__bridge id)kSecAttrAccount:key,
                               (__bridge id)kSecAttrAccessible:accessible,
                               (__bridge id)kSecValueData:data};
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)item, NULL);
        
        if (status == noErr) return YES;
        NSLog(@"SecItemAdd error status %d", (int)status);
        return NO;
    }
    
    if (! data) {
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
        
        if (status == noErr) return YES;
        NSLog(@"SecItemDelete error status %d", (int)status);
        return NO;
    }
    
    NSDictionary *update = @{(__bridge id)kSecAttrAccessible:accessible,
                             (__bridge id)kSecValueData:data};
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)update);
    
    if (status == noErr) return YES;
    NSLog(@"SecItemUpdate error status %d", (int)status);
    return NO;
}

static NSData *getKeychainData(NSString *key)
{
    NSDictionary *query = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService:SEC_ATTR_SERVICE,
                            (__bridge id)kSecAttrAccount:key,
                            (__bridge id)kSecReturnData:@YES};
    CFDataRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    
    if (status == errSecItemNotFound) return nil;
    if (status == noErr) return CFBridgingRelease(result);
    
    if (status == errSecAuthFailed && ! isPasscodeEnabled()) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"turn device passcode on", nil)
                                    message:NSLocalizedString(@"\ngo to settings and turn passcode on to access restricted areas of your wallet",
                                                              nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil)
                          otherButtonTitles:nil] show];
    }
    
    NSLog(@"SecItemCopyMatching error status %d", (int)status);
    return nil;
}

static BOOL setKeychainInt(int64_t i, NSString *key, BOOL authenticated)
{
    @autoreleasepool {
        NSMutableData *d = [NSMutableData new];
        //        NSMutableData *d = [NSMutableData secureDataWithLength:sizeof(int64_t)];
        
        *(int64_t *)d.mutableBytes = i;
        return setKeychainData(d, key, authenticated);
    }
}

static int64_t getKeychainInt(NSString *key)
{
    @autoreleasepool {
        NSData *d = getKeychainData(key);
        
        return (d.length == sizeof(int64_t)) ? *(int64_t *)d.bytes : 0;
    }
}

static BOOL setKeychainString(NSString *s, NSString *key, BOOL authenticated)
{
    @autoreleasepool {
        NSData *d = (s) ? [s dataUsingEncoding:NSUTF8StringEncoding] : nil;
        
        return setKeychainData(d, key, authenticated);
    }
}

static NSString *getKeychainString(NSString *key)
{
    @autoreleasepool {
        NSData *d = getKeychainData(key);
        return (d) ? [NSString stringWithUTF8String:[d bytes]] : nil;
    }
}


@implementation KeychainUtil
+ (BOOL)setKeychainData:(NSData *)data andKey:( NSString *)key andAuthenticated:(BOOL) authenticated; {
    return setKeychainData(data, key, authenticated);
}

+ (NSData *)getKeychainData:(NSString *)key; {
    return getKeychainData(key);
}

+ (BOOL)setKeychainInt:(int64_t)i andKey:(NSString *) key andAuthenticated:(BOOL) authenticated; {
    return setKeychainInt(i, key, authenticated);
}

+ (int64_t)getKeychainInt:(NSString *)key;{
    return getKeychainInt(key);
}

+ (BOOL)setKeychainString:(NSString *)s andKey:(NSString *)key andAuthenticated:(BOOL) authenticated; {
    return setKeychainString(s, key, authenticated);
}

+ (NSString *)getKeychainString:(NSString *) key; {
    return getKeychainString(key);
}

@end
