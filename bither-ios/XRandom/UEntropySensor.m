//
//  UEntropySensor.m
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
//

#import "UEntropySensor.h"

@import CoreMotion;

@interface UEntropySensor () {
    CMMotionManager *manager;
    NSOperationQueue *queue;
    BOOL paused;
}
@property(weak) UEntropyCollector *collector;
@property(weak) SensorVisualizerView *view;
@end

@implementation UEntropySensor

- (instancetype)initWithView:(SensorVisualizerView *)view andCollecor:(UEntropyCollector *)collector {
    self = [super init];
    if (self) {
        self.collector = collector;
        manager = [[CMMotionManager alloc] init];
        queue = [[NSOperationQueue alloc] init];
        queue.name = @"UEntropySensor";
        self.view = view;
        [self onResume];
    }
    return self;
}

- (void)onResume {
    paused = NO;
    [self updateViews];
    [[UIScreen mainScreen] addObserver:self forKeyPath:@"brightness" options:NSKeyValueObservingOptionNew context:NULL];
    if (manager.isAccelerometerAvailable) {
        [manager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            if (paused) {
                return;
            }
            if (!error) {
                CMAcceleration a = accelerometerData.acceleration;
                NSMutableData *data = [NSMutableData data];
                [data appendBytes:&a length:sizeof(CMAcceleration)];
                [self newData:data from:kUEntropySensorAccelerometer];
            } else {
                [self updateViews];
            }
        }];
    }
    if (manager.isGyroAvailable) {
        [manager startGyroUpdatesToQueue:queue withHandler:^(CMGyroData *gyroData, NSError *error) {
            if (paused) {
                return;
            }
            if (!error) {
                CMRotationRate a = gyroData.rotationRate;
                NSMutableData *data = [NSMutableData data];
                [data appendBytes:&a length:sizeof(CMRotationRate)];
                [self newData:data from:kUEntropySensorGyro];
            } else {
                [self updateViews];
            }
        }];
    }
    if (manager.isMagnetometerAvailable) {
        [manager startMagnetometerUpdatesToQueue:queue withHandler:^(CMMagnetometerData *magnetometerData, NSError *error) {
            if (paused) {
                return;
            }
            if (!error) {
                CMMagneticField a = magnetometerData.magneticField;
                NSMutableData *data = [NSMutableData data];
                [data appendBytes:&a length:sizeof(CMMagneticField)];
                [self newData:data from:kUEntropySensorMagnetometer];
            } else {
                [self updateViews];
            }
        }];
    }
    [self notifyBrightness];
}

- (void)onPause {
    paused = YES;
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
    [manager stopAccelerometerUpdates];
    [manager stopGyroUpdates];
    [manager stopMagnetometerUpdates];
    [queue cancelAllOperations];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(notifyBrightness) object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [UIScreen mainScreen] && [keyPath isEqualToString:@"brightness"]) {
        CGFloat brightness = [UIScreen mainScreen].brightness;
        NSMutableData *data = [NSMutableData data];
        [data appendBytes:&brightness length:sizeof(CGFloat)];
        [self newData:data from:kUEntropySensorBrightness];
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)newData:(NSData *)data from:(NSString *)source {
    [self.view newDataFrom:source];
    [self.collector onNewData:data fromSource:self];
}

- (void)notifyBrightness {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(notifyBrightness) object:nil];
    [self.view newDataFrom:kUEntropySensorBrightness];
    [self performSelector:@selector(notifyBrightness) withObject:nil afterDelay:1];
}

- (void)updateViews {
    NSMutableArray *sensors = [NSMutableArray array];
    if (manager.isMagnetometerAvailable) {
        [sensors addObject:kUEntropySensorMagnetometer];
    }
    if (manager.isAccelerometerAvailable) {
        [sensors addObject:kUEntropySensorAccelerometer];
    }
    if (manager.isGyroAvailable) {
        [sensors addObject:kUEntropySensorGyro];
    }
    [sensors addObject:kUEntropySensorBrightness];
    if (sensors.count == 0) {
        [self.collector onError:[[NSError alloc] initWithDomain:kUEntropySourceErrorDomain code:kUEntropySourceSensorCode userInfo:@{kUEntropySourceErrorDescKey : @"no sensors"}] fromSource:self];
    }
    [self.view updateViewWithSensors:sensors];
}

- (NSString *)name {
    return @"Sensor";
}

@end
