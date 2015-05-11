//
//  PasswordGetter.h
//  bither-ios
//
//  Created by 宋辰文 on 15/2/2.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PasswordGetterDelegate
@optional
- (void)beforePasswordDialogShow;

- (void)afterPasswordDialogDismiss;
@end

@interface PasswordGetter : NSObject
- (instancetype)initWithWindow:(UIWindow *)window;

- (instancetype)initWithWindow:(UIWindow *)window andDelegate:(NSObject <PasswordGetterDelegate> *)delegate;

@property(weak) NSObject <PasswordGetterDelegate> *delegate;
@property(weak) UIWindow *window;
@property NSString *password;
@property(readonly) BOOL hasPassword;
@end
