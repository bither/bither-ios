//
//  HDMApi.h
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
#import <Foundation/Foundation.h>
#import "BitherSetting.h"

@interface HDMApi : NSObject

+ (HDMApi *)instance;

- (void)getHDMPasswordRandomWithHDMBid:(NSString *)hdmBid callback:(IdResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

- (void)changeHDMPasswordWithHDMBid:(NSString *)hdmBid andPassword:(NSData *)password
                       andSignature:(NSString *)signature andHotAddress:(NSString *)hotAddress
                           callback:(VoidResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

- (void)createHDMAddressWithHDMBid:(NSString *)hdmBid andPassword:(NSData *)password start:(int)start end:(int)end
                           pubHots:(NSArray *)pubHots pubColds:(NSArray *)pubColds
                          callback:(ArrayResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

- (void)signatureByRemoteWithHDMBid:(NSString *)hdmBid andPassword:(NSData *)password andUnsignHash:(NSArray *)unsignHashes andIndex:(int)index
                           callback:(ArrayResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

- (void)recoverHDMAddressWithHDMBid:(NSString *)hdmBid andPassword:(NSData *)password andSignature:(NSString *)signature
                           callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

@end