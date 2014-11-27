//
//  TouchIdIntegration.h
//  bither-ios
//
//  Created by noname on 14-11-22.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TouchIdIntegration : NSObject
+(TouchIdIntegration*)instance;
-(BOOL)hasTouchId;
-(void)checkTouchId:(void (^)(BOOL success, BOOL denied))completion;
@end
