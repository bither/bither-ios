//
//  DialogHDMServerUnsignedQRCode.m
//  bither-ios
//
//  Created by 宋辰文 on 15/2/2.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import "DialogHDMServerUnsignedQRCode.h"
#import "DialogAlert.h"

#define kDialogAlertButtonFontSize 14
#define kButtonHeight (40)
#define kDialogAlertLabelAndBtnDistance 14

@interface DialogHDMServerUnsignedQRCode () {
    void(^block)();

    void(^cancel)();

    UIButton *btn;
}
@end

@implementation DialogHDMServerUnsignedQRCode

- (instancetype)initWithContent:(NSString *)content action:(void (^)())b andCancel:(void (^)())c {
    self = [super initWithContent:content andTitle:NSLocalizedString(@"hdm_keychain_add_unsigned_server_qr_code_title", nil)];
    if (self) {
        [self configureWithAction:b andCancel:c];
    }
    return self;
}

- (instancetype)initWithContent:(NSString *)content andAction:(void (^)())b {
    self = [super initWithContent:content andTitle:NSLocalizedString(@"hdm_keychain_add_unsigned_server_qr_code_title", nil)];
    if (self) {
        [self configureWithAction:b andCancel:nil];
    }
    return self;
}

- (void)configureWithAction:(void (^)())b andCancel:(void (^)())c {
    block = b;
    cancel = c;
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
    btn.adjustsImageWhenHighlighted = YES;
    [btn setTitle:NSLocalizedString(@"hdm_keychain_add_scan_signed_server_qr_code_action", nil) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:kDialogAlertButtonFontSize];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    CGFloat btnWidth = [btn sizeThatFits:CGSizeMake(CGFLOAT_MAX, kButtonHeight)].width;
    btnWidth = ceilf(btnWidth) + 20;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    btn.frame = CGRectMake((screenWidth - btnWidth) / 2, screenHeight - (screenHeight - screenWidth - kButtonHeight * 2) / 4 - kButtonHeight, btnWidth, kButtonHeight);
    [btn addTarget:self action:@selector(scanPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)scanPressed:(id)sender {
    [self dismissWithCompletion:block];
}

- (void)showInWindow:(UIWindow *)window completion:(void (^)())completion {
    [super showInWindow:window completion:completion];
    if (!btn.superview) {
        [self.superview addSubview:btn];
    }
}

- (void)dismiss {
    [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"hdm_keychain_add_unsigned_server_qr_code_dismiss_confirm", nil) confirm:^{
        [self doDismiss];
        if (cancel) {
            cancel();
        }
    }                              cancel:nil] showInWindow:self.window];
}

- (void)doDismiss {
    [super dismiss];
}

@end
