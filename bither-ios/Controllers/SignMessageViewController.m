//
//  SignMessageViewController.m
//  bither-ios
//
//  Created by 宋辰文 on 14/12/23.
//  Copyright (c) 2014年 宋辰文. All rights reserved.
//

#import "SignMessageViewController.h"
#import "StringUtil.h"
#import "DialogPassword.h"
#import "DialogSignMessageOutput.h"
#import "DialogBlackQrCode.h"
#import "UIViewController+PiShowBanner.h"
#import "ScanQrCodeViewController.h"
#import "QRCodeThemeUtil.h"
#import "UserDefaultsUtil.h"
#import "DialogAddressQrCode.h"
#import "KeyboardController.h"

@interface SignMessageViewController () <UITextViewDelegate, DialogPasswordDelegate, DialogSignMessageOutputDelegate, ScanQrCodeDelegate, DialogAddressQrCodeDelegate, KeyboardControllerDelegate, UIScrollViewDelegate> {
    CGFloat _tvMinHeight;
}
@property(weak, nonatomic) IBOutlet UIView *vTopbar;
@property(weak, nonatomic) IBOutlet UIView *vOutput;
@property(weak, nonatomic) IBOutlet UITextView *tvOutput;
@property(weak, nonatomic) IBOutlet UIView *vInput;
@property(weak, nonatomic) IBOutlet UITextView *tvInput;
@property(weak, nonatomic) IBOutlet UIImageView *ivArrow;
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *ai;
@property(weak, nonatomic) IBOutlet UIScrollView *sv;
@property(weak, nonatomic) IBOutlet UILabel *lblAddress;
@property(weak, nonatomic) IBOutlet UIView *vAddress;
@property(weak, nonatomic) IBOutlet UIView *vQr;
@property(weak, nonatomic) IBOutlet UIImageView *ivQr;
@property(weak, nonatomic) IBOutlet UIButton *btnScan;
@property(weak, nonatomic) IBOutlet UIButton *btnSign;
@property(weak, nonatomic) IBOutlet UIView *vButtons;

@property KeyboardController *kc;
@end

@implementation SignMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tvMinHeight = self.tvInput.frame.size.height;
    self.tvInput.delegate = self;
    self.ivArrow.hidden = YES;
    self.ai.hidden = YES;
    self.vOutput.hidden = YES;
    self.lblAddress.text = [StringUtil formatAddress:self.address.address groupSize:4 lineSize:12];
    self.sv.delegate = self;
    [self configureAddressFrame];
    [self configureOutputFrame];
    self.ivQr.image = [QRCodeThemeUtil qrCodeOfContent:self.address.address andSize:self.ivQr.frame.size.width withTheme:[[QRCodeTheme themes] objectAtIndex:[[UserDefaultsUtil instance] getQrCodeTheme]]];
    [self.tvInput becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.kc = [[KeyboardController alloc] initWithDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.kc = nil;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView != self.tvInput) {
        return;
    }
    CGFloat height = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, CGFLOAT_MAX)].height;
    height = MAX(height, _tvMinHeight);

    CGRect inputFrame = self.vInput.frame;
    inputFrame.size.height = height + self.tvInput.frame.origin.y * 2 + self.vButtons.frame.size.height + 10;
    self.vInput.frame = inputFrame;

    self.vOutput.hidden = YES;
    self.ivArrow.hidden = YES;
    self.btnScan.enabled = YES;
    self.btnSign.hidden = NO;

    [self configureOutputFrame];
}

- (IBAction)signPressed:(id)sender {
    NSString *input = [self.tvInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([StringUtil isEmpty:input]) {
        return;
    }
    [self.view endEditing:YES];
    [[[DialogPassword alloc] initWithDelegate:self] showInWindow:self.view.window];
}

- (void)onPasswordEntered:(NSString *)password {
    if ([StringUtil isEmpty:password]) {
        return;
    }
    NSString *input = [self.tvInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([StringUtil isEmpty:input]) {
        return;
    }
    self.ai.hidden = NO;
    self.vOutput.hidden = YES;
    self.ivArrow.hidden = YES;
    self.btnScan.enabled = NO;
    self.btnSign.hidden = YES;
    self.tvInput.editable = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *output = [self.address signMessage:input withPassphrase:password];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tvOutput.text = output;
            self.tvInput.editable = YES;
            self.ai.hidden = YES;
            self.btnScan.enabled = YES;
            if (![StringUtil isEmpty:output]) {
                self.vOutput.hidden = NO;
                self.ivArrow.hidden = NO;
                self.btnSign.hidden = YES;
            } else {
                self.vOutput.hidden = YES;
                self.ivArrow.hidden = YES;
                self.btnSign.hidden = NO;
            }
            [self configureOutputFrame];
        });
    });
}

- (IBAction)outputPressed:(id)sender {
    [self.view endEditing:YES];
    [[[DialogSignMessageOutput alloc] initWithDelegate:self] showInWindow:self.view.window];
}

- (void)copyOutput {
    [UIPasteboard generalPasteboard].string = self.tvOutput.text;
    [self showMsg:NSLocalizedString(@"sign_message_output_copied", nil)];
}

- (void)qrOutput {
    [[[DialogBlackQrCode alloc] initWithContent:self.tvOutput.text] showInWindow:self.view.window];
}

- (IBAction)scanPressed:(id)sender {
    [self.view endEditing:YES];
    ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc] initWithDelegate:self];
    [self presentViewController:scan animated:YES completion:nil];
}

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
    if ([StringUtil isEmpty:result]) {
        return;
    }
    self.tvInput.text = result;
    [self textViewDidChange:self.tvInput];
    [reader dismissViewControllerAnimated:YES completion:nil];
}

- (void)showMsg:(NSString *)msg {
    [self showBannerWithMessage:msg belowView:self.vTopbar];
}

- (IBAction)addressPressed:(id)sender {
    [UIPasteboard generalPasteboard].string = self.address.address;
    [self showMsg:NSLocalizedString(@"Address copied.", nil)];
}

- (IBAction)qrPressed:(id)sender {
    [self.view endEditing:YES];
    DialogAddressQrCode *dialogQr = [[DialogAddressQrCode alloc] initWithAddress:self.address delegate:self];
    [dialogQr showInWindow:self.view.window];
}

- (void)configureOutputFrame {
    CGFloat height = [self.tvOutput sizeThatFits:CGSizeMake(self.tvOutput.frame.size.width, CGFLOAT_MAX)].height;
    height = MAX(height, _tvMinHeight);

    CGRect outputFrame = self.vOutput.frame;
    outputFrame.origin.y = CGRectGetMaxY(self.vInput.frame);
    outputFrame.size.height = height + self.tvOutput.frame.origin.y * 2 + 7;
    self.vOutput.frame = outputFrame;

    CGFloat bottom = CGRectGetMaxY(self.vInput.frame);

    if (!self.vOutput.hidden) {
        bottom = CGRectGetMaxY(self.vOutput.frame);
    }

    self.sv.contentSize = CGSizeMake(self.sv.contentSize.width, bottom);
}

- (void)configureAddressFrame {
    CGSize lblSize = [self.lblAddress.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.lblAddress.font, NSParagraphStyleAttributeName : [NSParagraphStyle defaultParagraphStyle]} context:nil].size;
    lblSize.height = ceilf(lblSize.height);
    lblSize.width = ceilf(lblSize.width);
    CGSize containerSize = CGSizeMake(lblSize.width + self.lblAddress.frame.origin.x * 2, lblSize.height + self.lblAddress.frame.origin.y * 2);
    self.vAddress.frame = CGRectMake(self.vAddress.frame.origin.x, self.vAddress.frame.origin.y, containerSize.width, containerSize.height);
    [self configureQrCodeFrame];
}

- (void)configureQrCodeFrame {
    CGFloat size = self.vAddress.frame.size.height;
    CGFloat gap = (self.view.frame.size.width - 20 - self.vAddress.frame.size.width - size) / 3;
    self.vAddress.frame = CGRectMake(gap, self.vAddress.frame.origin.y, self.vAddress.frame.size.width, self.vAddress.frame.size.height);
    self.vQr.frame = CGRectMake(CGRectGetMaxX(self.vAddress.frame) + gap, self.vAddress.frame.origin.y, size, size);
}

- (void)qrCodeThemeChanged:(QRCodeTheme *)theme {
    self.ivQr.image = [QRCodeThemeUtil qrCodeOfContent:self.address.address andSize:self.ivQr.frame.size.width withTheme:theme];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

// MARK: KeyboardControllerDelegate
- (void)keyboardFrameChanged:(CGRect)frame {
    CGFloat y = [self.sv convertPoint:frame.origin fromView:self.view].y;
    UIEdgeInsets insets = self.sv.contentInset;
    insets.bottom = self.sv.frame.size.height - y;
    self.sv.contentInset = insets;
}

@end
