//
//  UEntropyCamera.m
//  bither-ios
//
//  Created by noname on 14-9-24.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "UEntropyCamera.h"
#import "NSString+Base58.h"
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

-(instancetype)initWithViewController:(UIViewController*)parent andCollector:(UEntropyCollector *)collector{
    self = [super init];
    if(self){
        device = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
        if(!device){
            [collector onError:[[NSError alloc]initWithDomain:kUEntropySourceErrorDomain code:kUEntropySourceCameraCode userInfo:@{kUEntropySourceErrorDescKey: @"no camera"}] fromSource:self];
        }
        queue = dispatch_queue_create("ZBarCaptureReader", NULL);
        session = [[AVCaptureSession alloc]init];
        AVCaptureVideoDataOutput *output = [AVCaptureVideoDataOutput new];
        output.alwaysDiscardsLateVideoFrames = YES;
        [output setSampleBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)self queue: queue];
        [session addOutput:output];
        
        AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession: session];
        CGRect bounds = parent.view.bounds;
        bounds.origin = CGPointZero;
        preview.bounds = bounds;
        preview.position = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [parent.view.layer addSublayer: preview];
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

@end
