//
//  HDMHotAddUtil.m
//  bither-ios
//
//  Created by 宋辰文 on 15/2/2.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import "HDMHotAddUtil.h"

@interface HDMHotAddUtil()
@property (weak) UIViewController<HDMHotAddUtilDelegate>* controller;
@end

@implementation HDMHotAddUtil
-(instancetype)initWithViewContoller:(UIViewController<HDMHotAddUtilDelegate>*)controller{
    self = [super init];
    if(self){
        self.controller = controller;
    }
    return self;
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
@end
