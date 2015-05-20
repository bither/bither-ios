//
//  SensorVisualizerView.m
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

#import "SensorVisualizerView.h"
#import "UEntropySensor.h"

#define kGap (16)

#define kFadeAlpha (0.3)
#define kFlashAlpha (1)
#define kFlashDuration (0.3)

@interface SensorVisualizerView () {
    UIImageView *ivMagnetometer;
    UIImageView *ivAccelerometer;
    UIImageView *ivBrightness;
    UIImageView *ivGyro;
    UIImageView *ivMic;
    NSArray *sensorsList;
    NSMutableSet *animatingSensors;
    BOOL holdingBackNextFlash;
}
@end

@implementation SensorVisualizerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    sensorsList = [[NSArray alloc] initWithObjects:kUEntropySensorMagnetometer,
                                                   kUEntropySensorAccelerometer,
            //kUEntropySensorBrightness,
                                                   kUEntropySensorGyro, nil];
    animatingSensors = [NSMutableSet set];
    ivMic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xrandom_sensor_mic"]];
    ivMagnetometer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xrandom_sensor_magnetic"]];
    ivAccelerometer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xrandom_sensor_accelerometer"]];
    ivBrightness = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xrandom_sensor_light"]];
    ivGyro = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xrandom_sensor_gravity"]];
}

- (void)updateViewWithSensors:(NSArray *)sensors {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger count = sensors.count + (self.showMic ? 1 : 0) - ([sensors containsObject:kUEntropySensorBrightness] ? 1 : 0);
        CGFloat totalWidth = count * kSensorVisualizerViewItemSize + (count - 1) * kGap;
        CGFloat x = (self.frame.size.width - totalWidth) / 2;
        if (self.showMic) {
            UIImageView *iv = ivMic;
            iv.frame = CGRectMake(x, 0, kSensorVisualizerViewItemSize, kSensorVisualizerViewItemSize);
            if (!iv.superview) {
                iv.alpha = kFadeAlpha;
                [self addSubview:iv];
            }
            x += kSensorVisualizerViewItemSize + kGap;
            [self autoFlashMic];
        } else {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoFlashMic) object:nil];
            [ivMic removeFromSuperview];
        }
        for (NSString *s in sensorsList) {
            UIImageView *iv = [self viewForSensor:s];
            if (iv) {
                if ([sensors containsObject:s]) {
                    iv.frame = CGRectMake(x, 0, kSensorVisualizerViewItemSize, kSensorVisualizerViewItemSize);
                    if (!iv.superview) {
                        iv.alpha = kFadeAlpha;
                        [self addSubview:iv];
                    }
                    x += kSensorVisualizerViewItemSize + kGap;
                } else {
                    [iv removeFromSuperview];
                }
            }
        }
    });
}

- (void)autoFlashMic {
    UIImageView *iv = ivMic;
    [UIView animateWithDuration:kFlashDuration animations:^{
        iv.alpha = kFlashAlpha;
    }                completion:^(BOOL finished) {
        [UIView animateWithDuration:kFlashDuration delay:kFlashDuration / 2.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            iv.alpha = kFadeAlpha;
        }                completion:^(BOOL finished) {
            [self performSelector:@selector(autoFlashMic) withObject:nil afterDelay:kFlashDuration];
        }];
    }];
}

- (void)newDataFrom:(NSString *)sensor {
    if ([animatingSensors containsObject:sensor] || holdingBackNextFlash) {
        return;
    }
    holdingBackNextFlash = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (kFlashDuration / 2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        holdingBackNextFlash = NO;
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *iv = [self viewForSensor:sensor];
        if (!iv) {
            return;
        }
        [animatingSensors addObject:sensor];
        [UIView animateWithDuration:kFlashDuration animations:^{
            iv.alpha = kFlashAlpha;
        }                completion:^(BOOL finished) {
            [UIView animateWithDuration:kFlashDuration delay:kFlashDuration / 2.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                iv.alpha = kFadeAlpha;
            }                completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (kFlashDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([animatingSensors containsObject:sensor]) {
                        [animatingSensors removeObject:sensor];
                    }
                });
            }];
        }];
    });
}

- (UIImageView *)viewForSensor:(NSString *)sensor {
    if ([sensor isEqualToString:kUEntropySensorMagnetometer]) {
        return ivMagnetometer;
    }
    if ([sensor isEqualToString:kUEntropySensorAccelerometer]) {
        return ivAccelerometer;
    }
    if ([sensor isEqualToString:kUEntropySensorBrightness]) {
        return ivBrightness;
    }
    if ([sensor isEqualToString:kUEntropySensorGyro]) {
        return ivGyro;
    }
    return nil;
}

@end
