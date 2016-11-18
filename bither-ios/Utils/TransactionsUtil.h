//  TransactionsUtil.h
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
#import "BTAddress.h"

@interface TransactionsUtil : NSObject

//+ (void)checkAddress:(NSArray *)addressList callback:(IdResponseBlock)callback andErrorCallback:(ErrorBlock)errorBlcok;

+ (NSArray *)getTransactions:(NSDictionary *)dict storeBlockHeight:(uint32_t)storeBlockHeigth;

+ (void)syncWallet:(VoidBlock)voidBlock andErrorCallBack:(ErrorHandler)errorCallback;

+ (void)syncWalletFrom_blockChain:(VoidBlock)voidBlock andErrorCallBack:(ErrorHandler)errorCallback;

+ (NSString *)getCompleteTxForError:(NSError *)error;
@end
