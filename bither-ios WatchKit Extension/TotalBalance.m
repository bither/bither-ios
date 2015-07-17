//
//  TotalBalance.m
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

#import "TotalBalance.h"
#import "GroupFileUtil.h"

@interface TotalBalance () {
    NSDictionary *dict;
}
@end

@implementation TotalBalance

- (instancetype)init {
    self = [super init];
    if (self) {
        dict = [GroupFileUtil totalBalance];
    }
    return self;
}

- (uint64_t)hd {
    return [self getValue:@"hd"];
}

- (uint64_t)hdMonitored {
    return [self getValue:@"hdMonitored"];
}

- (uint64_t)hdm {
    return [self getValue:@"hdm"];
}

- (uint64_t)hot {
    return [self getValue:@"hot"];
}

- (uint64_t)cold {
    return [self getValue:@"cold"];
}

- (uint64_t)total {
    return self.hdm + self.hot + self.cold + self.hd + self.hdMonitored;
}

- (uint64_t)getValue:(NSString *)key {
    if (dict) {
        NSNumber *n = [dict objectForKey:key];
        if (n) {
            return n.longLongValue;
        } else {
            return 0;
        }
    }
    return 0;
}

@end
