//
//  BTHDMBid+Api.h
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
#import "BTHDMBid.h"
#import "BitherSetting.h"

@interface BTHDMBid (Api)

- (NSString *)getPreSignHashAndError:(NSError **)err;

- (NSString *)changeBidPasswordWithSignature:(NSString *)signature andPassword:(NSString *)password andHotAddress:(NSString *)hotAddress andError:(NSError **)err;

- (NSString *)changeBidPasswordWithSignature:(NSString *)signature andPassword:(NSString *)password andError:(NSError **)error;

- (void)save;

- (NSArray *)createHDMAddress:(NSArray *)pubsList andPassword:(NSString *)password andError:(NSError **)err;

- (NSArray *)recoverHDMWithSignature:(NSString *)signature andPassword:(NSString *)password andError:(NSError **)err;

- (NSArray *)signatureByRemoteWithPassword:(NSString *)password andUnsignHash:(NSArray *)unsignHashes andIndex:(int)index andError:(NSError **)err;
@end