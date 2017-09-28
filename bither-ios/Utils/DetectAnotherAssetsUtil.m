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

static DetectAnotherAssetsUtil *detectAnotherAssets;

@interface DetectAnotherAssetsUtil()

@property(nonatomic, strong)DialogProgress *dp;

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

-(void) getBCCUnspentOutputs:(NSString *) address andPosition:(int) position andIsPrivate:(Boolean) isPrivate{
        DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    [dp showInWindow:_controller.view.window];
    [[BitherApi instance]getBccUnspendOutput:address callback:^(NSArray *array) {
      NSMutableArray *arr = [NSMutableArray arrayWithArray:[BccUnspentOutput getBTOuts:[BccUnspentOutput getBccUnspentOuts:array]]];
        [self extractBcc:arr andPosition:position andIsPrivate:isPrivate];
        [dp dismiss];
    } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
        [dp dismiss];
        return ;
    }];
}

-(void) getBCCHDUnspentOutputs:(NSString *)address andPathType:(PathTypeIndex*) pathTypeIndex andIsMonitored:(BOOL) isMonitored {
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
-(void) extractBcc:(NSArray *) extractBccUtxos andPosition:(int) position andIsPrivate:(Boolean) isPrivate {
    DialogAlert *alert;
    if ([self getAmount:extractBccUtxos] > 0) {
        NSString * s= [UnitUtil stringForAmount:[self getAmount:extractBccUtxos] unit:UnitBTC];
        alert = [[DialogAlert alloc]initWithMessage:[NSString localizedStringWithFormat:NSLocalizedString(@"detect_exist_another_assets_alert", nil), s,@"BCC"]
                                            confirm:^{
                                                if (isPrivate) {
                                                    
                                                } else {
                                                    
                                                }
                                            } cancel:^{
                                                
                                            }];
        
        [alert showInWindow:_controller.view.window];
    }else {
        alert = [[DialogAlert alloc]initWithMessage:NSLocalizedString(@"detect_no_assets_alert", nil) confirm:^{} cancel:^{}];
        [alert showInWindow:_controller.view.window];
    }
}

-(void) extractHDBcc:(NSArray *) extractBccUtxos andPathType:(PathTypeIndex*) pathTypeIndex andIsMonitored:(BOOL) isMonitored{
    DialogAlert *alert;
    if ([self getAmount:extractBccUtxos] > 0) {
        NSString * s= [UnitUtil stringForAmount:[self getAmount:extractBccUtxos] unit:UnitBTC];
        alert = [[DialogAlert alloc]initWithMessage:[NSString localizedStringWithFormat:NSLocalizedString(@"detect_exist_another_assets_alert", nil), s,@"BCC"]
                                            confirm:^{
                                                if (isMonitored) {
                                                    
                                                } else {
                                                    
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
