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

#import "RawPrivateKeyViewController.h"
#import "RawDataView.h"

@interface RawPrivateKeyViewController ()
@property (weak, nonatomic) IBOutlet UIView *vTopbar;

@property (weak, nonatomic) IBOutlet UIView *vInput;
@property (weak, nonatomic) IBOutlet RawDataView *vData;
@property (weak, nonatomic) IBOutlet UIView *vButtons;

@property (weak, nonatomic) IBOutlet UIView *vShow;
@property (weak, nonatomic) IBOutlet UILabel *lblPrivateKey;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;

@end

@implementation RawPrivateKeyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.vData.restrictedSize = CGSizeMake(self.vData.frame.size.width, self.vInput.frame.size.height * 0.52f);
    self.vData.dataSize = CGSizeMake(16, 16);
    self.vButtons.frame = CGRectMake(self.vButtons.frame.origin.x, CGRectGetMaxY(self.vData.frame), self.vButtons.frame.size.width, self.vInput.frame.size.height - CGRectGetMaxY(self.vData.frame));
}

-(void)addData:(BOOL)d{
    if(self.vData.filledDataLength < self.vData.dataLength){
        [self.vData addData:d];
    }
}

- (IBAction)zeroPressed:(id)sender {
    [self addData:NO];
}

- (IBAction)onePressed:(id)sender {
    [self addData:YES];
}

- (IBAction)addPressed:(id)sender {
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
