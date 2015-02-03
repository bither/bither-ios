//
//  HDMHotAddUtil.h
//  bither-ios
//
//  Created by 宋辰文 on 15/2/2.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol HDMHotAddUtilDelegate
-(void)moveToHot:(BOOL) anim;
-(void)moveToCold:(BOOL) anim;
-(void)moveToServer:(BOOL) anim;
-(void)moveToFinal:(BOOL) animToFinish;
-(void)showMsg:(NSString*)msg;
@end

@interface HDMHotAddUtil : NSObject
-(instancetype)initWithViewContoller:(UIViewController<HDMHotAddUtilDelegate>*)controller;
-(void)hot;
-(void)cold;
-(void)server;
-(void)refreshHDMLimit;
@property (readonly) BOOL isHDMKeychainLimited;
@end
