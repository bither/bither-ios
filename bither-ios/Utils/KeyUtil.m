//
//  KeyUtil.m
//  bither-ios
//
//  Copyright 2014 http://Bither.net
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <Bitheri/BTAddressProvider.h>
#import "KeyUtil.h"
#import "BTAddressManager.h"
#import "UserDefaultsUtil.h"
#import "PeerUtil.h"
#import "BTPrivateKeyUtil.h"
#import "BTQRCodeUtil.h"


@implementation KeyUtil
+ (BOOL)addPrivateKeyByRandom:(XRandom *)xRandom passphras:(NSString *)password count:(int)count {
    NSMutableArray *addressList = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        BTKey *key = [BTKey keyWithSecret:[xRandom randomWithSize:32] compressed:YES];
        NSString *privateKeyString = [BTPrivateKeyUtil getPrivateKeyString:key passphrase:password];
        if (!privateKeyString) {
            return NO;
        }
        BTAddress *btAddress = [[BTAddress alloc] initWithKey:key encryptPrivKey:privateKeyString isSyncComplete:YES isXRandom:NO];
        [addressList addObject:btAddress];
    }
    [KeyUtil addAddressList:addressList];
    return YES;
}

+ (BOOL)addBitcoinjKey:(NSArray *)array withPassphrase:(NSString *)passphrase error:(NSError **)aError {
    NSMutableArray *addressList = [NSMutableArray new];
    BTHDMKeychain *keychain = nil;
    for (NSString *encryptPrivKey in array) {
        NSRange range = [encryptPrivKey rangeOfString:HDM_QR_CODE_FLAG];
        if (range.location == 0) {
            NSString *hdmEncryptPrivKey = [encryptPrivKey substringFromIndex:1];
            BTEncryptData *encryptedData = [[BTEncryptData alloc] initWithStr:hdmEncryptPrivKey];
            if ([encryptedData decrypt:passphrase] == nil) {
                return NO;
            } else {
                keychain = [[BTHDMKeychain alloc] initWithEncrypted:hdmEncryptPrivKey password:passphrase andFetchBlock:nil];
            }

        } else {
            BTAddress *btAddress = [[BTAddress alloc] initWithBitcoinjKey:encryptPrivKey withPassphrase:passphrase isSyncComplete:NO];
            if (!btAddress) {
                if (aError != NULL) {
                    *aError = [NSError errorWithDomain:CustomErrorDomain code:PasswordError userInfo:nil];
                }
                return NO;
            }
            [addressList addObject:btAddress];
        }
    }
    if (keychain != nil) {
        [KeyUtil setHDKeyChain:keychain];
    }
    return [KeyUtil addAddressList:addressList];

}

+ (void)setHDKeyChain:(BTHDMKeychain *)keychain {
    [[BTAddressManager instance] setHdmKeychain:keychain];
}

+ (BOOL)addAddressList:(NSArray *)array {
    [[PeerUtil instance] stopPeer];
    array = array.reverseObjectEnumerator.allObjects;
    for (BTAddress *btAddress in array) {
        if (![[[BTAddressManager instance] privKeyAddresses] containsObject:btAddress] && ![[[BTAddressManager instance] watchOnlyAddresses] containsObject:btAddress]) {
            [[BTAddressManager instance] addAddress:btAddress];
        }
    }
    [[PeerUtil instance] startPeer];
    return YES;
}


+ (void)stopMonitor:(BTAddress *)address {
    [[PeerUtil instance] stopPeer];
    [[BTAddressManager instance] stopMonitor:address];
    [[NSNotificationCenter defaultCenter] postNotificationName:BitherBalanceChangedNotification
                                                        object:@[address.address, @(-address.balance), [NSNull null], [NSNull null]]];
    [[PeerUtil instance] startPeer];
}
@end
