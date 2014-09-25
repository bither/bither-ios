//
//  UEntropyCollector.m
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

#import "UEntropyCollector.h"

@interface UEntropyCollector(){
    dispatch_queue_t queue;
    BOOL paused;
    BOOL shouldCollectData;
    NSInputStream *input;
    NSOutputStream *output;
}
@end

#define kUEntropyPoolSize (32 * 200)

@implementation UEntropyCollector

-(instancetype)initWithDelegate:(NSObject<UEntropyDelegate>*) delegate{
    self = [super init];
    if(self){
        self.delegate = delegate;
        self.sources = [NSMutableSet set];
        queue = dispatch_queue_create("UEntropyCollector", NULL);
        paused = YES;
        shouldCollectData = NO;
    }
    return self;
}

-(void)addSource:(NSObject<UEntropySource>*)source,...{
    if(!source){
        return;
    }
    [self addSingleSource:source];
    va_list list;
    va_start(list, source);
    while (YES)
    {
        NSObject<UEntropySource> *s= va_arg(list, NSObject<UEntropySource> *);
        if (s) {
            [self addSingleSource:s];
        }else{
            break;
        }
    }
    va_end(list);
}

-(void)addSingleSource:(NSObject<UEntropySource>*)source{
    [self.sources addObject:source];
    if (!paused) {
        [source onResume];
    }
}

-(void)onNewData:(NSData*)data fromSource:(NSObject<UEntropySource>*) source{
    if(shouldCollectData){
        dispatch_async(queue, ^{
            if(shouldCollectData && output && output.hasSpaceAvailable){
                NSInteger actuallyWriten = [output write:data.bytes maxLength:data.length];
                NSLog(@"write %lu/%lu data to uentropy pool", actuallyWriten, data.length);
            }
        });
    }
}

-(void)onError:(NSError*)error fromSource:(NSObject<UEntropySource>*) source{
    NSLog(@"uentropy collector source %@ error %@", source.name, error.description);
    [source onPause];
    if([self.sources containsObject:source]){
        [self.sources removeObject:source];
    }
    if(self.sources.count == 0){
        if(self.delegate && [self.delegate respondsToSelector:@selector(onNoSourceAvailable)]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate onNoSourceAvailable];
            });
        }
    }
}

-(NSData*)nextBytes:(int)length{
    if(!shouldCollectData || !input){
        return nil;
    }
    NSMutableData* data = [NSMutableData dataWithLength:length];
    NSUInteger dataNeeded = length;
    while (dataNeeded > 0) {
        if(input.hasBytesAvailable){
            NSInteger outcome = [input read:data.mutableBytes + (length - dataNeeded) maxLength:dataNeeded];
            if(outcome < 0){
                NSLog(@"uentropy collector read error");
                [self.delegate onNoSourceAvailable];
                return nil;
            }
            dataNeeded -= outcome;
        }
    }
    return data;
}

-(void)start{
    if(shouldCollectData){
        return;
    }
    shouldCollectData = YES;
    NSInputStream *inputStr;
    NSOutputStream *outputStr;
    [self createBoundInputStream:&inputStr outputStream:&outputStr bufferSize:kUEntropyPoolSize];
    if(!inputStr || !outputStr){
        [self.delegate onNoSourceAvailable];
    }
    input = inputStr;
    output = outputStr;
    [output open];
    [input open];
}

-(void)stop{
    if(!shouldCollectData){
        return;
    }
    shouldCollectData = NO;
    [output close];
    [input close];
    output = nil;
    input = nil;
}

-(void)onResume{
    if(!paused){
        return;
    }
    paused = NO;
    for(NSObject<UEntropySource>* s in self.sources){
        [s onResume];
    }
}

-(void)onPause{
    if(paused){
        return;
    }
    paused = YES;
    for(NSObject<UEntropySource>* s in self.sources){
        [s onPause];
    }
}

- (void)createBoundInputStream:(NSInputStream **)inputStreamPtr outputStream:(NSOutputStream **)outputStreamPtr bufferSize:(NSUInteger)bufferSize
{
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    
    assert( (inputStreamPtr != NULL) || (outputStreamPtr != NULL) );
    
    readStream = NULL;
    writeStream = NULL;
    CFStreamCreateBoundPair(NULL,
                            ((inputStreamPtr  != nil) ? &readStream : NULL),
                            ((outputStreamPtr != nil) ? &writeStream : NULL),
                            (CFIndex) bufferSize
                            );
    
    if (inputStreamPtr != NULL) {
        *inputStreamPtr  = CFBridgingRelease(readStream);
    }
    if (outputStreamPtr != NULL) {
        *outputStreamPtr = CFBridgingRelease(writeStream);
    }
}
@end
