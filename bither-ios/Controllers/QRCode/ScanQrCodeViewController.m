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
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ScanQrCodeViewController (){
    NSString* _scanTitle;
    NSString* _scanMessage;
}
@property UILabel *lblTitle;
@property UILabel *lblMessage;
@end

@interface ScanQrCodeViewController (CameraOverlay)
-(void)configureCameraOverlay;
-(void)updateOverlay;
-(void)messageBreath;
@end

@implementation ScanQrCodeViewController

-(instancetype)init{
    self = [super init];
    if(self){
        self.readerDelegate = self;
        self.showsZBarControls = NO;
        self.videoQuality = UIImagePickerControllerQualityTypeHigh;
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        [self.scanner setSymbology: 0 config: ZBAR_CFG_ENABLE to: 0];
        [self.scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE to:1];
        self.readerView.tracksSymbols = YES;
        [self configureCameraOverlay];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self messageBreath];
}

-(instancetype)initWithDelegate:(NSObject<ScanQrCodeDelegate> *)delegate{
    self = [self initWithDelegate:delegate title:nil message:nil];
    return self;
}

-(instancetype)initWithDelegate:(NSObject<ScanQrCodeDelegate> *)delegate title:(NSString *)title message:(NSString *)message{
    self = [self init];
    if(self){
        self.scanDelegate = delegate;
        self.scanTitle = title;
        self.scanMessage = message;
    }
    return self;
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    NSInteger bestQuality = NSIntegerMin;
    ZBarSymbol *bestResult = nil;
    for(ZBarSymbol *r in results){
        int q = r.quality;
        if(q > bestQuality){
            bestQuality = q;
            bestResult = r;
        }
    }
    if(bestResult && self.scanDelegate && [self.scanDelegate respondsToSelector:@selector(handleResult:byReader:)]){
        [self.scanDelegate handleResult:bestResult.data byReader:self];
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)setScanTitle:(NSString *)scanTitle{
    _scanTitle = scanTitle;
    [self updateOverlay];
}

-(NSString*)scanTitle{
    return _scanTitle;
}

-(void)setScanMessage:(NSString *)scanMessage{
    _scanMessage = scanMessage;
    [self updateOverlay];
}

-(NSString*)scanMessage{
    return _scanMessage;
}

-(BOOL)lowQualityImageProccesing{
    return self.videoQuality != UIImagePickerControllerQualityTypeHigh;
}

-(void)setLowQualityImageProccesing:(BOOL)lowQualityImageProccesing{
    if(lowQualityImageProccesing){
        self.videoQuality = UIImagePickerControllerQualityType640x480;
    }else{
        self.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }
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

@implementation ScanQrCodeViewController(CameraOverlay)

-(void)configureCameraOverlay{
    self.cameraOverlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.cameraOverlayView.backgroundColor = [UIColor clearColor];
    self.cameraOverlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIButton *btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(kCancelButtonOffset, kCancelButtonOffset, kCancelButtonWidth, kCancelButtonHeight)];
    btnCancel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [btnCancel addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnCancel setImage:[UIImage imageNamed:@"scan_cancel"] forState:UIControlStateNormal];
    [btnCancel setImage:[UIImage imageNamed:@"scan_cancel_pressed"] forState:UIControlStateHighlighted];
    [self.cameraOverlayView addSubview:btnCancel];
    
    self.lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(kHorizontalMargin, kTitleFromTop, self.cameraOverlayView.frame.size.width - 2 * kHorizontalMargin, 0)];
    self.lblTitle.font = [UIFont boldSystemFontOfSize:kTitleFontSize];
    self.lblTitle.textColor = [UIColor colorWithWhite:1 alpha:kTitleAlpha];
    self.lblTitle.backgroundColor = [UIColor clearColor];
    self.lblTitle.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.lblTitle.textAlignment = NSTextAlignmentCenter;
    self.lblTitle.numberOfLines = 0;
    self.lblTitle.shadowColor = [UIColor colorWithWhite:0 alpha:0.9];
    self.lblTitle.shadowOffset = CGSizeMake(1, 1);
    [self.cameraOverlayView addSubview:self.lblTitle];
    
    self.lblMessage = [[UILabel alloc]initWithFrame:CGRectMake(kHorizontalMargin, self.cameraOverlayView.frame.size.height - kMessageFromBottom, self.view.frame.size.width - 2 * kHorizontalMargin, 0)];
    self.lblMessage.font = [UIFont systemFontOfSize:kMessageFontSize];
    self.lblMessage.textColor = [UIColor colorWithWhite:1 alpha:kMessageAlpha];
    self.lblMessage.backgroundColor = [UIColor clearColor];
    self.lblMessage.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.lblMessage.textAlignment = NSTextAlignmentCenter;
    self.lblMessage.numberOfLines = 0;
    self.lblMessage.shadowColor = [UIColor colorWithWhite:0 alpha:0.9];
    self.lblMessage.shadowOffset = CGSizeMake(1, 1);
    [self.cameraOverlayView addSubview:self.lblMessage];
}

-(void)messageBreath{
    [UIView animateWithDuration:kMessageBreathDuration animations:^{
        if(CGAffineTransformEqualToTransform(self.lblMessage.transform, CGAffineTransformIdentity)){
            self.lblMessage.transform = CGAffineTransformMakeScale(kMessageBreathScale, kMessageBreathScale);
        }else{
            self.lblMessage.transform =  CGAffineTransformIdentity;
        }
    } completion:^(BOOL finished) {
        if(finished){
            [self messageBreath];
        }
    }];
}

-(void)updateOverlay{
    if([StringUtil isEmpty:self.scanTitle]){
        self.lblTitle.text = @"";
    }else{
        self.lblTitle.text = self.scanTitle;
        [self configureLabel:self.lblTitle aroundLine:kTitleFromTop];
    }
    
    if([StringUtil isEmpty:self.scanMessage]){
        self.lblMessage.text = @"";
    }else{
        self.lblMessage.text = self.scanMessage;
        [self configureLabel:self.lblMessage aroundLine:self.cameraOverlayView.frame.size.height - kMessageFromBottom];
    }
}

-(void)configureLabel:(UILabel*)lbl aroundLine:(CGFloat)top{
    CGFloat height = [lbl.text boundingRectWithSize:CGSizeMake(lbl.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: lbl.font, NSParagraphStyleAttributeName:[NSParagraphStyle defaultParagraphStyle]} context:nil].size.height;
    height = ceilf(height);
    lbl.frame = CGRectMake(lbl.frame.origin.x, top - height / 2, lbl.frame.size.width, height);
}

-(void)cancelClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end


#define kShakeTime (7)
#define kShakeDuration (0.04f)
#define kShakeWaveSize (5)

@implementation ScanQrCodeViewController(Functions)


-(void)vibrate{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self.lblMessage.layer removeAllAnimations];
    [self.lblMessage shakeTime:kShakeTime interval:kShakeDuration length:kShakeWaveSize completion:^{
        [self messageBreath];
    }];
}

-(void)playSuccessSound{
    [PlaySoundUtil playSound:@"qr_code_scanned" callback:nil];
}

@end
