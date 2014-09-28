//
//  UEntropySensor.m
//  ;
//
//  Created by noname on 14-9-26.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "UEntropySensor.h"
#import "NSString+Base58.h"
@import CoreMotion;

@interface UEntropySensor(){
    CMMotionManager* manager;
    NSOperationQueue* queue;
}
@property (weak) UEntropyCollector* collector;
@end

@implementation UEntropySensor

-(instancetype) initWithCollecor:(UEntropyCollector*) collector{
    self = [super init];
    if(self){
        self.collector = collector;
        manager = [[CMMotionManager alloc]init];
        queue = [[NSOperationQueue alloc]init];
        queue.name = @"UEntropySensor";
    }
    return self;
}

-(void)onResume{
    [self updateViews];
    [[UIScreen mainScreen] addObserver:self forKeyPath:@"brightness" options:NSKeyValueObservingOptionNew context:NULL];
    if(manager.isAccelerometerAvailable){
        [manager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            if(!error){
                CMAcceleration a = accelerometerData.acceleration;
                NSMutableData *data = [NSMutableData data];
                [data appendBytes:&a length:sizeof(CMAcceleration)];
                [self newData:data from:kUEntropySensorAccelerometer];
            }else{
                [self updateViews];
            }
        }];
    }
    if(manager.isGyroAvailable){
        [manager startGyroUpdatesToQueue:queue withHandler:^(CMGyroData *gyroData, NSError *error) {
            if(!error){
                CMRotationRate a = gyroData.rotationRate;
                NSMutableData *data = [NSMutableData data];
                [data appendBytes:&a length:sizeof(CMRotationRate)];
                [self newData:data from:kUEntropySensorGyro];
            }else{
                [self updateViews];
            }
        }];
    }
    if(manager.isMagnetometerAvailable){
        [manager startMagnetometerUpdatesToQueue:queue withHandler:^(CMMagnetometerData *magnetometerData, NSError *error) {
            if(!error){
                CMMagneticField a = magnetometerData.magneticField;
                NSMutableData *data = [NSMutableData data];
                [data appendBytes:&a length:sizeof(CMMagneticField)];
                [self newData:data from:kUEntropySensorMagnetometer];
            }else{
                [self updateViews];
            }
        }];
    }
}

-(void)onPause{
    [[UIScreen mainScreen]removeObserver:self forKeyPath:@"brightness"];
    [manager stopAccelerometerUpdates];
    [manager stopGyroUpdates];
    [manager stopMagnetometerUpdates];
    [queue cancelAllOperations];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if(object == [UIScreen mainScreen] && [keyPath isEqualToString:@"brightness"]){
        CGFloat brightness = [UIScreen mainScreen].brightness;
        NSMutableData * data = [NSMutableData data];
        [data appendBytes:&brightness length:sizeof(CGFloat)];
        [self newData:data from:kUEntropySensorBrightness];
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

-(void)newData:(NSData*)data from:(NSString*)source{
    [self.collector onNewData:data fromSource:self];
}

-(void)updateViews{
    dispatch_async(dispatch_get_main_queue(), ^{
        int count = 0;
        if(manager.isMagnetometerAvailable){
            count++;
        }
        if(manager.isAccelerometerAvailable){
            count++;
        }
        if(manager.isGyroAvailable){
            count++;
        }
        if(count == 0){
            [self.collector onError:[[NSError alloc]initWithDomain:kUEntropySourceErrorDomain code:kUEntropySourceSensorCode userInfo:@{kUEntropySourceErrorDescKey: @"no sensors"}] fromSource:self];
        }
    });
}

-(NSString*)name{
    return @"Sensor";
}

@end
