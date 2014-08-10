//
//  ColdAddressAddViewController.m
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

#import "ColdAddressAddViewController.h"
#import "HotAddressAddPrivateKeyViewController.h"
#import "BitherSetting.h"

@interface ColdAddressAddViewController ()
@property (weak, nonatomic) IBOutlet UIView *vTopBar;

@end

@implementation ColdAddressAddViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    HotAddressAddPrivateKeyViewController * ctr = [self.storyboard instantiateViewControllerWithIdentifier:@"HotAddressAddPrivateKey"];
    ctr.limit=PRIVATE_KEY_OF_COLD_COUNT_LIMIT;
    [self addChildViewController:ctr];
    ctr.view.frame = CGRectMake(0, CGRectGetMaxY(self.vTopBar.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.vTopBar.frame));
    [self.view addSubview:ctr.view];
}
- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
