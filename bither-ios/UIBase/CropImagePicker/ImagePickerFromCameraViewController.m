//
//  ImagePickerWithPhotoViewController.m
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


#import "ImagePickerFromCameraViewController.h"
#import "UIViewController+SwipeRightToPop.h"
#import "CropImageViewController.h"

@interface ImagePickerFromCameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ImagePickerFromCameraViewController
- (id)init {
    self = [super init];
    if (self) {
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.delegate = self;
        self.shouldSwipeRightToPop = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    CropImageViewController *cropImage = [[CropImageViewController alloc] initWithInfo:info];
    cropImage.delegate = self.cropDelegate;
    [self pushViewController:cropImage animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.cropDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
            [self.cropDelegate imagePickerControllerDidCancel:self];
        }

    }];
}


@end
