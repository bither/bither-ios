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
#import "BTHDMAddress.h"
#import "HDMApi.h"

@implementation BTHDMBid (Api)

- (NSString *)getPreSignHashAndError:(NSError **)err; {
    self.password = [NSData randomWithSize:32];
    __block long serviceRandom = 0;
    __block NSCondition *condition = [NSCondition new];
    __block NSError *e = nil;
    [[HDMApi instance] getHDMPasswordRandomWithHDMBid:self.address callback:^(id response) {
        [condition lock];
        serviceRandom = [response intValue];
        [condition signal];
        [condition unlock];
    } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
        [condition lock];
        e = error;
        [condition signal];
        [condition unlock];
    }];
    //
    [condition lock];
    [condition wait];
    NSString *result = nil;
    self.serviceRandom = serviceRandom;
    NSString *message = [NSString stringWithFormat:@"bitid://hdm.bither.net/%@/password/%@/%ld", self.address, [NSString hexWithData:self.password], self.serviceRandom];
    NSData *d = [[BTUtils formatMessageForSigning:message] SHA256_2];
    result = [NSString hexWithData:d];
    [condition unlock];
    return result;
}

- (void)changeBidPasswordWithSignature:(NSString *)signature andPassword:(NSString *)password andHotAddress:(NSString *)hotAddress andError:(NSError **)err; {
    NSString *message = [NSString stringWithFormat:@"bitid://hdm.bither.net/%@/password/%@/%ld", self.address, [NSString hexWithData:self.password], self.serviceRandom];
    NSData *d = [[BTUtils formatMessageForSigning:message] SHA256_2];
    __block NSCondition *condition = [NSCondition new];
    if (![self.address isEqualToString:[[BTKey signedMessageToKey:message andSignatureBase64:signature] address]]) {
        //
    }
    [[HDMApi instance] changeHDMPasswordWithHDMBid:self.address andPassword:self.password andSignature:signature andHotAddress:hotAddress callback:^{
        [condition lock];
        [condition signal];
        [condition unlock];
    } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
        [condition lock];
        [condition signal];
        [condition unlock];
    }];

    [condition lock];
    [condition wait];
    self.encryptedBitherPassword = [[[BTEncryptData alloc] initWithData:self.password andPassowrd:password] toEncryptedString];
    [[BTAddressProvider instance] addHDMBid:self andPasswordSeed:[[[BTKey alloc] initWithSecret:self.password compressed:YES] address]];
    [condition unlock];
}

- (NSArray *)recoverHDMWithSignature:(NSString *)signature andPassword:(NSString *)password andError:(NSError **)error; {
    return nil;
}

- (NSArray *)createHDMAddress:(NSArray *)pubsList andPassword:(NSString *)password andError:(NSError **)err; {
    int start = 2147483647;
    int end = 0;
    NSMutableArray *hots = [NSMutableArray new];
    NSMutableArray *colds = [NSMutableArray new];
    for (BTHDMPubs *pubs in pubsList) {
        start = (int) MIN(start, pubs.index);
        end = (int) MAX(end, pubs.index);
        [hots addObject:pubs.hot];
        [colds addObject:pubs.cold];
    }
    __block NSCondition *condition = [NSCondition new];
    __block NSArray *remotes = nil;
    [[HDMApi instance] createHDMAddressWithHDMBid:self.address andPassword:[[[BTEncryptData alloc] initWithStr:self.encryptedBitherPassword] decrypt:password] start:start end:end pubHots:hots pubColds:colds callback:^(NSArray *array) {
        [condition lock];
        remotes = array;
        [condition signal];
        [condition unlock];
    } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
        [condition lock];
        [condition signal];
        [condition unlock];
    }];

    [condition lock];
    [condition wait];
    for (NSUInteger i = 0; i < pubsList.count; i++) {
        BTHDMPubs *pubs = pubsList[i];
        pubs.remote = remotes[i];
    }
    [condition unlock];
    return pubsList;
}


@end