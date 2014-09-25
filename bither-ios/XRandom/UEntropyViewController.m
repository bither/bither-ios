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
#import "UEntropyCollector.h"

@interface UEntropyViewController ()<UEntropyDelegate>
@property UEntropyCollector* collector;
@property UEntropyCamera* camera;
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
    self.camera = [[UEntropyCamera alloc]initWithViewController:self andCollector:self.collector];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.camera onResume];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.camera onPause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)onNoSourceAvailable{
    
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
