//
//  VerifyMessageSignatureViewController.m
//  bither-ios
//
//  Created by 宋辰文 on 14/12/24.
//  Copyright (c) 2014年 宋辰文. All rights reserved.
//

#import "VerifyMessageSignatureViewController.h"
#import "StringUtil.h"
#import "UIViewController+PiShowBanner.h"
#import "ScanQrCodeViewController.h"
#import "KeyboardController.h"
#import "BTPrivateKeyUtil.h"

@interface VerifyMessageSignatureViewController () <UITextViewDelegate, UITextFieldDelegate, ScanQrCodeDelegate, KeyboardControllerDelegate, UIScrollViewDelegate> {
    NSObject <UITextInput> *_qrWaitingInput;
    CGFloat _tvMinHeight;
}
@property(weak, nonatomic) IBOutlet UIScrollView *sv;
@property(weak, nonatomic) IBOutlet UITextField *tfAddress;
@property(weak, nonatomic) IBOutlet UITextView *tvMessage;
@property(weak, nonatomic) IBOutlet UIView *vMessage;
@property(weak, nonatomic) IBOutlet UIView *vSignature;
@property(weak, nonatomic) IBOutlet UITextView *tvSignature;
@property(weak, nonatomic) IBOutlet UIView *vBottom;
@property(weak, nonatomic) IBOutlet UIButton *btnVerify;
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *ai;
@property(weak, nonatomic) IBOutlet UIImageView *ivSuccess;
@property(weak, nonatomic) IBOutlet UIImageView *ivFailed;
@property(weak, nonatomic) IBOutlet UIView *vTopbar;

@property KeyboardController *kc;
@end

@implementation VerifyMessageSignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tfAddress.delegate = self;
    self.tvMessage.delegate = self;
    self.tvSignature.delegate = self;
    self.sv.delegate = self;
    _tvMinHeight = MIN(self.tvMessage.frame.size.height, self.tvSignature.frame.size.height);
    [self textViewDidChange:self.tvMessage];
    [self.tfAddress becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.kc = [[KeyboardController alloc] initWithDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.kc = nil;
}

- (IBAction)verifyPressed:(id)sender {
    NSString *address = [self.tfAddress.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *message = [self.tvMessage.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *signature = [self.tvSignature.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([StringUtil isEmpty:address] || [StringUtil isEmpty:message] || [StringUtil isEmpty:signature]) {
        return;
    }
    [self.view endEditing:YES];
    [self setVerifyButtonVerifying];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        BOOL success = [BTPrivateKeyUtil verifyMessage:message andSignedMessage:signature withAddress:address];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *msg;
            if (success) {
                msg = NSLocalizedString(@"verify_message_signature_verify_success", nil);
                [self setVerifyButtonSuccess];
            } else {
                msg = NSLocalizedString(@"verify_message_signature_verify_failed", nil);
                [self setVerifyButtonFailed];
            }
            [self showBannerWithMessage:msg belowView:self.vTopbar];
        });
    });
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// MARK: UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [self resetVerifyButton];

    CGFloat height = [self.tvMessage sizeThatFits:CGSizeMake(self.tvMessage.frame.size.width, CGFLOAT_MAX)].height;
    height = MAX(height, _tvMinHeight);
    CGFloat top = self.tvMessage.frame.origin.y;
    CGFloat bottom = self.vMessage.frame.size.height - CGRectGetMaxY(self.tvMessage.frame);
    CGRect frame = self.vMessage.frame;
    frame.size.height = height + top + bottom;
    self.vMessage.frame = frame;
    self.tvMessage.contentOffset = CGPointMake(0, 0);

    height = [self.tvSignature sizeThatFits:CGSizeMake(self.tvSignature.frame.size.width, CGFLOAT_MAX)].height;
    height = MAX(height, _tvMinHeight);
    top = self.tvSignature.frame.origin.y;
    bottom = self.vSignature.frame.size.height - CGRectGetMaxY(self.tvSignature.frame);
    frame = self.vSignature.frame;
    frame.size.height = height + top + bottom;
    frame.origin.y = CGRectGetMaxY(self.vMessage.frame);
    self.vSignature.frame = frame;
    self.tvSignature.contentOffset = CGPointMake(0, 0);

    frame = self.vBottom.frame;
    frame.origin.y = CGRectGetMaxY(self.vSignature.frame);
    self.vBottom.frame = frame;

    self.sv.contentSize = CGSizeMake(self.sv.frame.size.width, CGRectGetMaxY(self.vBottom.frame));
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self resetVerifyButton];
    return YES;
}

// MARK: KeyboardControllerDelegate
- (void)keyboardFrameChanged:(CGRect)frame {
    CGFloat y = [self.sv convertPoint:frame.origin fromView:self.view].y;
    UIEdgeInsets insets = self.sv.contentInset;
    insets.bottom = self.sv.frame.size.height - y;
    self.sv.contentInset = insets;
}

// MARK: Handle Button
- (void)resetVerifyButton {
    self.btnVerify.enabled = YES;
    [self.btnVerify setTitle:NSLocalizedString(@"verify_message_signature_verify_button", nil) forState:UIControlStateNormal];
    self.ivSuccess.hidden = YES;
    self.ivFailed.hidden = YES;
    self.ai.hidden = YES;
}

- (void)setVerifyButtonVerifying {
    self.btnVerify.enabled = NO;
    [self.btnVerify setTitle:NSLocalizedString(@"verify_message_signature_verify_button_verifying", nil) forState:UIControlStateNormal];
    self.ivSuccess.hidden = YES;
    self.ivFailed.hidden = YES;
    self.ai.hidden = NO;
}

- (void)setVerifyButtonSuccess {
    self.btnVerify.enabled = YES;
    [self.btnVerify setTitle:NSLocalizedString(@"verify_message_signature_verify_button_reverify", nil) forState:UIControlStateNormal];
    self.ivSuccess.hidden = NO;
    self.ivFailed.hidden = YES;
    self.ai.hidden = YES;
}

- (void)setVerifyButtonFailed {
    self.btnVerify.enabled = YES;
    [self.btnVerify setTitle:NSLocalizedString(@"verify_message_signature_verify_button_reverify", nil) forState:UIControlStateNormal];
    self.ivSuccess.hidden = YES;
    self.ivFailed.hidden = NO;
    self.ai.hidden = YES;
}

// MARK: QR Code
- (IBAction)qrAddressPressed:(id)sender {
    [self scanQrCodeFor:self.tfAddress];
}

- (IBAction)qrMessagePressed:(id)sender {
    [self scanQrCodeFor:self.tvMessage];
}

- (IBAction)qrSignaturePressed:(id)sender {
    [self scanQrCodeFor:self.tvSignature];
}

- (void)scanQrCodeFor:(NSObject <UITextInput> *)input {
    [self.view endEditing:YES];
    _qrWaitingInput = input;
    [self presentViewController:[[ScanQrCodeViewController alloc] initWithDelegate:self] animated:YES completion:nil];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
    if ([StringUtil isEmpty:result]) {
        return;
    }
    if (_qrWaitingInput) {
        if ([_qrWaitingInput respondsToSelector:@selector(setText:)]) {
            [_qrWaitingInput performSelector:@selector(setText:) withObject:result];
        }
        if ([_qrWaitingInput isKindOfClass:[UITextView class]]) {
            [self textViewDidChange:(UITextView *) _qrWaitingInput];
        } else if ([_qrWaitingInput isKindOfClass:[UITextField class]]) {
            UITextField *tf = (UITextField *) _qrWaitingInput;
            [self textField:tf shouldChangeCharactersInRange:NSMakeRange(0, tf.text.length) replacementString:result];
        }
    }
    _qrWaitingInput = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
