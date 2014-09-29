//
//  UEntropyAnimatedTransition.h
//  bither-ios
//
//  Created by noname on 14-9-29.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UEntropyAnimatedTransition : NSObject<UIViewControllerAnimatedTransitioning>
-(instancetype)initWithPresenting:(BOOL)presenting;
@property BOOL presenting;
@end
