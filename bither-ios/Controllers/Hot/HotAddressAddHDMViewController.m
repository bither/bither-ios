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
#import "HDMTriangleBgView.h"

@interface HotAddressAddHDMViewController () <HDMHotAddUtilDelegate>{
    UIImageView* flashingIv;
}
@property(weak, nonatomic) IBOutlet UIView *vContainer;
@property(weak, nonatomic) IBOutlet HDMTriangleBgView *vBg;
@property(weak, nonatomic) IBOutlet UIImageView *ivHotLight;
@property(weak, nonatomic) IBOutlet UIImageView *ivColdLight;
@property(weak, nonatomic) IBOutlet UIImageView *ivServerLight;
@property(weak, nonatomic) IBOutlet UIButton *btnHot;
@property(weak, nonatomic) IBOutlet UIButton *btnCold;
@property(weak, nonatomic) IBOutlet UIButton *btnServer;
@property(weak, nonatomic) IBOutlet UILabel *lblHot;
@property(weak, nonatomic) IBOutlet UILabel *lblCold;
@property(weak, nonatomic) IBOutlet UILabel *lblServer;

@property HDMHotAddUtil *util;
@end

@implementation HotAddressAddHDMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!self.util){
        self.util = [[HDMHotAddUtil alloc] initWithViewContoller:self];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showFlash:flashingIv];
}

- (void)moveToHot:(BOOL)anim {
    self.btnHot.enabled = YES;
    self.btnHot.selected = NO;
    self.btnCold.enabled = NO;
    self.btnCold.selected = NO;
    self.btnServer.enabled = NO;
    self.btnServer.selected = NO;
    [self showFlash:self.ivHotLight];
}

- (void)moveToCold:(BOOL)anim {
    self.btnHot.enabled = NO;
    self.btnHot.selected = YES;
    self.btnServer.enabled = NO;
    self.btnServer.selected = NO;
    self.btnCold.selected = NO;
    if (!anim) {
        [self.vBg addLineFromView:self.btnHot toView:self.btnCold];
        self.btnCold.enabled = YES;
        [self showFlash:self.ivColdLight];
    } else {
        [self stopAllFlash];
        [self.vBg addLineAnimatedFromView:self.btnHot toView:self.btnCold completion:^{
            [self showFlash:self.ivColdLight];
            self.btnCold.enabled = YES;
        }];
    }
}

- (void)moveToServer:(BOOL)anim {
    if (self.btnServer.enabled) {
        return;
    }
    self.btnHot.enabled = NO;
    self.btnHot.selected = YES;
    self.btnCold.enabled = NO;
    self.btnCold.selected = YES;
    self.btnServer.selected = NO;
    if (!anim) {
        [self.vBg addLineFromView:self.btnCold toView:self.btnServer];
        self.btnServer.enabled = YES;
        [self showFlash:self.ivServerLight];
    } else {
        [self stopAllFlash];
        [self.vBg addLineAnimatedFromView:self.btnCold toView:self.btnServer completion:^{
            [self showFlash:self.ivServerLight];
            self.btnServer.enabled = YES;
        }];
    }
}

- (void)moveToFinal:(BOOL)animToFinish {
    [self.util refreshHDMLimit];
    self.btnHot.enabled = NO;
    self.btnHot.selected = YES;
    self.btnCold.enabled = NO;
    self.btnCold.selected = YES;
    self.btnServer.enabled = NO;
    self.btnServer.selected = YES;
    [self stopAllFlash];
    if (!animToFinish) {
        [self.vBg addLineFromView:self.btnServer toView:self.btnHot];
        if (self.util.isHDMKeychainLimited) {
            self.btnHot.enabled = YES;
            self.btnCold.enabled = YES;
            self.btnServer.enabled = YES;
        }
    } else {
        [self.vBg addLineAnimatedFromView:self.btnServer toView:self.btnHot completion:^{
            [self finalAnimation];
        }];
    }
}

- (void)finalAnimation{

}

- (void)stopAllFlash {
    [self showFlash:nil];
}

- (void)showFlash:(UIImageView *)iv {
    flashingIv = iv;
    NSArray *ivs = @[self.ivHotLight, self.ivColdLight, self.ivServerLight];
    for (UIImageView *v in ivs) {
        if (v != iv) {
            [v.layer removeAllAnimations];
            v.hidden = YES;
        }
    }
    if (iv) {
        iv.alpha = 0;
        iv.hidden = NO;
        [UIView animateWithDuration:0.8 delay:0.2 options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
            iv.alpha = 1;
        } completion:nil];
    }
}

- (IBAction)hotPressed:(id)sender {
    [self.util hot];
}

- (IBAction)coldPressed:(id)sender {
    [self.util cold];
}

- (IBAction)serverPressed:(id)sender {
    [self.util server];
}

- (IBAction)hdmInfoPressed:(id)sender {

}

- (void)showMsg:(NSString *)msg {
    [self showBannerWithMessage:msg belowView:nil belowTop:0 autoHideIn:1 withCompletion:nil];
}
@end
