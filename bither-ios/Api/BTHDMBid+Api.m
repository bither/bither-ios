//
//  BTHDMBid+Api.m
//  bitheri
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
#import <Bitheri/NSData+Hash.h>
#import <Bitheri/BTUtils.h>
#import <Bitheri/BTAddressProvider.h>
#import <Bitheri/BTAddressManager.h>
#import <Bitheri/BTEncryptData.h>
#import "BTHDMBid+Api.h"
#import "BitherApi.h"

@implementation BTHDMBid (Api)

- (void)getPreSignHash:(StringBlock) callback andError:(ErrorBlock)error; {
    self.password = [NSData randomWithSize:32];
    __block long serviceRandom = 0;
    [[BitherApi instance] getHDMPasswordRandomWithHDMBid:self.address callback:^(id response) {
        serviceRandom = [response intValue];
        self.serviceRandom = serviceRandom;
        NSString *message = [NSString stringWithFormat:@"bitid://hdm.bither.net/%@/password/%@/%ld", self.address, [NSString hexWithData:self.password], self.serviceRandom];
        NSData *d = [[BTUtils formatMessageForSigning:message] SHA256_2];
        if (callback != nil) {
            callback([NSString hexWithData:d]);
        }
    } andErrorCallBack:^(MKNetworkOperation *errorOp, NSError *err) {

    }];
}

- (void)changeBidPasswordWithSignature:(NSString *)signature andPassword:(NSString *)password callback:(VoidBlock)callback andError:(ErrorBlock)error; {
    NSString *message = [NSString stringWithFormat:@"bitid://hdm.bither.net/%@/password/%@/%ld", self.address, [NSString hexWithData:self.password], self.serviceRandom];
    NSData *d = [[BTUtils formatMessageForSigning:message] SHA256_2];
    BTKey *key = [BTKey signedMessageToKey:message andSignatureBase64:signature];
    if ([self.address isEqualToString:[key address]]) {
        //
    }
    NSString *hotAddress = [BTAddressManager instance].hdmKeychain.firstAddressFromDb;
    [[BitherApi instance] ChangeHDMPasswordWithHDMBid:self.address andPassword:[NSString hexWithData:self.password] andSignature:signature andHotAddress:hotAddress callback:^{
        BTKey *key1 = [[BTKey alloc] initWithSecret:self.password compressed:YES];
        NSString *address = [key1 address];
        self.encryptedBitherPassword = [[[BTEncryptData alloc] initWithData:self.password andPassowrd:password] toEncryptedString];
        [[BTAddressProvider instance] addHDMBid:self andPasswordSeed:address];
    } andErrorCallBack:^(MKNetworkOperation *errorOp, NSError *err) {

    }];
}

- (void)recoverHDMWithSignature:(NSString *)signature andPassword:(NSString *)password callback:(GetArrayBlock)callback andError:(ErrorBlock)error; {
    return ;
}

@end