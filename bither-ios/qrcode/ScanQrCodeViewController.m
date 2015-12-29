//
//  ScanQrCodeViewController.m
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

#import "ScanQrCodeViewController.h"
#import "StringUtil.h"
#import "PlaySoundUtil.h"
#import "UIBaseUtil.h"
#import "UIViewController+SwipeRightToPop.h"
#import "DialogProgress.h"
#import "UIViewController+PiShowBanner.h"
#import "AppDelegate.h"
#import "DialogCentered.h"
#import "DialogWithActions.h"
@interface ScanQrCodeViewController () {
    NSString *_scanTitle;
    NSString *_scanMessage;
    NSString *_lastResult;
    BOOL fromGallery;
}
@property UILabel *lblTitle;
@property UILabel *lblMessage;
@property UIView *vCamera;
@property UIView *cameraOverlayView;
@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@end

@interface ScanQrCodeViewController (CameraOverlay) <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
- (void)configureCameraOverlay;

- (void)updateOverlay;

- (void)messageBreath;
@end

@implementation ScanQrCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.vCamera = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.vCamera.backgroundColor = [UIColor clearColor];
    self.vCamera.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.vCamera];
    [self configureCameraOverlay];
    fromGallery = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusDenied) {
        self.scanTitle = NSLocalizedString(@"Camera Permission Required", nil);
        self.scanMessage = nil;
        return;
    }
    NSError *error = nil;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];

    if (error) NSLog(@"%@", [error localizedDescription]);

    if ([device lockForConfiguration:&error]) {
        if (device.isAutoFocusRangeRestrictionSupported) {
            device.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
        }

        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }

        [device unlockForConfiguration];
    }

    self.session = [AVCaptureSession new];
    if (input) [self.session addInput:input];
    [self.session addOutput:output];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    }

    self.preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = self.view.layer.bounds;
    [self.vCamera.layer addSublayer:self.preview];
    dispatch_async(dispatch_queue_create("scan", NULL), ^{
        [self.session startRunning];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self messageBreath];
}

- (instancetype)initWithDelegate:(NSObject <ScanQrCodeDelegate> *)delegate {
    self = [self initWithDelegate:delegate title:nil message:nil];
    return self;
}

- (instancetype)initWithDelegate:(NSObject <ScanQrCodeDelegate> *)delegate title:(NSString *)title message:(NSString *)message {
    self = [self init];
    if (self) {
        self.scanDelegate = delegate;
        self.scanTitle = title;
        self.scanMessage = message;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.session removeOutput:self.session.outputs.firstObject];
    [self.session stopRunning];
    self.session = nil;
    [self.preview removeFromSuperlayer];
    self.preview = nil;
    [super viewDidDisappear:animated];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (fromGallery) {
        return;
    }
    for (AVMetadataMachineReadableCodeObject *o in metadataObjects) {
        if ([o.type isEqual:AVMetadataObjectTypeQRCode]) {
            NSString *result = o.stringValue;
            if (result && ![StringUtil compareString:result compare:_lastResult] && self.scanDelegate && [self.scanDelegate respondsToSelector:@selector(handleResult:byReader:)]) {
                [self.scanDelegate handleResult:result byReader:self];
            }
            _lastResult = result;
            return;
        }
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setScanTitle:(NSString *)scanTitle {
    _scanTitle = scanTitle;
    [self updateOverlay];
}

- (NSString *)scanTitle {
    return _scanTitle;
}

- (void)setScanMessage:(NSString *)scanMessage {
    _scanMessage = scanMessage;
    [self updateOverlay];
}

- (NSString *)scanMessage {
    return _scanMessage;
}

@end

#define kCancelButtonOffset (10)
#define kCancelButtonWidth (52)
#define kCancelButtonHeight (35)

#define kHorizontalMargin (16)

#define kTitleFontSize (20)
#define kTitleAlpha (0.96f)
#define kTitleFromTop (100)

#define kMessageFontSize (16)
#define kMessageAlpha (0.84f)
#define kMessageFromBottom (100)
#define kMessageBreathDuration (1)
#define kMessageBreathScale (0.96f)

@implementation ScanQrCodeViewController (CameraOverlay)

- (void)configureCameraOverlay {
    self.cameraOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.cameraOverlayView.backgroundColor = [UIColor clearColor];
    self.cameraOverlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.cameraOverlayView];

    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(kCancelButtonOffset, kCancelButtonOffset, kCancelButtonWidth, kCancelButtonHeight)];
    btnCancel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [btnCancel addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnCancel setImage:[UIImage imageNamed:@"scan_cancel"] forState:UIControlStateNormal];
    [btnCancel setImage:[UIImage imageNamed:@"scan_cancel_pressed"] forState:UIControlStateHighlighted];
    [self.cameraOverlayView addSubview:btnCancel];

    UIButton *btnFlash = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - kCancelButtonWidth - kCancelButtonOffset, kCancelButtonOffset, kCancelButtonWidth, kCancelButtonHeight)];
    btnFlash.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [btnFlash addTarget:self action:@selector(flashClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnFlash setImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateSelected];
    [btnFlash setImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
    [btnFlash setBackgroundImage:[UIImage imageNamed:@"scan_overlay_button"] forState:UIControlStateNormal];
    [btnFlash setBackgroundImage:[UIImage imageNamed:@"scan_overlay_button_pressed"] forState:UIControlStateHighlighted];
    [self.cameraOverlayView addSubview:btnFlash];

    UIImage *galleryImage = [UIImage imageNamed:@"scan_from_gallery"];
    self.btnGallery = [[UIButton alloc] initWithFrame:CGRectMake(kCancelButtonOffset, self.cameraOverlayView.frame.size.height - kCancelButtonOffset - galleryImage.size.height, galleryImage.size.width, galleryImage.size.height)];
    [self.btnGallery setImage:galleryImage forState:UIControlStateNormal];
    self.btnGallery.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.btnGallery addTarget:self action:@selector(fromGalleryClick:) forControlEvents:UIControlEventTouchUpInside];
    self.btnGallery.hidden = [[UIDevice currentDevice].systemVersion floatValue] < 8;
    [self.cameraOverlayView addSubview:self.btnGallery];

    self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(kHorizontalMargin, kTitleFromTop, self.cameraOverlayView.frame.size.width - 2 * kHorizontalMargin, 0)];
    self.lblTitle.font = [UIFont boldSystemFontOfSize:kTitleFontSize];
    self.lblTitle.textColor = [UIColor colorWithWhite:1 alpha:kTitleAlpha];
    self.lblTitle.backgroundColor = [UIColor clearColor];
    self.lblTitle.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.lblTitle.textAlignment = NSTextAlignmentCenter;
    self.lblTitle.numberOfLines = 0;
    self.lblTitle.shadowColor = [UIColor colorWithWhite:0 alpha:0.9];
    self.lblTitle.shadowOffset = CGSizeMake(1, 1);
    [self.cameraOverlayView addSubview:self.lblTitle];

    self.lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(kHorizontalMargin, self.cameraOverlayView.frame.size.height - kMessageFromBottom, self.view.frame.size.width - 2 * kHorizontalMargin, 0)];
    self.lblMessage.font = [UIFont systemFontOfSize:kMessageFontSize];
    self.lblMessage.textColor = [UIColor colorWithWhite:1 alpha:kMessageAlpha];
    self.lblMessage.backgroundColor = [UIColor clearColor];
    self.lblMessage.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.lblMessage.textAlignment = NSTextAlignmentCenter;
    self.lblMessage.numberOfLines = 0;
    self.lblMessage.shadowColor = [UIColor colorWithWhite:0 alpha:0.9];
    self.lblMessage.shadowOffset = CGSizeMake(1, 1);
    [self.cameraOverlayView addSubview:self.lblMessage];
    [self updateOverlay];
}

- (void)messageBreath {
    [UIView animateWithDuration:kMessageBreathDuration animations:^{
        if (CGAffineTransformEqualToTransform(self.lblMessage.transform, CGAffineTransformIdentity)) {
            self.lblMessage.transform = CGAffineTransformMakeScale(kMessageBreathScale, kMessageBreathScale);
        } else {
            self.lblMessage.transform = CGAffineTransformIdentity;
        }
    }                completion:^(BOOL finished) {
        if (finished) {
            [self messageBreath];
        }
    }];
}

- (void)updateOverlay {
    if (self.lblTitle) {
        if ([StringUtil isEmpty:self.scanTitle]) {
            self.lblTitle.text = @"";
        } else {
            self.lblTitle.text = self.scanTitle;
            [self configureLabel:self.lblTitle aroundLine:kTitleFromTop];
        }
    }
    if (self.lblMessage) {
        if ([StringUtil isEmpty:self.scanMessage]) {
            self.lblMessage.text = @"";
        } else {
            self.lblMessage.text = self.scanMessage;
            [self configureLabel:self.lblMessage aroundLine:self.cameraOverlayView.frame.size.height - kMessageFromBottom];
        }
    }
}

- (void)configureLabel:(UILabel *)lbl aroundLine:(CGFloat)top {
    CGFloat height = [lbl.text boundingRectWithSize:CGSizeMake(lbl.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : lbl.font, NSParagraphStyleAttributeName : [NSParagraphStyle defaultParagraphStyle]} context:nil].size.height;
    height = ceilf(height);
    lbl.frame = CGRectMake(lbl.frame.origin.x, top - height / 2, lbl.frame.size.width, height);
}

- (void)cancelClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.scanDelegate && [self.scanDelegate respondsToSelector:@selector(handleScanCancelByReader:)]) {
            [self.scanDelegate handleScanCancelByReader:self];
        }
    }];
}

- (void)flashClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    NSError *error = nil;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device lockForConfiguration:&error]) {
        device.torchMode = sender.selected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
        [device unlockForConfiguration];
    }
}

- (void)fromGalleryClick:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.shouldSwipeRightToPop = NO;
    fromGallery = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    __block DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    [dp showInWindow:picker.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString *result = nil;
            UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
            if (img) {
                CIDetector *detector = [CIDetector detectorOfType:@"CIDetectorTypeQRCode" context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
                NSArray *features = [detector featuresInImage:[[CIImage alloc] initWithImage:img]];
                if (features && features.count > 0) {
                    CIQRCodeFeature *qr = features[0];
                    result = qr.messageString;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [dp dismissWithCompletion:^{
                    if (!result) {
                        fromGallery = NO;
                        [picker dismissViewControllerAnimated:YES completion:^{
                            [self showBannerWithMessage:NSLocalizedString(@"scan_qr_code_from_photo_wrong", nil) belowView:nil belowTop:0 autoHideIn:1 withCompletion:nil];
                        }];
                    } else {
                        if (self.scanDelegate && [self.scanDelegate respondsToSelector:@selector(handleResult:byReader:)]) {
                            [self.scanDelegate handleResult:result byReader:self];
                        }
                    }
                }];
            });
        });
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    fromGallery = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end


#define kShakeTime (7)
#define kShakeDuration (0.04f)
#define kShakeWaveSize (5)

@implementation ScanQrCodeViewController (Functions)


- (void)vibrate {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self.lblMessage.layer removeAllAnimations];
    [self.lblMessage shakeTime:kShakeTime interval:kShakeDuration length:kShakeWaveSize completion:^{
        [self messageBreath];
    }];
}

- (void)playSuccessSound {
    [PlaySoundUtil playSound:@"qr_code_scanned" callback:nil];
}

@end
