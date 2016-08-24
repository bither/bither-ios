//
//  XRandom.m
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

#import "XRandom.h"
#import "NSData+Hash.h"
#import "NSMutableData+Bitcoin.h"
#import "NSString+Base58.h"

#define PARAMETERS_N @"fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141"
#define PARAMETERS_MIN_N @"0"

@implementation XRandom

- (instancetype)initWithDelegate:(id <UEntropyDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (NSData *)randomWithSize:(NSInteger)size {
    NSMutableData *xRandomData = [NSMutableData new];
    NSData *uRandomData = nil;
    NSData *uEntropyData = nil;

    while ([xRandomData compare:[PARAMETERS_MIN_N hexToData]] == 0 || [xRandomData compare:[PARAMETERS_N hexToData]] >= 0) {
        while (uRandomData == nil) {
            uRandomData = [NSData randomWithSize:(int)size];
        }
        if ([self.delegate respondsToSelector:@selector(randomWithSize:)]) {
            while (uEntropyData == nil) {
                uEntropyData = [self.delegate randomWithSize:size];
            }
        }
        if (uEntropyData != nil) {
            Byte *uRandomBytes = (Byte *) uRandomData.bytes;
            Byte *uEntropyBytes = (Byte *) uEntropyData.bytes;
            for (int i = 0; i < size; i++) {
                Byte byte = uRandomBytes[i] ^uEntropyBytes[i];
                [xRandomData appendUInt8:byte];
            }

        } else {
            [xRandomData appendData:uRandomData];
        }
    }


    return xRandomData;

}


@end
