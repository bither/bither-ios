//
//  HotCheckPrivateKeyViewController.m
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

#import "HotCheckPrivateKeyViewController.h"
#import "CheckViewController.h"
#import "BitherSetting.h"

@interface HotCheckPrivateKeyViewController ()

@property(weak, nonatomic) IBOutlet UIView *topBar;

@end

@implementation HotCheckPrivateKeyViewController

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CheckViewController *checkViewController = (CheckViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"tab_check"];
    [self addChildViewController:checkViewController];
    [self.view insertSubview:checkViewController.view atIndex:0];
    checkViewController.view.frame = CGRectMake(0, TabBarHeight, self.view.frame.size.width, self.view.frame.size.height - TabBarHeight);
}

@end
