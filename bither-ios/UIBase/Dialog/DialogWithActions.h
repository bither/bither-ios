//
//  DialogWithActions.h
//  bither-ios
//
//  Created by 宋辰文 on 15/1/30.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import "DialogCentered.h"

@interface Action : NSObject
@property NSString *name;
@property SEL selector;
@property(weak) NSObject *target;

- (instancetype)initWithName:(NSString *)name target:(NSObject *)target andSelector:(SEL)selector;

- (void)perform;
@end

@interface DialogWithActions : DialogCentered
@property NSArray *actions;

- (instancetype)initWithActions:(NSArray *)actions;
@end
