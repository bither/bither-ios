//
//  UEntropyCamera.h
//  bither-ios
//
//  Created by noname on 14-9-24.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "ZBarImageScanner.h"
#import "UEntropyCollector.h"

@interface UEntropyCamera : NSObject <UEntropySource>
-(instancetype)initWithViewController:(UIViewController*)parent andCollector:(UEntropyCollector*)collector;
@end
