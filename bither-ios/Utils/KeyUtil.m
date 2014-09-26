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

#import "KeyUtil.h"
#import "BTAddressManager.h"
#import "UserDefaultsUtil.h"
#import "FileUtil.h"
#import "BTPeerManager.h"
#import "PeerUtil.h"
#import "BTPrivateKeyUtil.h"
#import "BTQRCodeUtil.h"


@implementation KeyUtil
+(void)addPrivateKeyByRandomWithPassphras:(NSString *)password count:(int) count{
    [[PeerUtil instance] stopPeer];
    for (int i=0; i<count; i++) {
        BTKey *key = [BTKey keyWithSecret:[NSData randomWithSize:32] compressed:YES];
        NSString * privateKeyString=[BTPrivateKeyUtil getPrivateKeyString:key passphrase:password];
        BTAddress *btAddress=[[BTAddress alloc] initWithKey:key encryptPrivKey:privateKeyString isXRandom:NO];
        if (![[[BTAddressManager instance] privKeyAddresses] containsObject:btAddress]) {
            [[BTAddressManager instance] addAddress:btAddress];
            if (![[UserDefaultsUtil instance] getPasswordSeed]) {
                BTPasswordSeed * passwordSeed=[[BTPasswordSeed alloc] initWithBTAddress:btAddress];
                [[UserDefaultsUtil instance] setPasswordSeed:passwordSeed];
            }
        }
    }
    [[PeerUtil instance] startPeer];

}
+(BOOL)addBitcoinjKey:(NSArray *)array withPassphrase:(NSString *)passphrase error:(NSError **)aError{
    [[PeerUtil instance] stopPeer];
    for(NSString * encryptPrivKey in array){
        BTAddress *btAddress=[[BTAddress alloc] initWithBitcoinjKey:encryptPrivKey withPassphrase:passphrase];
        if (!btAddress) {
            if (aError!=NULL) {
                *aError = [NSError errorWithDomain:CustomErrorDomain code:PasswordError userInfo:nil];
            }
            return NO;
        }
        if (![[[BTAddressManager instance]  privKeyAddresses] containsObject:btAddress]&&![[[BTAddressManager instance] watchOnlyAddresses] containsObject:btAddress]) {
            [[BTAddressManager instance] addAddress:btAddress];
            if (![[UserDefaultsUtil instance] getPasswordSeed]) {
                BTPasswordSeed * passwordSeed=[[BTPasswordSeed alloc] initWithBTAddress:btAddress];
                [[UserDefaultsUtil instance] setPasswordSeed:passwordSeed];
            }
        }
    }
    [[PeerUtil instance]startPeer];
    return YES; 
}
+(BOOL)addAddressList:(NSArray *)array {
    [[PeerUtil instance] stopPeer];
    for(BTAddress * btAddress in array){
        if (![[[BTAddressManager instance]  privKeyAddresses] containsObject:btAddress]&&![[[BTAddressManager instance] watchOnlyAddresses] containsObject:btAddress]) {
            [[BTAddressManager instance] addAddress:btAddress];
            if (![[UserDefaultsUtil instance] getPasswordSeed]) {
                BTPasswordSeed * passwordSeed=[[BTPasswordSeed alloc] initWithBTAddress:btAddress];
                [[UserDefaultsUtil instance] setPasswordSeed:passwordSeed];
            }
        }
    }
    [[PeerUtil instance]startPeer];
    return YES;
}
+(void) addWatckOnly:(NSArray *)pubKeys{
    [[PeerUtil instance] stopPeer];
    for (NSString * pubKey in pubKeys) {
        BOOL isXRandom=NO;
        NSString * pubKeyString;
        if ([pubKey rangeOfString:XRANDOM_FLAG].location!=NSNotFound) {
            pubKeyString=[pubKey substringFromIndex:1];
            isXRandom=YES;
        }else{
            pubKeyString=pubKey;
        }
        BTKey *key = [BTKey keyWithPublicKey:[pubKeyString hexToData] ];
        BTAddress *btAddress = [[BTAddress alloc] initWithKey:key encryptPrivKey:nil isXRandom:isXRandom];
        if (![[[BTAddressManager instance] watchOnlyAddresses] containsObject:btAddress]&&![[[BTAddressManager instance] privKeyAddresses] containsObject:btAddress]) {
            [[BTAddressManager instance] addAddress:btAddress];
        }

    }
    [[PeerUtil instance]startPeer];
    
}

+(void)stopMonitor:(BTAddress *)address{
    [[PeerUtil instance] stopPeer];
    [[BTAddressManager instance] stopMonitor:address];
    [[NSNotificationCenter defaultCenter] postNotificationName:BitherBalanceChangedNotification
                                                        object:@[address.address, @(-address.balance),[NSNull null], [NSNull null]]];
    [[PeerUtil instance]startPeer];
}
@end
