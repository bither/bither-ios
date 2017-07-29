//
//  ObtainBccDetailViewController.m
//  bither-ios
//
//  Created by 韩珍 on 2017/7/26.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "ObtainBccDetailViewController.h"
#import "ScanQrCodeViewController.h"
#import "UIViewController+PiShowBanner.h"
#import "StringUtil.h"
#import "NSString+Base58.h"
#import "DialogProgressChangable.h"
#import "UserDefaultsUtil.h"
#import "PeerUtil.h"
#import "BTPeerManager.h"
#import "TransactionsUtil.h"
#import "DialogHDSendTxConfirm.h"
#import "BitherApi.h"
#import "UnitUtil.h"
#import "BTHDAccount.h"

#define kSendButtonQrIconSize (20)

@interface ObtainBccDetailViewController () <UITextFieldDelegate, ScanQrCodeDelegate, DialogSendTxConfirmDelegate> {
    DialogProgressChangable *dp;
}

@property (weak, nonatomic) IBOutlet UIView *vTopBar;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property(weak, nonatomic) IBOutlet UITextField *tfAddress;
@property(weak, nonatomic) IBOutlet UITextField *tfPassword;
@property(weak, nonatomic) IBOutlet UIButton *btnObtain;

@end

@implementation ObtainBccDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lblTitle.text = [NSString stringWithFormat:@"%@%@BCC", NSLocalizedString(@"obtainable_bcc", nil), [UnitUtil stringForAmount:_amount]];
    [self configureTextField:self.tfAddress];
    [self configureTextField:self.tfPassword];
    UIImageView *ivSendQr = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unsigned_transaction_button_icon"]];
    CGFloat ivSendQrMargin = (self.btnObtain.frame.size.height - kSendButtonQrIconSize) / 2;
    ivSendQr.frame = CGRectMake(self.btnObtain.frame.size.width - kSendButtonQrIconSize - ivSendQrMargin, ivSendQrMargin, kSendButtonQrIconSize, kSendButtonQrIconSize);
    [self.btnObtain addSubview:ivSendQr];
    dp = [[DialogProgressChangable alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    dp.touchOutSideToDismiss = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [BTSettings instance].feeBase = [[UserDefaultsUtil instance] getTransactionFeeMode];
    if (![[BTPeerManager instance] connected]) {
        [[PeerUtil instance] startPeer];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([StringUtil isEmpty:self.tfAddress.text]) {
        [self.tfAddress becomeFirstResponder];
    }
}

- (IBAction)obtainPressed:(id)sender {
    NSString *checkValues = [self checkValues];
    if (checkValues) {
        [self showMsg:checkValues];
        return;
    }
    
    [dp showInWindow:self.view.window completion:^{
        [[BitherApi instance] getHasBccAddress:[self getToAddress] callback:^(NSDictionary *dict) {
            NSNumber *numResult = dict[@"result"];
            BOOL result = numResult.intValue > 0;
            if (!result) {
                [self showMsg:NSLocalizedString(@"not_bitpie_bcc_address", nil)];
                return;
            }
            
            [self hideKeyboard];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                if (![[BTPasswordSeed getPasswordSeed] checkPassword:self.tfPassword.text]) {
                    [self showPasswordWrong];
                    return;
                }
                NSError *error;
                NSString *toAddress = [self getToAddress];
                BTTx *tx;
                if ([self.btAddress isMemberOfClass:[BTHDAccount class]]) {
                    tx = [(BTHDAccount *)self.btAddress newTxToAddress:toAddress withAmount:self.amount andChangeAddress:toAddress password:self.tfPassword.text andError:&error coin: BCC];
                } else {
                    tx = [self.btAddress txForAmounts:@[@(self.amount)] andAddress:@[toAddress] andChangeAddress:toAddress andError:&error coin:BCC];
                }
                
                if (error) {
                    NSString *msg = [TransactionsUtil getCompleteTxForError:error];
                    [self showMsg:msg];
                } else {
                    if (!tx) {
                        [self showSendFailed];
                        return;
                    }
                    
                    if ([self.btAddress isMemberOfClass:[BTHDAccount class]]) {
                        __block NSString *addressBlock = toAddress;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [dp dismissWithCompletion:^{
                                [dp changeToMessage:NSLocalizedString(@"Please wait…", nil)];
                                [[[DialogHDSendTxConfirm alloc] initWithTx:tx to:addressBlock delegate:self unitName:@"BCC"] showInWindow:self.view.window];
                            }];
                        });
                    } else {
                        if ([self.btAddress signTransaction:tx withPassphrase:self.tfPassword.text]) {
                            __block NSString *addressBlock = toAddress;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [dp dismissWithCompletion:^{
                                    [dp changeToMessage:NSLocalizedString(@"Please wait…", nil)];
                                    [[[DialogHDSendTxConfirm alloc] initWithTx:tx to:addressBlock delegate:self unitName:@"BCC"] showInWindow:self.view.window];
                                }];
                            });
                        } else {
                            [self showPasswordWrong];
                        }
                    }
                }
            });
        } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
            [self showMsg:NSLocalizedString(@"Network failure.", nil)];
            return;
        }];
    }];
}

- (void)onSendTxConfirmed:(BTTx *)tx {
    [dp changeToMessage:NSLocalizedString(@"Please wait…", nil) completion:^{
        [dp showInWindow:self.view.window completion:^{
            [[BitherApi instance] postBccBroadcast:tx callback:^(NSDictionary *dict) {
                NSNumber *numResult = dict[@"result"];
                if (numResult.intValue > 0) {
                    [dp dismissWithCompletion:^{
                        [self.navigationController popViewControllerAnimated:YES];
                        if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(sendSuccessed:)]) {
                            [self.sendDelegate sendSuccessed:tx];
                        }
                    }];
                } else {
                    NSDictionary *dicError = dict[@"error"];
                    NSString *code = dicError[@"code"];
                    NSString *message = dicError[@"message"];
                    [self showMsg:[NSString stringWithFormat:@"%@: %@", code, message]];
                }
            } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
                [self showSendFailed];
            }];
        }];
    }];
}

- (void)showSendFailed {
    [self showMsg:NSLocalizedString(@"Send failed.", nil)];
}

- (void)showPasswordWrong {
    [self showMsg:NSLocalizedString(@"Password wrong.", nil)];
}

- (void)showMsg:(NSString *)msg {
    if ([NSThread isMainThread]) {
        [dp dismissWithCompletion:^{
            [self showBannerWithMessage:msg belowView:self.vTopBar];
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [dp dismissWithCompletion:^{
                [self showBannerWithMessage:msg belowView:self.vTopBar];
            }];
        });
    }
}

- (IBAction)scanPressed:(id)sender {
    ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc] initWithDelegate:self title:NSLocalizedString(@"Scan Bitpie Bitcoin Cash Address", nil) message:NSLocalizedString(@"Scan QR Code for Bitcoin address", nil)];
    [self presentViewController:scan animated:YES completion:nil];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
    BOOL isValidBitcoinAddress = result.isValidBitcoinAddress;
    BOOL isValidBitcoinBIP21Address = [StringUtil isValidBitcoinBIP21Address:result];
    if (isValidBitcoinAddress || isValidBitcoinBIP21Address) {
        [reader playSuccessSound];
        [reader vibrate];
        if (isValidBitcoinAddress) {
            self.tfAddress.text = result;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        if (isValidBitcoinBIP21Address) {
            self.tfAddress.text = [StringUtil getAddressFormBIP21Address:result];
            uint64_t amt = [StringUtil getAmtFormBIP21Address:result];
            if (amt != -1) {
                [self.tfPassword becomeFirstResponder];
            }
        }
    } else {
        [reader vibrate];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.tfPassword && string.length > 0 && ![StringUtil validPartialPassword:string]) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.tfPassword) {
        [self obtainPressed:self.btnObtain];
    }
    return YES;
}

- (void)hideKeyboard {
    [self.view endEditing:true];
}

- (NSString *)checkValues {
    BOOL validPassword = [StringUtil validPassword:self.tfPassword.text];
    if (!validPassword) {
        return NSLocalizedString(@"Password wrong.", nil);
    }
    BOOL validAddress = [[self getToAddress] isValidBitcoinAddress];
    if (!validAddress) {
        return NSLocalizedString(@"not_bitpie_bcc_address", nil);
    }
    
    if (_amount <= 0) {
        return NSLocalizedString(@"you_do_not_have_obtainable_BBC", nil);
    }
    return nil;
}

- (NSString *)getToAddress {
    return [StringUtil removeBlankSpaceString:self.tfAddress.text];
}

- (void)configureTextField:(UITextField *)tf {
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, tf.frame.size.height)];
    leftView.backgroundColor = [UIColor clearColor];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, tf.frame.size.height)];
    rightView.backgroundColor = [UIColor clearColor];
    tf.leftView = leftView;
    tf.rightView = rightView;
    tf.leftViewMode = UITextFieldViewModeAlways;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    if (touch.view != self.tfAddress && touch.view != self.tfPassword) {
        [self hideKeyboard];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    if (touch.view != self.tfAddress && touch.view != self.tfPassword) {
        [self hideKeyboard];
    }
}

@end
