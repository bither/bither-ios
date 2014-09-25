//
//  UEntropyCollector.h
//  bither-ios
//
//  Created by noname on 14-9-24.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kUEntropySourceErrorDomain (@"UEntropySource")
#define kUEntropySourceCameraCode (1)
#define kUEntropySourceMicCode (2)
#define kUEntropySourceSensorCode (3)
#define kUEntropySourceErrorDescKey (@"Desc")

@protocol UEntropySource
-(void)onResume;
-(void)onPause;

@optional
-(NSString*)name;
@end

@protocol UEntropyDelegate <NSObject>
-(void)onNoSourceAvailable;
@end

@interface UEntropyCollector : NSObject <UEntropySource>
-(void)onNewData:(NSData*)data fromSource:(NSObject<UEntropySource>*) source;
-(void)onError:(NSError*)error fromSource:(NSObject<UEntropySource>*) source;
@end
