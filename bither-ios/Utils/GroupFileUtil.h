//
//  GroupFileUtil.h
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
//
//  Created by songchenwen on 2015/2/27.
//

#import <Foundation/Foundation.h>

#define kBitherGroupName (@"group.net.bither.ent")

@interface GroupFileUtil : NSObject

+ (void)setTotalBalanceWithHD:(int64_t)hd hdMonitored:(int64_t)hdMonitored hot:(int64_t)hot andCold:(int64_t)cold HDM:(int64_t)hdm;

+ (NSDictionary *)totalBalance;

+ (void)setTicker:(NSString *)content;

+ (NSString *)getTicker;

+ (void)setCurrencyRate:(NSString *)currencyRate;

+ (NSString *)getCurrencyRate;

+ (BOOL)supported;

+ (NSString *)readFile:(NSURL *)url;

+ (BOOL)writeFile:(NSURL *)url content:(NSString *)content;
@end
