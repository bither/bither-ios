//
//  BccDetectDetailViewController.m
//  bither-ios
//
//  Created by LTQ on 2017/9/28.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "BccDetectDetailViewController.h"
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
#import "BTAddressManager.h"

#define kSendButtonQrIconSize (20)

@interface BccDetectDetailViewController () <UITextFieldDelegate, ScanQrCodeDelegate, DialogSendTxConfirmDelegate> {
    DialogProgressChangable *dp;
}

@property (weak, nonatomic) IBOutlet UIView *vTopBar;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property(weak, nonatomic) IBOutlet UITextField *tfAddress;
@property(weak, nonatomic) IBOutlet UITextField *tfPassword;
@property(weak, nonatomic) IBOutlet UIButton *btnObtain;

@end

@implementation BccDetectDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lblTitle.text = [NSString stringWithFormat:@"%@%@BCC", NSLocalizedString(@"extract_assets_BCC_send_title", nil), [UnitUtil stringForAmount:_amount unit:UnitBTC]];
    [self configureTextField:self.tfAddress];
    [self configureTextField:self.tfPassword];
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
    
    self.btnObtain.enabled = NO;
    [self hideKeyboard];
    [dp showInWindow:self.view.window completion:^{
        //        [[BitherApi instance] getHasBccAddress:[self getToAddress] callback:^(NSDictionary *dict) {
        //            NSNumber *numResult = dict[@"result"];
        //            BOOL result = numResult.intValue > 0;
        //            if (!result) {
        //                [self showMsg:NSLocalizedString(@"not_bitpie_bcc_address", nil)];
        //                return;
        //            }
        //
        //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //
        //            });
        //        } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
        //            [self showMsg:NSLocalizedString(@"Network failure.", nil)];
        //            return;
        //        }];
        if (![[BTPasswordSeed getPasswordSeed] checkPassword:self.tfPassword.text]) {
            [self showPasswordWrong];
            return;
        }
        NSError *error;
        NSString *toAddress = [self getToAddress];
        NSArray *txs;
        
        if (self.isHDAccount) {
            BTHDAccount *account = [BTAddressManager instance].hdAccountHot;
           txs = [account extractBccToAddresses:@[toAddress] withAmounts:@[@(self.amount)] andChangeAddress:toAddress andUnspentOuts:self.outs andPathTypeIndex:self.pathTypeIndex password:self.tfPassword.text andError:&error];
        } else {
            txs = [self.btAddress bccTxsForAmounts:@[@(self.amount)] andAddress:@[toAddress] andChangeAddress:toAddress andUnspentOuts: self.outs andError:&error];
        }
        
        if (error) {
            NSString *msg = [TransactionsUtil getCompleteTxForError:error];
            [self showMsg:msg];
        } else {
            if (!txs) {
                [self showSendFailed];
                return;
            }
            
            if (self.isHDAccount) {
                [self showDialogHDSendTxConfirmForTx:txs];
            } else {
                BOOL isPasswordWrong = NO;
                for (BTTx *tx in txs) {
                    tx.isDetectBcc = true;
                    if ([self.btAddress signTransaction:tx withPassphrase:self.tfPassword.text andUnspentOuts: self.outs]) {
                        continue;
                    } else {
                        isPasswordWrong = YES;
                        break;
                    }
                }
                if (isPasswordWrong) {
                    [self showPasswordWrong];
                } else {
                    [self showDialogHDSendTxConfirmForTx:txs];
                }
            }
        }
    }];
}

- (void)showDialogHDSendTxConfirmForTx:(NSArray *)txs {
    dispatch_async(dispatch_get_main_queue(), ^{
        [dp dismissWithCompletion:^{
            [dp changeToMessage:NSLocalizedString(@"Please wait…", nil)];
            DialogHDSendTxConfirm *dialogHDSendTxConfirm =
            [[DialogHDSendTxConfirm alloc]initWithTxs:txs to:[self getToAddress] delegate:self unitName:@"BCC" andIsDetectBcc:true];
            dialogHDSendTxConfirm.touchOutSideToDismiss = false;
            [dialogHDSendTxConfirm showInWindow:self.view.window];
        }];
    });
}

- (void)onGetBccSendTxConfirmed:(NSArray *)txs {
    [dp changeToMessage:NSLocalizedString(@"Please wait…", nil) completion:^{
        [dp showInWindow:self.view.window completion:^{
            dispatch_group_t group = dispatch_group_create();
            __block NSString *errorMsg;
            for (BTTx *tx in txs) {
                dispatch_group_enter(group);
                [[BitherApi instance] postBccBroadcast:tx callback:^(NSDictionary *dict) {
                    NSNumber *numResult = dict[@"result"];
                    if (!(numResult.intValue > 0)) {
                        NSDictionary *dicError = dict[@"error"];
                        NSString *code = dicError[@"code"];
                        NSString *message = dicError[@"message"];
                        errorMsg = [NSString stringWithFormat:@"%@: %@", code, message];
                    }
                    dispatch_group_leave(group);
                } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
                    errorMsg = NSLocalizedString(@"Send failed.", nil);
                    dispatch_group_leave(group);
                }];
            }
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                if (errorMsg) {
                    [self showMsg:errorMsg];
                    return;
                }
                [dp dismissWithCompletion:^{
                    [self.navigationController popViewControllerAnimated:YES];
                    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(sendSuccessed:)]) {
                        [self.sendDelegate sendSuccessed:nil];
                    }
                }];
            });
        }];
    }];
}

- (void)onSendTxCanceled {
    self.btnObtain.enabled = YES;
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
            self.btnObtain.enabled = YES;
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [dp dismissWithCompletion:^{
                [self showBannerWithMessage:msg belowView:self.vTopBar];
                self.btnObtain.enabled = YES;
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
        [self dismissViewControllerAnimated:YES completion:nil];
        [self showMsg:NSLocalizedString(@"not_bitpie_bcc_address", nil)];
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
