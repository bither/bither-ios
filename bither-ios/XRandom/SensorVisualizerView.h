//
//  SensorVisualizerView.h
//  bither-ios
//
//  Created by noname on 14-9-28.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSensorVisualizerViewItemSize (30)
@interface SensorVisualizerView : UIView
@property BOOL showMic;
-(void)updateViewWithSensors:(NSArray*)sensors;
-(void)newDataFrom:(NSString*)sensor;
@end
