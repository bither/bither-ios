//  BitherEngine.h
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

#import <Foundation/Foundation.h>
#import "BitherSetting.h"


#define  HTTP_POST @"POST"
#define  HTTP_GET @"GET"
#define  TIME_STRING  @"ts"
typedef enum {
    BitherUser = 1, BitherStats = 2, BitherBitcoin = 3, BitherBC = 4, BitherHDM = 5,BlockChain = 6, ChainBtcCom = 7
} BitherNetworkType;

@interface BitherEngine : NSObject

+ (BitherEngine *)instance;

- (MKNetworkEngine *)getUserNetworkEngine;

- (MKNetworkEngine *)getStatsNetworkEngine;

- (MKNetworkEngine *)getBitcoinNetworkEngine;

- (MKNetworkEngine *)getBCNetworkEngine;

- (MKNetworkEngine *)getHDMNetworkEngine;

- (MKNetworkEngine *)getBlockChainEngine;

- (MKNetworkEngine *)getChainBtcComEngine;


- (void)setEngineCookie;

- (NSArray *)getCookies;

@end
