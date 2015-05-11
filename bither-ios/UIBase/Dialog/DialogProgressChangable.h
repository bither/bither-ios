//
//  DialogProgressChangable.h
//  bither-ios
//
//  Created by noname on 14-10-22.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "DialogCentered.h"

@interface DialogProgressChangable : DialogCentered

- (id)initWithMessage:(NSString *)message;

- (void)changeToMessage:(NSString *)message icon:(UIImage *)icon completion:(void (^)())completion;

- (void)changeToMessage:(NSString *)message completion:(void (^)())completion;

- (void)changeToMessage:(NSString *)message;

- (void)changeToMessage:(NSString *)message icon:(UIImage *)icon;
@end
