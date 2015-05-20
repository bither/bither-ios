//
//  CropImageViewController.m
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


#import "CropImageViewController.h"
#import "ImageCropView.h"

@interface CropImageViewController ()
@property(nonatomic, strong) NSDictionary *info;
@property(nonatomic, strong) ImageCropView *icv;
@end

@implementation CropImageViewController
- (id)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        self.info = info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.leftItemsSupplementBackButton = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)];
    self.navigationItem.title = NSLocalizedString(@"Move And Scale", @"Crop Image");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];
    self.icv = [[ImageCropView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.icv];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.icv.image = [self.info objectForKey:UIImagePickerControllerOriginalImage];
}

- (void)cancelPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}

- (void)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.info setValue:self.icv.croppedImage forKey:UIImagePickerControllerEditedImage];
        [self.delegate imagePickerController:(UIImagePickerController *) self.navigationController didFinishPickingMediaWithInfo:self.info];
    }];
}

@end
