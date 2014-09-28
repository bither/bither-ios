//
//  UEntropyViewController.m
//  bither-ios
//
//  Copyright 2014 http://Bither.net
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "UEntropyViewController.h"
#import "UEntropyCamera.h"
#import "UEntropyMic.h"
#import "UEntropySensor.h"
#import "UEntropyCollector.h"
#import "DialogAlert.h"
#import "DialogProgress.h"

@interface UEntropyViewController ()<UEntropyDelegate>{
    NSString* password;
    NSUInteger count;
    BOOL isFinishing;
    void(^cancelBlock)();
    DialogProgress *dpStopping;
}
@property UEntropyCollector* collector;
@end

@implementation UEntropyViewController

-(instancetype)initWithCount:(NSUInteger)inCount password:(NSString*)inPassword{
    self = [super init];
    if(self){
        password = inPassword;
        count = inCount;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collector = [[UEntropyCollector alloc]initWithDelegate:self];
    [self.collector addSource:  [[UEntropyCamera alloc] initWithViewController: self.view andCollector: self.collector],
                                [[UEntropyMic alloc] initWithView: nil andCollector: self.collector],
                                [[UEntropySensor alloc] initWithCollecor: self.collector],
                                nil];
    [self configureOverlay];
    dpStopping = [[DialogProgress alloc]initWithMessage:NSLocalizedString(@"xrandom_stopping", nil)];
}

-(void)configureOverlay{
    UIButton* btnClose = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnClose setTitle:@"Close" forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [btnClose sizeToFit];
    btnClose.frame = CGRectMake(0, 0, btnClose.frame.size.width, btnClose.frame.size.height);
    [self.view addSubview:btnClose];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self.collector onResume];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.collector onPause];
    [self.collector stop];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[self startGenerate];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)close:(id)sender{
    if(isFinishing){
        return;
    }
    __block __weak UEntropyViewController* c = self;
    __block __weak DialogProgress* dp = dpStopping;
    [[[DialogAlert alloc]initWithMessage:NSLocalizedString(@"xrandom_cancel_confirm", nil) confirm:^{
        isFinishing = YES;
        [dp showInWindow:self.view.window completion:^{
            cancelBlock = ^{
                [dp dismissWithCompletion:^{
                    [c dismissViewControllerAnimated:YES completion:nil];
                }];
            };
        }];
    } cancel:nil]showInWindow:self.view.window];
}

-(void)onNoSourceAvailable{
    [self.collector onPause];
    NSLog(@"no source available");
}

-(void)onProgress:(double)progress{
    
}

-(void)onSuccess{
    isFinishing = YES;
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)onFailed{
    isFinishing = YES;
    void(^block)() = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    NSString* msg;
    if(self.collector.sources.count == 0){
        msg = NSLocalizedString(@"xrandom_no_source", nil);
    }else{
        msg = NSLocalizedString(@"xrandom_generating_failed", nil);
    }
    [[[DialogAlert alloc]initWithMessage:msg confirm:block cancel:block] showInWindow:self.view.window];
}

-(void)startGenerate{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.collector start];
        for(int i = 0; i < count; i++){
            if(cancelBlock){
                [self.collector stop];
                dispatch_async(dispatch_get_main_queue(), cancelBlock);
                return;
            }
            NSData* data = [self.collector nextBytes:32];
            if(data){
                NSLog(@"uentropy outcome data %d/%lu", i + 1, count);
                //TODO new key
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self onFailed];
                });
                return;
            }
            
        }
        if(cancelBlock){
            [self.collector stop];
            dispatch_async(dispatch_get_main_queue(), cancelBlock);
            return;
        }
        //TODO save
        [self.collector stop];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onSuccess];
        });
    });
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
