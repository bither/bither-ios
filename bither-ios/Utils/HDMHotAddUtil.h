//
//  HDMHotAddUtil.h
//  bither-ios
//
//  Created by 宋辰文 on 15/2/2.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDMSingular.h"

@protocol HDMHotAddUtilDelegate
- (void)moveToHot:(BOOL)anim andCompletion:(void (^)())completion;

- (void)moveToCold:(BOOL)anim andCompletion:(void (^)())completion;

- (void)moveToServer:(BOOL)anim andCompletion:(void (^)())completion;

- (void)moveToFinal:(BOOL)animToFinish andCompletion:(void (^)())completion;

- (void)setSingularModeAvailable:(BOOL)available;

- (void)onSingularModeBegin;

- (BOOL)shouldGoSingularMode;

- (void)singularServerFinishWithWords:(NSArray *)words andColdQr:(NSString *)qr;

- (void)singularShowNetworkFailure;

- (void)showMsg:(NSString *)msg;
@end

@interface HDMHotAddUtil : NSObject <HDMSingularDelegate>
- (instancetype)initWithViewContoller:(UIViewController <HDMHotAddUtilDelegate> *)controller;

- (void)hot;

- (void)cold;

- (void)server;

- (void)refreshHDMLimit;

@property(readonly) BOOL isHDMKeychainLimited;
@property(readonly) BOOL canCancel;
@end
