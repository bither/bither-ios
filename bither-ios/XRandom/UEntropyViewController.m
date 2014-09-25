//
//  UEntropyViewController.m
//  bither-ios
//
//  Created by noname on 14-9-24.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "UEntropyViewController.h"
#import "UEntropyCamera.h"
#import "UEntropyCollector.h"

@interface UEntropyViewController ()
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
    self.collector = [[UEntropyCollector alloc]init];
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

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
