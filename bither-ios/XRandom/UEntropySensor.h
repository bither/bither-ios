//
//  UEntropySensor.h
//  bither-ios
//
//  Created by noname on 14-9-26.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "UEntropyCollector.h"
#define kUEntropySensorAccelerometer (@"Accelerometer")
#define kUEntropySensorGyro (@"Gyro")
#define kUEntropySensorMagnetometer (@"Magnetometer")
#define kUEntropySensorBrightness (@"Brightness")

@interface UEntropySensor : NSObject<UEntropySource>
-(instancetype) initWithCollecor:(UEntropyCollector*) collector;
@end
