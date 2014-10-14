//
//  DialogAddressQrCode.m
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

#import "DialogAddressQrCode.h"
#import "UIImage+ImageWithColor.h"
#import "QRCodeThemeUtil.h"
#import "UserDefaultsUtil.h"
#import "UIBaseUtil.h"
#import "FileUtil.h"

#define kQrCodeMargin (8)
#define kButtonSize (40)
#define kButtonBottomDistance (20)

@interface DialogAddressQrCode()<UIDocumentInteractionControllerDelegate>{
    UserDefaultsUtil *defaults;
    NSString *_shareFileName;
    UIImage * _shapeImage;
    UIImage * _broderImage;
    UIImage *_avatarImage;
}
@property NSString *address;
@property UIScrollView *sv;
@property UIDocumentInteractionController *interactionController;
@property (strong, nonatomic) UIActivityIndicatorView* riv;
@end

@implementation DialogAddressQrCode

-(instancetype)initWithAddress:(BTAddress*)address delegate:(NSObject<DialogAddressQrCodeDelegate>*)delegate{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width + (kButtonSize + kButtonBottomDistance) * 2)];
    if(self){
        self.address = address.address;
        self.delegate = delegate;
        defaults = [UserDefaultsUtil instance];
        _shareFileName = address.address;
        _shapeImage=[UIImage imageNamed:@"avatar_for_fancy_qr_code_shape"];
        _broderImage=[UIImage imageNamed:@"avatar_for_fancy_qr_code_overlay"];
        [self firstConfigure];
    }
    return self;
}

-(void)firstConfigure{
    self.backgroundImage = [UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0]];
    self.bgInsets = UIEdgeInsetsMake(10, 0, 10, 0);
    self.dimAmount = 0.8f;
    self.sv = [[UIScrollView alloc]initWithFrame:CGRectMake(0, kButtonSize + kButtonBottomDistance, self.frame.size.width, self.frame.size.width)];
    self.sv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
     self.riv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.riv.frame = CGRectMake(self.frame.size.width/2,self.frame.size.width*2/3, self.riv.frame.size.width, self.riv.frame.size.height);
    [self addSubview:self.riv];
    [self.riv startAnimating];
    NSArray *themes = [QRCodeTheme themes];
    
    self.sv.contentSize = CGSizeMake(themes.count * self.sv.frame.size.width, self.sv.frame.size.height);
    self.sv.pagingEnabled = YES;
    self.sv.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.sv];
    
    for(int i = 0; i < themes.count; i++){
        UIImageView *iv = [[UIImageView alloc]init];
        iv.frame = CGRectMake(i * self.sv.frame.size.width, 0, self.sv.frame.size.width, self.sv.frame.size.height);
        UIButton *btnDismiss = [[UIButton alloc]initWithFrame:iv.frame];
        [btnDismiss setBackgroundImage:nil forState:UIControlStateNormal];
        [btnDismiss addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self.sv addSubview:iv];
        [self.sv addSubview:btnDismiss];
        [self setQRImage:[themes objectAtIndex:i] iv:iv last:i==themes.count-1];
        
    }
    
    int buttonCount = 2;
    CGFloat buttonMargin = (self.frame.size.width - kButtonSize * buttonCount)/(buttonCount + 1);
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(buttonMargin, self.frame.size.height - kButtonSize, kButtonSize, kButtonSize)];
    [btn setImage:[UIImage imageNamed:@"fancy_qr_code_share_normal"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"fancy_qr_code_share_pressed"] forState:UIControlStateHighlighted];
    [btn setBackgroundImage:nil forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(sharePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    btn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(btn.frame) + buttonMargin, self.frame.size.height - kButtonSize, kButtonSize, kButtonSize)];
    [btn setImage:[UIImage imageNamed:@"fancy_qr_code_save_normal"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"fancy_qr_code_save_pressed"] forState:UIControlStateHighlighted];
    [btn setBackgroundImage:nil forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(savePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
}

-(void)setQRImage:(QRCodeTheme *)theme iv:(UIImageView *)iv last:(BOOL) isLast{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage * qrCodeImage=[QRCodeThemeUtil qrCodeOfContent:self.address andSize:self.sv.frame.size.width margin:kQrCodeMargin withTheme:theme];
        NSString * avatarName=[[UserDefaultsUtil instance] getUserAvatar];
        NSString * avatatPath=[[FileUtil getSmallAvatarDir] stringByAppendingString:avatarName];
        if ([FileUtil fileExists:avatatPath]) {
            if (!_avatarImage) {
                _avatarImage=[[UIImage alloc]initWithContentsOfFile:avatatPath];
            }
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(qrCodeImage.size.width, qrCodeImage.size.height), NO, 0);
            [qrCodeImage drawInRect:CGRectMake(0, 0, qrCodeImage.size.width, qrCodeImage.size.height)];
            int w=130;
            int borderW=(qrCodeImage.size.width-w)/2;
            int borderH=(qrCodeImage.size.height-w)/2;
            CGRect rect=CGRectMake(borderW, borderH, w, w);
            [_shapeImage drawInRect:rect];
            [_avatarImage drawInRect:CGRectMake(borderW+4, borderH+4, w-8, w-8)];
            [_broderImage drawInRect:rect];
            qrCodeImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            iv.image=qrCodeImage;
            if (isLast) {
                [self.riv stopAnimating ];
                self.riv.hidden=YES;
            }
        });
        
    });
    
}
-(void)sharePressed:(id)sender{
    NSURL* url = [FileUtil saveTmpImageForShare:[self currentQrCode] fileName:_shareFileName];
    self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    UIView *fromView = self.window.topViewController.view;
    self.interactionController.delegate = self;
    [self.interactionController presentOptionsMenuFromRect:CGRectMake(0, 0, fromView.frame.size.width, fromView.frame.size.height) inView:fromView animated:YES];
    
}

-(void)savePressed:(id)sender{
    UIImageWriteToSavedPhotosAlbum([self currentQrCode], nil, nil, nil);
    UIViewController* topController = nil;
    if([self.delegate isKindOfClass:[UIView class]]){
        topController = ((UIView*) self.delegate).getUIViewController;
    }
    [self dismissWithCompletion:^{
        if(topController && [topController respondsToSelector:@selector(showMessage:)]){
            [topController performSelector:@selector(showMessage:) withObject:NSLocalizedString(@"QR Code saved.", nil)];
        }
    }];
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application{
    [self dismiss];
}

-(void)dialogDidDismiss{
    [super dialogDidDismiss];
    [FileUtil deleteTmpImageForShareWithName:_shareFileName];
}

-(void)dialogWillShow{
    [super dialogWillShow];
    self.sv.contentOffset = CGPointMake([defaults getQrCodeTheme] * self.sv.frame.size.width, 0);
    NSArray *themes = [QRCodeTheme themes];
}

-(int)currentIndex{
    return floorf(self.sv.contentOffset.x / self.sv.frame.size.width);
}

-(UIImage*)currentQrCode{
    UIView *v = [self.sv.subviews objectAtIndex:[self currentIndex]];
    if([v isKindOfClass:[UIImageView class]]){
        UIImageView* iv = (UIImageView*)v;
        return iv.image;
    }
    return nil;
}

-(void)dialogWillDismiss{
    [super dialogWillDismiss];
    int index = [self currentIndex];
    if(index != [defaults getQrCodeTheme]){
        [defaults setQrCodeTheme:index];
        if(self.delegate && [self.delegate respondsToSelector:@selector(qrCodeThemeChanged:)]){
            [self.delegate qrCodeThemeChanged:[[QRCodeTheme themes] objectAtIndex:index]];
        }
    }
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    for(UIView *v in self.subviews){
        if([v isKindOfClass:[UIButton class]] || v == self.sv){
            if(CGRectContainsPoint(v.frame, point)){
                return [super pointInside:point withEvent:event];
            }
        }
    }
    return NO;
}

@end
