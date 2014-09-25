//
//  UEntropyCamera.m
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

#import "UEntropyCamera.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface UEntropyCamera() <AVCaptureVideoDataOutputSampleBufferDelegate>{
    AVCaptureDevice *device;
    AVCaptureSession *session;
    dispatch_queue_t queue;
    BOOL paused;
}
@property (weak) UEntropyCollector *collector;
@end

@implementation UEntropyCamera

-(instancetype)initWithViewController:(UIView*)view andCollector:(UEntropyCollector *)collector{
    self = [super init];
    if(self){
        device = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
        if(!device){
            [collector onError:[[NSError alloc]initWithDomain:kUEntropySourceErrorDomain code:kUEntropySourceCameraCode userInfo:@{kUEntropySourceErrorDescKey: @"no camera"}] fromSource:self];
        }
        queue = dispatch_queue_create("UEntropyCamera", NULL);
        session = [[AVCaptureSession alloc]init];
        AVCaptureVideoDataOutput *output = [AVCaptureVideoDataOutput new];
        output.alwaysDiscardsLateVideoFrames = YES;
        [output setSampleBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)self queue: queue];
        [session addOutput:output];
        
        AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession: session];
        CGRect bounds = view.bounds;
        bounds.origin = CGPointZero;
        preview.bounds = bounds;
        preview.position = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [view.layer addSublayer: preview];
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
        [self.collector onError:[[NSError alloc]initWithDomain:kUEntropySourceErrorDomain code:kUEntropySourceCameraCode userInfo:@{kUEntropySourceErrorDescKey: error.debugDescription }] fromSource:self];
        return;
    }
    [session beginConfiguration];
    [session addInput:input];
    [session commitConfiguration];
    [session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    void *src_buff = CVPixelBufferGetBaseAddress(imageBuffer);
    
    NSData *data = [NSData dataWithBytes:src_buff length:bytesPerRow * height];
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
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
    return @"Camera";
}

-(NSUInteger)byteCountFromSingleFrame{
    return 8;
}

@end
