//
//  PinCodeChangeViewController.m
//  bither-ios
//
//  Created by noname on 14-11-21.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "PinCodeChangeViewController.h"
#import "PinCodeEnterView.h"
#import "UIViewController+PiShowBanner.h"
#import "UserDefaultsUtil.h"

@interface PinCodeChangeViewController ()<PinCodeEnterViewDelegate>{
    UserDefaultsUtil *d;
}

@property (weak, nonatomic) IBOutlet PinCodeEnterView *vEnter;
@property (weak, nonatomic) IBOutlet UIView *vTopBar;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@end

@implementation PinCodeChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    d = [UserDefaultsUtil instance];
    self.lblTitle.text = NSLocalizedString(@"pin_code_setting_change", nil);
    self.vEnter.delegate = self;
    [self.vEnter becomeFirstResponder];
}

-(void)onEntered:(NSString*) code{
    
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showMsg:(NSString*)msg{
    [self showBannerWithMessage:msg belowView:self.vTopBar];
}

@end
