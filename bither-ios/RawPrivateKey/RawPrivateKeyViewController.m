//
//  RawPrivateKeyViewController.m
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
//
//  Created by songchenwen on 2015/3/21.
//

#import "RawPrivateKeyViewController.h"
#import "PiPageViewController.h"

@interface RawPrivateKeyViewController () <PiPageViewControllerDelegate>
@property(weak, nonatomic) IBOutlet UISegmentedControl *vTab;
@property PiPageViewController *page;
@end

@implementation RawPrivateKeyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = [[PiPageViewController alloc] initWithStoryboard:self.storyboard viewControllerIdentifiers:@[@"RawPrivateKeyDice", @"RawPrivateKeyBinary"] andPageDelegate:self];
    [self addChildViewController:self.page];
    self.page.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view insertSubview:self.page.view atIndex:0];
    self.vTab.selectedSegmentIndex = 0;
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pageIndexChanged:(int)index {
    self.vTab.selectedSegmentIndex = index;
}

- (IBAction)tabChanged:(UISegmentedControl *)sender {
    [self.page setIndex:sender.selectedSegmentIndex animated:YES];
}

@end
