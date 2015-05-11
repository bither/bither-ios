//
//  PasswordGetter.m
//  bither-ios
//
//  Created by 宋辰文 on 15/2/2.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import "PasswordGetter.h"
#import "DialogPassword.h"

@interface PasswordGetter () <DialogPasswordDelegate> {
    NSString *password;
    NSCondition *condition;
}
@end

@implementation PasswordGetter

- (instancetype)initWithWindow:(UIWindow *)window {
    self = [super init];
    if (self) {
        self.window = window;
        condition = [NSCondition new];
    }
    return self;
}

- (instancetype)initWithWindow:(UIWindow *)window andDelegate:(NSObject <PasswordGetterDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.window = window;
        self.delegate = delegate;
        condition = [NSCondition new];
    }
    return self;
}

- (NSString *)password {
    if (!password) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(beforePasswordDialogShow)]) {
                [self.delegate beforePasswordDialogShow];
            }
            [[[DialogPassword alloc] initWithDelegate:self] showInWindow:self.window];
        });
        [condition lock];
        [condition wait];
        [condition unlock];
    }
    return password;
}

- (void)setPassword:(NSString *)p {
    password = p;
}

- (BOOL)hasPassword {
    return password != nil;
}

- (void)onPasswordEntered:(NSString *)p {
    password = p;
    [self signalReturn];
}

- (void)signalReturn {
    [condition lock];
    [condition signal];
    [condition unlock];
    if (self.delegate && [self.delegate respondsToSelector:@selector(afterPasswordDialogDismiss)]) {
        [self.delegate afterPasswordDialogDismiss];
    }
}

- (void)dialogPasswordCanceled {
    password = nil;
    [self signalReturn];
}

@end
