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
#import "UEntropyCollector.h"
#import "NSString+Base58.h"

@interface UEntropyViewController ()<UEntropyDelegate>
@property UEntropyCollector* collector;
@end

@implementation UEntropyViewController

- (instancetype)init{
    self = [super init];
    if(self){
    }
    return self;
}

-(void)configureOverlay{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collector = [[UEntropyCollector alloc]initWithDelegate:self];
    [self.collector addSource:[[UEntropyCamera alloc]initWithViewController:self.view andCollector:self.collector],
                                [[UEntropyMic alloc]initWithView:nil andCollector:self.collector],
                                nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.collector onResume];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"start generate");
        [self.collector start];
        for(int i = 0; i < 20; i++){
            NSData* data = [self.collector nextBytes:32];
            NSLog(@"outcome %d data %@", i + 1, [NSString hexWithData:data]);
        }
        [self.collector stop];
        NSLog(@"end generate");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.collector onPause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)onNoSourceAvailable{
    NSLog(@"no source available");
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
