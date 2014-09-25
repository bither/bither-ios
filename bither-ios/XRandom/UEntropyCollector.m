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
}
@end

@implementation UEntropyCollector

-(instancetype)initWithDelegate:(NSObject<UEntropyDelegate>*) delegate{
    self = [super init];
    if(self){
        self.delegate = delegate;
        self.sources = [NSMutableSet set];
        paused = YES;
        shouldCollectData = NO;
    }
    return self;
}

-(void)addSource:(NSObject<UEntropySource>*)source,...{
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
    return nil;
}

-(void)start{
    if(shouldCollectData){
        return;
    }
    shouldCollectData = YES;
}

-(void)stop{
    if(!shouldCollectData){
        return;
    }
    shouldCollectData = NO;
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
@end
