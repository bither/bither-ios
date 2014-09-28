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
#import "AudioVisualizerView.h"
#import "SensorVisualizerView.h"
#import "NSString+Base58.h"
#import "UIColor+Util.h"

#define kMicViewHeight (100)
#define kSaveProgress (0.1)
#define kStartProgress (0.01)
#define kProgressKeyRate (0.5)
#define kProgressEntryptRate (0.5)
#define kMinGeneratingTime (5)

@interface UEntropyViewController ()<UEntropyDelegate>{
    NSString* password;
    NSUInteger count;
    BOOL isFinishing;
    void(^cancelBlock)();
    DialogProgress *dpStopping;
    UIProgressView *pv;
    UIView *vOverlayTop;
    UIView *vOverlayBottom;
    UIImageView* ivOverlayTop;
    UIImageView* ivOverlayBottom;
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
    UIView *dimmer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    dimmer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    dimmer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:dimmer];
    
    AudioVisualizerView* vMic = [[AudioVisualizerView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - kMicViewHeight, self.view.frame.size.width, kMicViewHeight)];
    vMic.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:vMic];
    SensorVisualizerView* vSensor = [[SensorVisualizerView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(vMic.frame) - kSensorVisualizerViewItemSize - 10, self.view.frame.size.width, kSensorVisualizerViewItemSize)];
    vSensor.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:vSensor];
    
    self.collector = [[UEntropyCollector alloc]initWithDelegate:self];
    [self.collector addSource:  [[UEntropyCamera alloc] initWithViewController: self.view andCollector: self.collector],
                                [[UEntropyMic alloc] initWithView: vMic andCollector: self.collector],
                                [[UEntropySensor alloc] initWithView: vSensor andCollecor: self.collector],
                                nil];
    dpStopping = [[DialogProgress alloc]initWithMessage:NSLocalizedString(@"xrandom_stopping", nil)];
    [self configureOverlay];
}

-(void)configureOverlay{
    pv = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    pv.progressTintColor = [[UIColor parseColor:0x7ce24d] colorWithAlphaComponent:0.8];
    pv.trackTintColor = [UIColor clearColor];
    pv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    pv.progress = 0;
    [self.view addSubview:pv];
    
    UIButton* btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose setImage:[UIImage imageNamed:@"scan_cancel"] forState:UIControlStateNormal];
    [btnClose setImage:[UIImage imageNamed:@"scan_cancel_pressed"] forState:UIControlStateHighlighted];
    [btnClose addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [btnClose sizeToFit];
    btnClose.frame = CGRectMake(10, 10, btnClose.frame.size.width, btnClose.frame.size.height);
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
    [self startGenerate];
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

-(void)onProgress:(float)progress{
    dispatch_async(dispatch_get_main_queue(), ^{
        [pv setProgress:progress animated:YES];
    });
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
        float progress = kStartProgress;
        float itemProgress = (1.0 - kStartProgress - kSaveProgress) / (float) count;
        NSTimeInterval startGeneratingTime = [[NSDate date] timeIntervalSince1970];
        [self.collector start];
        [self onProgress:progress];
        for(int i = 0; i < count; i++){
            if(cancelBlock){
                [self.collector stop];
                [self.collector onPause];
                dispatch_async(dispatch_get_main_queue(), cancelBlock);
                return;
            }
            NSData* data = [self.collector nextBytes:32];
            if(data){
                NSLog(@"uentropy outcome data %d/%lu", i + 1, count);
                progress += itemProgress * kProgressKeyRate;
                [self onProgress:progress];
                if(cancelBlock){
                    [self.collector stop];
                    [self.collector onPause];
                    dispatch_async(dispatch_get_main_queue(), cancelBlock);
                    return;
                }
                
                sleep(1);
                //TODO new key
                progress += itemProgress * kProgressEntryptRate;
                [self onProgress:progress];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self onFailed];
                });
                return;
            }
            
        }
        if(cancelBlock){
            [self.collector stop];
            [self.collector onPause];
            dispatch_async(dispatch_get_main_queue(), cancelBlock);
            return;
        }
        [self.collector stop];
        [self.collector onPause];
        //TODO save
        while ([[NSDate new] timeIntervalSince1970] - startGeneratingTime < kMinGeneratingTime) {
            
        }
        [self onProgress:1];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onSuccess];
        });
    });
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
