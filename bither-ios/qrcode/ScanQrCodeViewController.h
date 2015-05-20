//
//  ScanQrCodeViewController.h
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ScanQrCodeViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property(strong, nonatomic) NSString *scanTitle;
@property(strong, nonatomic) NSString *scanMessage;
@property UIButton *btnGallery;

@end


@protocol ScanQrCodeDelegate

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader;

@optional
- (void)handleScanCancelByReader:(ScanQrCodeViewController *)reader;
@end


@interface ScanQrCodeViewController ()

- (instancetype)initWithDelegate:(NSObject <ScanQrCodeDelegate> *)delegate;

- (instancetype)initWithDelegate:(NSObject <ScanQrCodeDelegate> *)delegate title:(NSString *)title message:(NSString *)message;

@property(weak) NSObject <ScanQrCodeDelegate> *scanDelegate;
@end

@interface ScanQrCodeViewController (Functions)

- (void)vibrate;

- (void)playSuccessSound;

@end
