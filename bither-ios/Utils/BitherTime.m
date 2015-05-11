//
//  BitherTime.m
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

#import "BitherTime.h"
#import "BitherApi.h"
#import "MarketUtil.h"
#import "GroupFileUtil.h"

static BitherTime *bitherTime;

@interface BitherTime ()
@property(nonatomic, strong) NSTimer *timer;

@end


@implementation BitherTime

+ (BitherTime *)instance {
    @synchronized (self) {
        if (bitherTime == nil) {
            bitherTime = [[self alloc] init];
        }
    }
    return bitherTime;
}

- (void)start {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError *error = nil;
        NSData *data = [[GroupFileUtil getTicker] dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            id returnValue = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (returnValue) {
                [MarketUtil handlerResult:returnValue];
            }

        }
        [self updateTicker];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.timer) {
                self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateTicker) userInfo:nil repeats:YES];


            }
        });

    });

}

- (void)pause {
    if (![self.timer isValid]) {
        return;
    }
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)resume {
    if (![self.timer isValid]) {
        return;
    }
    [self.timer setFireDate:[NSDate date]];
}

- (void)stop {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }

}

- (void)updateTicker {

    [[BitherApi instance] getExchangeTicker:nil andErrorCallBack:nil];
}


@end
