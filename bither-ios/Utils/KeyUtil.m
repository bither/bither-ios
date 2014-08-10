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


@implementation KeyUtil
+(void)addPrivateKeyByRandomWithPassphras:(NSString *)password count:(int) count{
    [[BTPeerManager sharedInstance] disconnect];
    for (int i=0; i<count; i++) {
        BTAddress *btAddress=[[BTAddress alloc] initWithPassphrase:password];
        if (![[[BTAddressManager sharedInstance] privKeyAddresses] containsObject:btAddress]) {
            [[BTAddressManager sharedInstance] addAddress:btAddress];
            if (![[UserDefaultsUtil instance] getPasswordSeed]) {
                BTPasswordSeed * passwordSeed=[[BTPasswordSeed alloc] initWithBTAddress:btAddress];
                [[UserDefaultsUtil instance] setPasswordSeed:passwordSeed];
            }
        }
    }
    [[PeerUtil instance] startPeer];

}
+(BOOL)addBitcoinjKey:(NSArray *)array withPassphrase:(NSString *)passphrase error:(NSError **)aError{
    [[BTPeerManager sharedInstance] disconnect];
    for(NSString * encryptPrivKey in array){
        BTAddress *btAddress=[[BTAddress alloc] initWithBitcoinjKey:encryptPrivKey withPassphrase:passphrase];
        if (!btAddress) {
            if (aError!=NULL) {
                *aError = [NSError errorWithDomain:CustomErrorDomain code:PasswordError userInfo:nil];
            }
            return NO;
        }
        if (![[[BTAddressManager sharedInstance]  privKeyAddresses] containsObject:btAddress]&&![[[BTAddressManager sharedInstance] watchOnlyAddresses] containsObject:btAddress]) {
            [[BTAddressManager sharedInstance] addAddress:btAddress];
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
    [[BTPeerManager sharedInstance] disconnect];
    for (NSString * pubKey in pubKeys) {
        BTKey *key = [BTKey keyWithPublicKey:[pubKey hexToData] ];
        BTAddress *btAddress = [[BTAddress alloc] initWithKey:key encryptPrivKey:nil];
        if (![[[BTAddressManager sharedInstance] watchOnlyAddresses] containsObject:btAddress]&&![[[BTAddressManager sharedInstance] privKeyAddresses] containsObject:btAddress]) {
            [[BTAddressManager sharedInstance] addAddress:btAddress];
        }

    }
    [[PeerUtil instance]startPeer];
    
}

+(void)stopMonitor:(BTAddress *)address{
    [[BTPeerManager sharedInstance] disconnect];
    [[BTAddressManager sharedInstance] stopMonitor:address];
    [[NSNotificationCenter defaultCenter] postNotificationName:BitherBalanceChangedNotification
                                                        object:@[address.address, @(-address.balance),[NSNull null], [NSNull null]]];
    [[PeerUtil instance]startPeer];
}
@end
