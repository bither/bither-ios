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
#define kButtonHeight (36)
#define kDialogAlertLabelAndBtnDistance 14

@interface DialogHDMServerUnsignedQRCode(){
    void(^block)();
}
@end

@implementation DialogHDMServerUnsignedQRCode

-(instancetype)initWithContent:(NSString *)content andAction:(void(^)())b{
    self = [super initWithContent:content andTitle:NSLocalizedString(@"hdm_keychain_add_unsigned_server_qr_code_title", nil)];
    if(self){
        block = b;
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
        btn.adjustsImageWhenHighlighted = YES;
        [btn setTitle:NSLocalizedString(@"hdm_keychain_add_unsigned_server_qr_code_title", nil) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:kDialogAlertButtonFontSize];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        CGFloat btnWidth = [btn sizeThatFits:CGSizeMake(CGFLOAT_MAX, kButtonHeight)].width;
        btnWidth = ceilf(btnWidth);
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        btn.frame = CGRectMake((screenWidth - btnWidth)/2, screenHeight - (screenHeight - screenWidth - kButtonHeight * 2)/4, btnWidth, kButtonHeight);
        [btn addTarget:self action:@selector(scanPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    return self;
}

-(void)scanPressed:(id)sender{
    [self dismissWithCompletion:block];
}

-(void)dismiss{
    [[[DialogAlert alloc]initWithMessage:NSLocalizedString(@"hdm_keychain_add_unsigned_server_qr_code_dismiss_confirm", nil) confirm:^{
        [self doDismiss];
    } cancel:nil] showInWindow:self.window];
}

-(void)doDismiss{
    [super dismiss];
}

@end
