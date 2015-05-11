//
//  UEntropyCollector.h
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
#import "XRandom.h"

#define kUEntropySourceErrorDomain (@"UEntropySource")
#define kUEntropySourceCameraCode (1)
#define kUEntropySourceMicCode (2)
#define kUEntropySourceSensorCode (3)
#define kUEntropySourceErrorDescKey (@"Desc")

@protocol UEntropySource
- (void)onResume;

- (void)onPause;

@optional
- (NSString *)name;

- (NSUInteger)byteCountFromSingleFrame;
@end

@protocol UEntropyCollectorDelegate <NSObject>
- (void)onNoSourceAvailable;
@end

@interface UEntropyCollector : NSObject <UEntropySource, UEntropyDelegate>
@property(weak) NSObject <UEntropyCollectorDelegate> *delegate;
@property(strong) NSMutableSet *sources;

- (instancetype)initWithDelegate:(NSObject <UEntropyCollectorDelegate> *)delegate;

- (void)addSource:(NSObject <UEntropySource> *)source, ...;

- (void)start;

- (void)stop;

- (void)onNewData:(NSData *)data fromSource:(NSObject <UEntropySource> *)source;

- (void)onError:(NSError *)error fromSource:(NSObject <UEntropySource> *)source;
@end
