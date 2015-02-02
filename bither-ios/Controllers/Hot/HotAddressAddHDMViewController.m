//
//  HotAddressAddHDMViewController.m
//  bither-ios
//
//  Created by 宋辰文 on 15/2/2.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import "HotAddressAddHDMViewController.h"
#import "UIViewController+PiShowBanner.h"
#import "HDMHotAddUtil.h"

@interface HotAddressAddHDMViewController ()<HDMHotAddUtilDelegate>
@property (weak, nonatomic) IBOutlet UIView *vContainer;
@property (weak, nonatomic) IBOutlet UIView *vBg;
@property (weak, nonatomic) IBOutlet UIImageView *ivHotLight;
@property (weak, nonatomic) IBOutlet UIImageView *ivColdLight;
@property (weak, nonatomic) IBOutlet UIImageView *ivServerLight;
@property (weak, nonatomic) IBOutlet UIButton *btnHot;
@property (weak, nonatomic) IBOutlet UIButton *btnCold;
@property (weak, nonatomic) IBOutlet UIButton *btnServer;
@property (weak, nonatomic) IBOutlet UILabel *lblHot;
@property (weak, nonatomic) IBOutlet UILabel *lblCold;
@property (weak, nonatomic) IBOutlet UILabel *lblServer;

@property HDMHotAddUtil* util;
@end

@implementation HotAddressAddHDMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.util = [[HDMHotAddUtil alloc]initWithViewContoller:self];
}

-(void)moveToHot:(BOOL)anim{

}

-(void)moveToCold:(BOOL)anim{

}

-(void)moveToServer:(BOOL)anim{

}

-(void)moveToFinal:(BOOL)animToFinish{

}

- (IBAction)hotPressed:(id)sender {
}

- (IBAction)coldPressed:(id)sender {
}

- (IBAction)serverPressed:(id)sender {
}

- (IBAction)hdmInfoPressed:(id)sender {
}

-(void)showMsg:(NSString*)msg{
    [self showBannerWithMessage:msg belowView:nil belowTop:0 autoHideIn:1 withCompletion:nil];
}
@end
