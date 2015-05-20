//
//  NSDictionary-Fromat.m
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

#import "NSDictionary+Fromat.h"

@implementation NSDictionary (Fromat)
- (int)getIntFromDict:(NSString *)key andDefault:(int)defaultValue; {
    if ([[self allKeys] containsObject:key]) {
        return [[self objectForKey:key] intValue];
    } else {
        return defaultValue;
    }
}

- (long)getLongFromDict:(NSString *)key andDefault:(long)defaultValue; {
    if ([[self allKeys] containsObject:key]) {
        return [[self objectForKey:key] longValue];
    } else {
        return defaultValue;
    }
}

- (long long)getLongLongFromDict:(NSString *)key andDefault:(long long)defaultValue; {
    if ([[self allKeys] containsObject:key]) {
        return [[self objectForKey:key] longLongValue];
    } else {
        return defaultValue;
    }
}

- (float)getFloatFromDict:(NSString *)key andDefault:(float)defaultValue {
    if ([[self allKeys] containsObject:key]) {
        return [[self objectForKey:key] floatValue];
    } else {
        return defaultValue;
    }

}

- (double)getDoubleFromDict:(NSString *)key andDefault:(double)defaultValue {
    if ([[self allKeys] containsObject:key]) {
        return [[self objectForKey:key] doubleValue];
    } else {
        return defaultValue;
    }
}

- (NSString *)getStringFromDict:(NSString *)key andDefault:(NSString *)defaultValue; {
    if ([[self allKeys] containsObject:key]) {
        id obj = [self objectForKey:key];
        if ([obj isKindOfClass:[NSString class]]) {
            return obj;
        } else {
            return [obj stringValue];
        }
    } else {
        return defaultValue;
    }
}

- (BOOL)getBoolFromDict:(NSString *)key andDefault:(BOOL)defaultValue {
    if ([[self allKeys] containsObject:key]) {
        return [[self objectForKey:key] boolValue];

    } else {
        return defaultValue;
    }

}

- (int)getIntFromDict:(NSString *)key {
    return [self getIntFromDict:key andDefault:0];
}

- (long)getLongFromDict:(NSString *)key {
    return [self getLongFromDict:key andDefault:0];
}

- (long long)getLongLongFromDict:(NSString *)key {
    return [self getLongLongFromDict:key andDefault:0];
}

- (float)getFloatFromDict:(NSString *)key {
    return [self getFloatFromDict:key andDefault:0];
}

- (double)getDoubleFromDict:(NSString *)key {
    return [self getDoubleFromDict:key andDefault:0];
}

- (NSString *)getStringFromDict:(NSString *)key {
    return [self getStringFromDict:key andDefault:nil];
}

- (BOOL)getBoolFromDict:(NSString *)key {
    return [self getBoolFromDict:key andDefault:NO];
}


@end
