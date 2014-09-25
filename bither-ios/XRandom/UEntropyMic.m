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
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface UEntropyMic()<AVCaptureAudioDataOutputSampleBufferDelegate>{
    AVCaptureDevice *device;
    AVCaptureSession *session;
    dispatch_queue_t queue;
    BOOL paused;
}

@property (weak) UEntropyCollector *collector;
@end

@implementation UEntropyMic

-(instancetype)initWithView:(UIView*)view andCollector:(UEntropyCollector*)collector{
    self = [super init];
    if(self){
        device = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeAudio];
        if(!device){
            [collector onError:[[NSError alloc]initWithDomain:kUEntropySourceErrorDomain code:kUEntropySourceCameraCode userInfo:@{kUEntropySourceErrorDescKey: @"no mic"}] fromSource:self];
        }
        queue = dispatch_queue_create("UEntropyMic", NULL);
        session = [[AVCaptureSession alloc]init];
        AVCaptureAudioDataOutput *output = [AVCaptureAudioDataOutput new];
        [output setSampleBufferDelegate: self queue: queue];
        [session addOutput:output];
        
        self.collector = collector;
        paused = YES;
    }
    return self;
}

-(void)onResume{
    if(!paused){
        return;
    }
    paused = NO;
    if(session && session.isRunning){
        [session stopRunning];
    }
    NSError *error = nil;
    AVCaptureInput *input = [[AVCaptureDeviceInput alloc]initWithDevice: device error: &error];
    if(error){
        [self.collector onError:[[NSError alloc]initWithDomain:kUEntropySourceErrorDomain code:kUEntropySourceMicCode userInfo:@{kUEntropySourceErrorDescKey: error.debugDescription }] fromSource:self];
        return;
    }
    [session beginConfiguration];
    [session addInput:input];
    [session commitConfiguration];
    [session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if(sampleBuffer == NULL)
        return;
    AudioBufferList audioBufferList;
    NSMutableData *data=[[NSMutableData alloc] init];
    CMBlockBufferRef blockBuffer;
    CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);
    
    for(int y = 0; y < audioBufferList.mNumberBuffers; y++ ){
        AudioBuffer audioBuffer = audioBufferList.mBuffers[y];
        Float32 *frame = (Float32*)audioBuffer.mData;
        [data appendBytes:frame length:audioBuffer.mDataByteSize];
    }
    
    [self.collector onNewData:data fromSource:self];
}

-(void)onPause{
    if(paused){
        return;
    }
    paused = YES;
    if(session && session.isRunning){
        [session stopRunning];
    }
}

-(NSString*)name{
    return @"Mic";
}

-(NSUInteger)byteCountFromSingleFrame{
    return 8;
}
@end
