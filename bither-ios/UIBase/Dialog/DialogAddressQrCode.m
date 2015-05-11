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
#import "UserDefaultsUtil.h"
#import "UIBaseUtil.h"
#import "FileUtil.h"
#import "UIColor+Util.h"

#define kQrCodeMargin (8)
#define kButtonSize (40)
#define kButtonBottomDistance (20)
#define kLabelAddressMargin (46)
#define kLabelAddressHeight (15)
#define kLabelAddressFontSize (13)
#define kVanitySizeRate (0.6f)
#define kVanityShareQrSizeRate (0.9f)
#define kVanityShareMargin (32)
#define kVanityShareWaterMarkHeightRate (0.1f)
#define kVanityAddressGlowColor (0x00bbff)
#define kVanityAddressTextColor (0xd8f5ff)
#define kVanityAddressQrBgColor (0x2b2f32)

@interface DialogAddressQrCode () <UIDocumentInteractionControllerDelegate> {
    UserDefaultsUtil *defaults;
    NSString *_shareFileName;
    UIImage *_broderImage;
    UIImage *_avatarImage;
    NSInteger vanityLength;
}
@property NSString *address;
@property UIScrollView *sv;
@property UILabel *lblAddress;
@property UIDocumentInteractionController *interactionController;
@property(strong, nonatomic) UIActivityIndicatorView *riv;
@end

@implementation DialogAddressQrCode

- (instancetype)initWithAddress:(BTAddress *)address delegate:(NSObject <DialogAddressQrCodeDelegate> *)delegate {
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width + (kButtonSize + kButtonBottomDistance) * 2)];
    if (self) {
        self.address = address.address;
        self.delegate = delegate;
        defaults = [UserDefaultsUtil instance];
        _shareFileName = address.address;
        _broderImage = [UIImage imageNamed:@"avatar_for_fancy_qr_code_overlay"];
        vanityLength = address.vanityLen;
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.backgroundImage = [UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0]];
    self.bgInsets = UIEdgeInsetsMake(10, 0, 10, 0);
    self.dimAmount = 0.8f;
    self.sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kButtonSize + kButtonBottomDistance, self.frame.size.width, self.frame.size.width)];
    self.sv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.riv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.riv.frame = CGRectMake(self.frame.size.width / 2, self.frame.size.width * 2 / 3, self.riv.frame.size.width, self.riv.frame.size.height);
    [self addSubview:self.riv];
    [self.riv startAnimating];
    NSArray *themes = [QRCodeTheme themes];

    self.sv.contentSize = CGSizeMake(themes.count * self.sv.frame.size.width, self.sv.frame.size.height);
    self.sv.pagingEnabled = YES;
    self.sv.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.sv];

    for (int i = 0; i < themes.count; i++) {
        UIImageView *iv = [[UIImageView alloc] init];
        iv.frame = CGRectMake(i * self.sv.frame.size.width, 0, self.sv.frame.size.width, self.sv.frame.size.height);
        UIButton *btnDismiss = [[UIButton alloc] initWithFrame:iv.frame];
        [btnDismiss setBackgroundImage:nil forState:UIControlStateNormal];
        [btnDismiss addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];

        if (self.shouldShowVanity) {
            iv.transform = CGAffineTransformMakeScale(kVanitySizeRate, kVanitySizeRate);
            iv.layer.shadowColor = [UIColor blackColor].CGColor;
            iv.layer.shadowRadius = 6;
            iv.layer.shadowOpacity = 1;
            iv.layer.shadowOffset = CGSizeMake(0, 3);
        }

        [self.sv addSubview:iv];
        [self.sv addSubview:btnDismiss];
        [self setQRImage:[themes objectAtIndex:i] iv:iv last:i == themes.count - 1];

    }

    self.lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.sv.frame) - kLabelAddressHeight - kLabelAddressMargin + (self.shouldShowVanity ? self.sv.frame.size.width * (1.0f - kVanitySizeRate) / 2 : 0), self.frame.size.width, kLabelAddressHeight)];
    self.lblAddress.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.lblAddress.backgroundColor = [UIColor clearColor];
    self.lblAddress.textAlignment = NSTextAlignmentCenter;
    self.lblAddress.textColor = [UIColor whiteColor];
    self.lblAddress.font = [UIFont boldSystemFontOfSize:kLabelAddressFontSize];
    self.lblAddress.text = self.address;
    [self addSubview:self.lblAddress];
    [self configureAddressLabel];

    int buttonCount = 2;
    CGFloat buttonMargin = (self.frame.size.width - kButtonSize * buttonCount) / (buttonCount + 1);

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(buttonMargin, self.frame.size.height - kButtonSize, kButtonSize, kButtonSize)];
    [btn setImage:[UIImage imageNamed:@"fancy_qr_code_share_normal"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"fancy_qr_code_share_pressed"] forState:UIControlStateHighlighted];
    [btn setBackgroundImage:nil forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(sharePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];

    btn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn.frame) + buttonMargin, self.frame.size.height - kButtonSize, kButtonSize, kButtonSize)];
    [btn setImage:[UIImage imageNamed:@"fancy_qr_code_save_normal"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"fancy_qr_code_save_pressed"] forState:UIControlStateHighlighted];
    [btn setBackgroundImage:nil forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(savePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
}

- (void)setQRImage:(QRCodeTheme *)theme iv:(UIImageView *)iv last:(BOOL)isLast {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *qrCodeImage = [QRCodeThemeUtil qrCodeOfContent:self.address andSize:self.sv.frame.size.width margin:kQrCodeMargin withTheme:theme];
        NSString *avatarName = [[UserDefaultsUtil instance] getUserAvatar];
        NSString *avatatPath = nil;
        if (avatarName) {
            avatatPath = [[FileUtil getSmallAvatarDir] stringByAppendingString:avatarName];
        }
        if (avatatPath && [FileUtil fileExists:avatatPath]) {
            if (!_avatarImage) {
                _avatarImage = [[UIImage alloc] initWithContentsOfFile:avatatPath];
            }
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(qrCodeImage.size.width, qrCodeImage.size.height), NO, 0);
            [qrCodeImage drawInRect:CGRectMake(0, 0, qrCodeImage.size.width, qrCodeImage.size.height)];
            int w = qrCodeImage.size.width * 0.24f;
            if (self.shouldShowVanity) {
                w = w * 0.9f;
            }
            int borderW = (qrCodeImage.size.width - w) / 2;
            int borderH = (qrCodeImage.size.height - w) / 2;
            CGRect rect = CGRectMake(borderW, borderH, w, w);
            [_avatarImage drawInRect:CGRectMake(borderW + 4, borderH + 4, w - 8, w - 8)];
            [_broderImage drawInRect:rect];
            qrCodeImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            iv.image = qrCodeImage;
            if (isLast) {
                [self.riv stopAnimating];
                self.riv.hidden = YES;
            }
        });

    });

}

- (void)sharePressed:(id)sender {
    NSURL *url = [FileUtil saveTmpImageForShare:[self currentQrCode] fileName:_shareFileName];
    self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    UIView *fromView = self.window.topViewController.view;
    self.interactionController.delegate = self;
    [self.interactionController presentOptionsMenuFromRect:CGRectMake(0, 0, fromView.frame.size.width, fromView.frame.size.height) inView:fromView animated:YES];

}

- (void)savePressed:(id)sender {
    UIImageWriteToSavedPhotosAlbum([self currentQrCode], nil, nil, nil);
    UIViewController *topController = nil;
    if ([self.delegate isKindOfClass:[UIView class]]) {
        topController = ((UIView *) self.delegate).getUIViewController;
    }
    [self dismissWithCompletion:^{
        if (topController && [topController respondsToSelector:@selector(showMessage:)]) {
            [topController performSelector:@selector(showMessage:) withObject:NSLocalizedString(@"QR Code saved.", nil)];
        }
    }];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    [self dismiss];
}

- (void)dialogDidDismiss {
    [super dialogDidDismiss];
    [FileUtil deleteTmpImageForShareWithName:_shareFileName];
}

- (void)dialogWillShow {
    [super dialogWillShow];
    self.sv.contentOffset = CGPointMake([defaults getQrCodeTheme] * self.sv.frame.size.width, 0);
}

- (int)currentIndex {
    int index = floorf(self.sv.contentOffset.x / self.sv.frame.size.width);
    if (index < 0) {
        index = 0;
    }
    if (index >= [QRCodeTheme themes].count) {
        index = [QRCodeTheme themes].count - 1;
    }
    return index;
}

- (UIImage *)currentQrCode {
    UIView *v = [self.sv.subviews objectAtIndex:[self currentIndex] * 2];
    if ([v isKindOfClass:[UIImageView class]]) {
        UIImageView *iv = (UIImageView *) v;
        UIImage *qr = iv.image;
        if (self.shouldShowVanity) {
            return [self editQrForVanity:qr];
        } else {
            return qr;
        }
    }
    return nil;
}

- (UIImage *)editQrForVanity:(UIImage *)qr {
    self.lblAddress.opaque = NO;
    UIImage *imgLbl = [self.lblAddress generateImage];
    UIImage *waterMark = [UIImage imageNamed:@"pin_code_water_mark"];
    CGFloat qrSize = qr.size.width / [UIScreen mainScreen].scale * kVanitySizeRate * kVanityShareQrSizeRate;
    CGFloat waterMarkHeight = qrSize * kVanityShareWaterMarkHeightRate;
    CGFloat waterMarkWidth = waterMarkHeight * waterMark.size.width / waterMark.size.height;
    CGSize size = CGSizeMake(MAX(imgLbl.size.width, qrSize) + kVanityShareMargin * 2, kVanityShareMargin * 2 + qrSize + kVanityShareMargin + imgLbl.size.height + waterMarkHeight);

    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    UIColor *bg = [UIColor parseColor:kVanityAddressQrBgColor];
    [bg setFill];
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height + 1));

    [imgLbl drawInRect:CGRectMake((size.width - imgLbl.size.width) / 2, kVanityShareMargin, imgLbl.size.width, imgLbl.size.height)];

    CGContextSaveGState(context);
    CGContextSetShadow(context, CGSizeMake(0, 6), 6);
    [qr drawInRect:CGRectMake((size.width - qrSize) / 2, size.height - qrSize - kVanityShareMargin - waterMarkHeight, qrSize, qrSize)];
    CGContextRestoreGState(context);

    [waterMark drawInRect:CGRectMake((size.width - waterMarkWidth) / 2, size.height - kVanityShareMargin / 2 - waterMarkHeight, waterMarkWidth, waterMarkHeight)];

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)configureAddressLabel {
    if (self.shouldShowVanity) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self.address attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:kLabelAddressFontSize]}];
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowBlurRadius = 6;
        shadow.shadowOffset = CGSizeZero;
        shadow.shadowColor = [UIColor parseColor:kVanityAddressGlowColor];

        [attr addAttributes:@{NSShadowAttributeName : shadow,
                NSForegroundColorAttributeName : [UIColor parseColor:kVanityAddressTextColor],
                NSFontAttributeName : [UIFont boldSystemFontOfSize:kLabelAddressFontSize * 1.3f]
        }             range:NSMakeRange(0, vanityLength)];

        NSAttributedString *space = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kLabelAddressFontSize * 0.6f]}];
        [attr insertAttributedString:space atIndex:vanityLength];

        self.lblAddress.text = nil;
        self.lblAddress.attributedText = attr;
        [self.lblAddress sizeToFit];
        CGRect frame = self.lblAddress.frame;
        frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
        self.lblAddress.frame = frame;
    } else {
        self.lblAddress.attributedText = nil;
        self.lblAddress.text = self.address;
    }
}

- (void)dialogWillDismiss {
    [super dialogWillDismiss];
    int index = [self currentIndex];
    if (index != [defaults getQrCodeTheme]) {
        [defaults setQrCodeTheme:index];
        if (self.delegate && [self.delegate respondsToSelector:@selector(qrCodeThemeChanged:)]) {
            [self.delegate qrCodeThemeChanged:[[QRCodeTheme themes] objectAtIndex:index]];
        }
    }
}

- (BOOL)shouldShowVanity {
    return vanityLength > 0;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[UIButton class]] || v == self.sv) {
            if (CGRectContainsPoint(v.frame, point)) {
                return [super pointInside:point withEvent:event];
            }
        }
    }
    return NO;
}

@end
