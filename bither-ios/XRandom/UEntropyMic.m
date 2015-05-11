//
//  UEntropyMic.m
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

#import "UEntropyMic.h"

@interface UEntropyMic () <AVCaptureAudioDataOutputSampleBufferDelegate> {
    AVCaptureDevice *device;
    AVCaptureSession *session;
    dispatch_queue_t queue;
    BOOL paused;
}

@property(weak) UEntropyCollector *collector;
@property(weak) AudioVisualizerView *view;
@end

@implementation UEntropyMic

- (instancetype)initWithView:(AudioVisualizerView *)view andCollector:(UEntropyCollector *)collector {
    self = [super init];
    if (self) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (authStatus == AVAuthorizationStatusDenied) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.view.hidden = YES;
                [collector onError:[[NSError alloc] initWithDomain:kUEntropySourceErrorDomain code:kUEntropySourceMicCode userInfo:@{kUEntropySourceErrorDescKey : @"no mic"}] fromSource:self];
            });
            return self;
        }
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        if (!device) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.view.hidden = YES;
                [collector onError:[[NSError alloc] initWithDomain:kUEntropySourceErrorDomain code:kUEntropySourceMicCode userInfo:@{kUEntropySourceErrorDescKey : @"no mic"}] fromSource:self];
            });
            return self;
        }
        queue = dispatch_queue_create("UEntropyMic", NULL);
        session = [[AVCaptureSession alloc] init];
        AVCaptureAudioDataOutput *output = [AVCaptureAudioDataOutput new];
        [output setSampleBufferDelegate:self queue:queue];
        [session addOutput:output];

        self.collector = collector;
        self.view = view;
        paused = YES;
    }
    return self;
}

- (void)onResume {
    if (!paused) {
        return;
    }
    if (!device) {
        return;
    }
    paused = NO;
    if (session && session.isRunning) {
        [session stopRunning];
    }
    NSError *error = nil;
    AVCaptureInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        self.view.hidden = YES;
        [self.collector onError:[[NSError alloc] initWithDomain:kUEntropySourceErrorDomain code:kUEntropySourceMicCode userInfo:@{kUEntropySourceErrorDescKey : error.debugDescription}] fromSource:self];
        return;
    }
    if (self.view.hidden) {
        self.view.hidden = NO;
    }
    [session addInput:input];
    [session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (sampleBuffer == NULL)
        return;
    AudioBufferList audioBufferList;
    NSMutableData *data = [[NSMutableData alloc] init];
    CMBlockBufferRef blockBuffer;
    CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);

    for (int y = 0; y < audioBufferList.mNumberBuffers; y++) {
        AudioBuffer audioBuffer = audioBufferList.mBuffers[y];
        Float32 *frame = (Float32 *) audioBuffer.mData;
        [data appendBytes:frame length:audioBuffer.mDataByteSize];
    }

    [self.collector onNewData:data fromSource:self];
    [self.view showConnectionData:connection];
    CFRelease(blockBuffer);
}

- (void)onPause {
    if (paused) {
        return;
    }
    if (!device) {
        return;
    }
    paused = YES;
    if (session && session.isRunning) {
        [session stopRunning];
        for (AVCaptureInput *i in [NSArray arrayWithArray:session.inputs]) {
            [session removeInput:i];
        }
    }
}

- (NSString *)name {
    return @"Mic";
}

- (NSUInteger)byteCountFromSingleFrame {
    return 4;
}
@end
