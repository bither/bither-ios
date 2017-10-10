//
//  DetectAnotherAssetsUtil.m
//  bither-ios
//
//  Created by LTQ on 2017/9/27.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "DetectAnotherAssetsUtil.h"
#import "DialogProgress.h"
#import "BitherApi.h"
#import "BccUnspentOutput.h"
#import "BTOut.h"
#import "DialogAlert.h"
#import "UnitUtil.h"
#import "BccDetectMonitoredDetailViewController.h"
#import "BccDetectDetailViewController.h"

static DetectAnotherAssetsUtil *detectAnotherAssets;

@interface DetectAnotherAssetsUtil()

@property(nonatomic, strong)DialogProgress *dp;
@property(nonatomic, strong)NSString *address;
@end

@implementation DetectAnotherAssetsUtil

+(DetectAnotherAssetsUtil *)instance{
    @synchronized (self) {
        
        if (detectAnotherAssets == nil) {
            detectAnotherAssets = [[self alloc] init];
        }
    }
    return detectAnotherAssets;
}

-(void) getBCCUnspentOutputs:(NSString *) address andBTAddress:(BTAddress *) btAddress andIsPrivate:(BOOL) isPrivate{
    self.address = address;
    DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    [dp showInWindow:_controller.view.window];
    [[BitherApi instance]getBccUnspendOutput:address callback:^(NSArray *array) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[BccUnspentOutput getBTOuts:[BccUnspentOutput getBccUnspentOuts:array]]];
        [self extractBcc:arr andBTAddress: btAddress andIsPrivate:isPrivate];
        [dp dismiss];
    } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
        [dp dismiss];
        return ;
    }];
}

-(void) getBCCHDUnspentOutputs:(NSString *)address andPathType:(PathTypeIndex*) pathTypeIndex andIsMonitored:(BOOL) isMonitored {
    self.address = address;
    DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    [dp showInWindow:_controller.view.window];
    [[BitherApi instance]getBccUnspendOutput:address callback:^(NSArray *array) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[BccUnspentOutput getBTOuts:[BccUnspentOutput getBccUnspentOuts:array]]];
        [self extractHDBcc:arr andPathType:pathTypeIndex andIsMonitored:isMonitored];
        [dp dismiss];
    } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
        [dp dismiss];
        return ;
    }];
}

# pragma mark private
-(void) extractBcc:(NSArray *) btOuts andBTAddress:(BTAddress *) btAddress andIsPrivate:(BOOL) isPrivate {
    DialogAlert *alert;
    if ([self getAmount:btOuts] > 0) {
        NSString * s= [UnitUtil stringForAmount:[self getAmount:btOuts] unit:UnitBTC];
        alert = [[DialogAlert alloc]initWithMessage:[NSString localizedStringWithFormat:NSLocalizedString(@"detect_exist_another_assets_alert", nil), s,@"BCC"]
                                            confirm:^{
                                                UIViewController *vc;
                                                if (isPrivate) {
                                                    BccDetectDetailViewController *bccVc = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"BccDetectDetailViewController"];
                                                                        bccVc.btAddress= btAddress;
                                                    
                                                    bccVc.amount = [self getAmount:btOuts];
                                                    bccVc.outs = btOuts;
                                                    bccVc.isHDAccount = false;
                                                    bccVc.sendDelegate = _controller;
                                                    vc = bccVc;
                                                    
                                                    UINavigationController *nav = self.controller.navigationController;
                                                    [nav pushViewController:vc animated:YES];
                                            } else {
                                                BccDetectMonitoredDetailViewController *bccVc = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"BccDetectMonitoredDetailViewController"];
                                                bccVc.btAddress = btAddress;
                                                bccVc.isHDAccount = false;
                                                bccVc.amount = [self getAmount:btOuts];
                                                bccVc.outs = btOuts;
                                                bccVc.sendDelegate = _controller;
                                                vc = bccVc;
                                                
                                                UINavigationController *nav = self.controller.navigationController;
                                                [nav pushViewController:vc animated:YES];
                                            }
                 } cancel:^{
                     
                 }];
        
        [alert showInWindow:_controller.view.window];
    }else {
        alert = [[DialogAlert alloc]initWithMessage:NSLocalizedString(@"detect_no_assets_alert", nil) confirm:^{} cancel:^{}];
        [alert showInWindow:_controller.view.window];
    }
}

-(void) extractHDBcc:(NSArray *) btOuts andPathType:(PathTypeIndex*) pathTypeIndex andIsMonitored:(BOOL) isMonitored{
    DialogAlert *alert;
    if ([self getAmount:btOuts] > 0) {
        NSString * s= [UnitUtil stringForAmount:[self getAmount:btOuts] unit:UnitBTC];
        alert = [[DialogAlert alloc]initWithMessage:[NSString localizedStringWithFormat:NSLocalizedString(@"detect_exist_another_assets_alert", nil), s,@"BCC"]
                                            confirm:^{
                                                UIViewController *vc;
                                                if (isMonitored) {
                                                    
                                                    BccDetectMonitoredDetailViewController *bccVc = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"BccDetectMonitoredDetailViewController"];
                                                    bccVc.amount = [self getAmount:btOuts];
                                                    bccVc.outs = btOuts;
                                                    bccVc.pathTypeIndex = pathTypeIndex ;
                                                    bccVc.isHDAccount = true;
                                                    bccVc.address = self.address;
                                                    bccVc.sendDelegate = _controller;
                                                    vc = bccVc;
                                                    
                                                    UINavigationController *nav = self.controller.navigationController;
                                                    [nav pushViewController:vc animated:YES];
                                                } else {
                                                    BccDetectDetailViewController *bccVc = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"BccDetectDetailViewController"];                                                    
                                                    bccVc.amount = [self getAmount:btOuts];
                                                    bccVc.outs = btOuts;
                                                    bccVc.pathTypeIndex = pathTypeIndex ;
                                                    bccVc.isHDAccount = true;
                                                    bccVc.sendDelegate = _controller;
                                                    vc = bccVc;
                                                    
                                                    UINavigationController *nav = self.controller.navigationController;
                                                    [nav pushViewController:vc animated:YES];
                                                }
                                            } cancel:^{
                                                
                                            }];
        
        [alert showInWindow:_controller.view.window];
    }else {
        alert = [[DialogAlert alloc]initWithMessage:NSLocalizedString(@"detect_no_assets_alert", nil) confirm:^{} cancel:^{}];
        [alert showInWindow:_controller.view.window];
    }
}

-(u_int64_t)getAmount:(NSArray *) outs{
    long amount = 0;
    for (BTOut *btout in outs) {
        amount += btout.outValue;
    }
    return amount;
}

@end
