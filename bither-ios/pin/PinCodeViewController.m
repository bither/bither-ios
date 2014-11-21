//
//  PinCodeViewController.m
//  bither-ios
//
//  Created by noname on 14-11-21.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "PinCodeViewController.h"
#import "PinCodeEnterView.h"
#import "UIViewController+PiShowBanner.h"
#import "UIViewController+SwipeRightToPop.h"
#import "UserDefaultsUtil.h"

@interface PinCodeViewController ()<PinCodeEnterViewDelegate>{
    UserDefaultsUtil *d;
}

@property (weak, nonatomic) IBOutlet PinCodeEnterView *vEnter;
@end

@implementation PinCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    d = [UserDefaultsUtil instance];
    self.shouldSwipeRightToPop = NO;
    self.vEnter.delegate = self;
    [self.vEnter becomeFirstResponder];
}

-(void)onEntered:(NSString*) code{
    
}

-(void)showMsg:(NSString*)msg{
    [self showBannerWithMessage:msg belowView:nil belowTop:0 autoHideIn:1 withCompletion:nil];
}

@end
