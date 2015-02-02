//
//  HDMHotAddUtil.m
//  bither-ios
//
//  Created by 宋辰文 on 15/2/2.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import "HDMHotAddUtil.h"
#import "DialogProgress.h"
#import "PasswordGetter.h"

@interface HDMHotAddUtil()<PasswordGetterDelegate>{
    PasswordGetter* passwordGetter;
    DialogProgress *dp;
}
@property (weak) UIViewController<HDMHotAddUtilDelegate>* controller;
@end

@implementation HDMHotAddUtil
-(instancetype)initWithViewContoller:(UIViewController<HDMHotAddUtilDelegate>*)controller{
    self = [super init];
    if(self){
        self.controller = controller;
        [self firstConfigure];
    }
    return self;
}

-(void)firstConfigure{
    dp = [[DialogProgress alloc]initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    dp.touchOutSideToDismiss = NO;
    passwordGetter = [[PasswordGetter alloc]initWithWindow:self.controller.view.window andDelegate:self];
}

-(void)hot{

}

-(void)cold{

}

-(void)server{

}

-(void)showMsg:(NSString*)msg{
    if(self.controller && [self.controller respondsToSelector:@selector(showMsg:)]){
        [self.controller performSelector:@selector(showMsg:) withObject:msg];
    }
}

-(void)beforePasswordDialogShow{
    if(dp.shown){
        [dp dismiss];
    }
}

-(void)afterPasswordDialogDismiss{
    if(!dp.shown){
        [dp showInWindow:self.controller.view.window];
    }
}
@end
