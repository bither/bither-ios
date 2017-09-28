//
//  DetectAnotherAssetsUtil.h
//  bither-ios
//
//  Created by LTQ on 2017/9/27.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTHDAccountAddress.h"

@interface DetectAnotherAssetsUtil : NSObject

@property(weak) UIViewController *controller;

+(DetectAnotherAssetsUtil *)instance;
-(void) getBCCUnspentOutputs:(NSString *) address andPosition:(int) position andIsPrivate:(Boolean) isPrivate;
-(void) getBCCHDUnspentOutputs:(NSString *)address andPathType:(PathTypeIndex*) pathTypeIndex andIsMonitored:(BOOL) isMonitored;
-(u_int64_t)getAmount:(NSArray *) outs;

@end
