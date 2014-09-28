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

@implementation XRandom

-(instancetype)initWithDelegate:(id<UEntropyDelegate>)delegate{
    self = [super init];
    if(self){
        self.delegate = delegate;
    }
    return self;
}

-(NSData *)randomWithSize:(NSInteger)size{
    NSMutableData * xRandomData=[NSMutableData new];
    NSData * uRandomData=nil;
    NSData * uEntropyData=nil;
    while (uRandomData==nil) {
        uRandomData=[NSData randomWithSize:size];
    }
    if ([self.delegate respondsToSelector:@selector(randomWithSize:)]) {
        while (uEntropyData==nil) {
            uEntropyData=[self.delegate randomWithSize:size];
        }
    }
    if (uEntropyData!=nil) {
        Byte* uRandomBytes=(Byte*)uRandomData.bytes;
        Byte* uEntropyBytes=(Byte*)uEntropyData.bytes;
        for (int i=0; i<size; i++) {
            Byte byte=uRandomBytes[i]^uEntropyBytes[i];
            [xRandomData appendUInt8:byte];
        }
        
    }else{
        [xRandomData appendData:xRandomData];
    }
    
    return xRandomData;

}

@end
