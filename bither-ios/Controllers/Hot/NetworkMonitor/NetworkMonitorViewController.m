//  NetworkMonitorViewController.m
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


#import "NetworkMonitorViewController.h"
#import "PiPageViewController.h"
#import "DialogNetworkMonitorOption.h"

@interface NetworkMonitorViewController () <PiPageViewControllerDelegate>

@property(strong, nonatomic) PiPageViewController *page;
@property(weak, nonatomic) IBOutlet UISegmentedControl *vTab;
@property(weak, nonatomic) IBOutlet UIView *vTopBar;

@end

@implementation NetworkMonitorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)configurePage {
    self.page = [[PiPageViewController alloc] initWithStoryboard:self.storyboard andViewControllerIdentifiers:[[NSArray alloc] initWithObjects:@"PeerViewController", @"BlockViewController", nil]];
    self.page.pageDelegate = self;
    [self addChildViewController:self.page];
    self.page.view.frame = CGRectMake(0, CGRectGetMaxY(self.vTopBar.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.vTopBar.frame));
    [self.view insertSubview:self.page.view atIndex:0];
    self.vTab.selectedSegmentIndex = 0;
}

- (IBAction)optionPressed:(id)sender {
    [[[DialogNetworkMonitorOption alloc] init] showInWindow:self.view.window];
}

- (void)pageIndexChanged:(int)index {
    self.vTab.selectedSegmentIndex = index;
}

- (IBAction)tabChanged:(id)sender {
    if (self.vTab.selectedSegmentIndex != self.page.index) {
        [self.page setIndex:(int) self.vTab.selectedSegmentIndex animated:YES];
    }
}
@end















