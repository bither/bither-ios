//
//  SendViewController.m
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

#import "SendViewController.h"
#import "StringUtil.h"
#import "NSString+Base58.h"
#import "ScanQrCodeViewController.h"
#import "DialogProgress.h"
#import "UserDefaultsUtil.h"
#import "UIViewController+PiShowBanner.h"
#import "DialogSendTxConfirm.h"
#import <Bitheri/BTAddressManager.h>
#import <Bitheri/BTSettings.h>
#import <Bitheri/BTPeerManager.h>
#import "UserDefaultsUtil.h"
#import "PeerUtil.h"
#import "TransactionsUtil.h"
#import "CurrencyCalculatorLink.h"

#define kBalanceFontSize (15)

@interface SendViewController ()<UITextFieldDelegate,ScanQrCodeDelegate,DialogSendTxConfirmDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblBalancePrefix;
@property (weak, nonatomic) IBOutlet UILabel *lblBalance;
@property (weak, nonatomic) IBOutlet UILabel *lblPayTo;
@property (weak, nonatomic) IBOutlet UITextField *tfAddress;
@property (weak, nonatomic) IBOutlet CurrencyCalculatorLink *amtLink;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIView *vTopBar;

@end

@implementation SendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureBalance];
    self.tfAddress.delegate = self;
    self.tfPassword.delegate = self;
    self.amtLink.delegate = self;
    [self configureTextField:self.tfAddress];
    [self configureTextField:self.tfPassword];
    if(self.toAddress){
        self.tfAddress.text = self.toAddress;
        self.tfAddress.enabled = NO;
        if(self.amount > 0){
            self.amtLink.amount = self.amount;
        }
    }
    [self check];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [BTSettings instance].feeBase = ([[UserDefaultsUtil instance] getTransactionFeeMode] == Low ? 1000 : 10000);
    if (![[BTPeerManager instance] connected]) {
        [[PeerUtil instance] startPeer];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([StringUtil isEmpty:self.tfAddress.text]){
        [self.tfAddress becomeFirstResponder];
    }else{
        [self.amtLink becomeFirstResponder];
    }
}

- (IBAction)sendPressed:(id)sender {
    if([self checkValues]){
        [self hideKeyboard];
        DialogProgress *dp = [[DialogProgress alloc]initWithMessage:NSLocalizedString(@"Please wait…", nil)];
        [dp showInWindow:self.view.window completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                if(![[[UserDefaultsUtil instance]getPasswordSeed]checkPassword:self.tfPassword.text]){
                    [self showSendResult:NSLocalizedString(@"Password wrong.", nil) dialog:dp];
                    return;
                }
                u_int64_t value = self.amtLink.amount;
                NSError * error;
                BTTx* tx = [self.address txForAmounts:@[@(value)] andAddress:@[[self.tfAddress.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] andError:&error];
                if (error) {
                    NSString * msg=[TransactionsUtil getCompleteTxForError:error];
                    [self showSendResult:msg dialog:dp];
                }else{
                    if(!tx){
                        [self showSendResult:NSLocalizedString(@"Send failed.", nil) dialog:dp];
                        return;
                    }
                    if([self.address signTransaction:tx withPassphrase:self.tfPassword.text]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [dp dismissWithCompletion:^{
                                DialogSendTxConfirm *dialog = [[DialogSendTxConfirm alloc]initWithTx:tx from:self.address to:[self.tfAddress.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] delegate:self];
                                [dialog showInWindow:self.view.window];
                            }];
                        });
                    }else{
                        [self showSendResult:NSLocalizedString(@"Password wrong.", nil) dialog:dp];
                    }
                }
            });
        }];
    }
}


-(void)onSendTxConfirmed:(BTTx*)tx{
    if(!tx){
        return;
    }
    DialogProgress *dp = [[DialogProgress alloc]initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    [dp showInWindow:self.view.window completion:^{
        [[BTPeerManager instance] publishTransaction:tx completion:^(NSError *error) {
            if(!error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dp dismissWithCompletion:^{
                        [self.navigationController popViewControllerAnimated:YES];
                        if(self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(sendSuccessed:)]){
                            [self.sendDelegate sendSuccessed:tx];
                        }
                    }];
                });
            }else{
                [self showSendResult:NSLocalizedString(@"Send failed.", nil) dialog:dp];
            }
        }];
    }];
}

-(void)showSendResult:(NSString*)msg dialog:(DialogProgress*)dp{
    dispatch_async(dispatch_get_main_queue(), ^{
        [dp dismissWithCompletion:^{
            [self showBannerWithMessage:msg belowView:self.vTopBar];
        }];
    });
}

- (IBAction)scanPressed:(id)sender {
    ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc]initWithDelegate:self title:NSLocalizedString(@"Scan Bitcoin Address", nil) message:NSLocalizedString(@"Scan QR Code for Bitcoin address", nil)];
    [self presentViewController:scan animated:YES completion:nil];
}

-(void)handleResult:(NSString*)result byReader:(ScanQrCodeViewController*)reader{
    if(result.isValidBitcoinAddress){
        [reader playSuccessSound];
        [reader vibrate];
        self.tfAddress.text = result;
        [reader dismissViewControllerAnimated:YES completion:^{
            [self check];
            [self.amtLink becomeFirstResponder];
        }];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self check];
    });
    if(textField == self.tfPassword && string.length > 0 && ![StringUtil validPartialPassword:string]){
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == self.tfAddress){
        [self.amtLink becomeFirstResponder];
    }
    if([self.amtLink isLinked:textField]){
        [self.tfPassword becomeFirstResponder];
    }
    if(textField == self.tfPassword){
        [self sendPressed:self.btnSend];
    }
    return YES;
}

-(BOOL)checkValues{
    BOOL validPassword = [StringUtil validPassword:self.tfPassword.text];
    BOOL validAddress = [self.tfAddress.text isValidBitcoinAddress];
    int64_t amount = self.amtLink.amount;
    return validAddress && validPassword && amount > 0;
}

-(void)check{
    self.btnSend.enabled = [self checkValues];
    if([StringUtil compareString:self.tfAddress.text compare:DONATE_ADDRESS]){
        [self.btnSend setTitle:NSLocalizedString(@"Donate", nil) forState:UIControlStateNormal];
        self.lblPayTo.text = NSLocalizedString(@"Donate to developers", nil);
    }else{
        [self.btnSend setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
        self.lblPayTo.text = NSLocalizedString(@"Pay to", nil);
    }
}

-(void)configureBalance{
    self.lblBalance.attributedText = [StringUtil stringWithSymbolForAmount:self.address.balance withFontSize:kBalanceFontSize color:self.lblBalance.textColor];
    [self configureBalanceLabelWidth:self.lblBalance];
    [self configureBalanceLabelWidth:self.lblBalancePrefix];
    self.lblBalance.frame = CGRectMake(CGRectGetMaxX(self.lblBalancePrefix.frame) + 5, self.lblBalance.frame.origin.y, self.lblBalance.frame.size.width, self.lblBalance.frame.size.height);
}

-(void)hideKeyboard{
    if(self.tfAddress.isFirstResponder){
        [self.tfAddress resignFirstResponder];
    }
    if(self.amtLink.isFirstResponder){
        [self.amtLink resignFirstResponder];
    }
    if(self.tfPassword.isFirstResponder){
        [self.tfPassword resignFirstResponder];
    }
}

-(void)configureBalanceLabelWidth:(UILabel*)lbl{
    CGRect frame = lbl.frame;
    [lbl sizeToFit];
    frame.size.width = lbl.frame.size.width;
    lbl.frame = frame;
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)configureTextField:(UITextField*)tf{
    UIView *leftView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, tf.frame.size.height)];
    leftView.backgroundColor = [UIColor clearColor];
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, tf.frame.size.height)];
    rightView.backgroundColor = [UIColor clearColor];
    tf.leftView = leftView;
    tf.rightView = rightView;
    tf.leftViewMode = UITextFieldViewModeAlways;
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;
    if(touch.view != self.tfAddress && touch.view != self.amtLink.tfCurrency && touch.view != self.amtLink.tfBtc && touch.view != self.tfPassword){
        [self hideKeyboard];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;
    if(touch.view != self.tfAddress && touch.view != self.amtLink.tfCurrency && touch.view != self.amtLink.tfBtc && touch.view != self.tfPassword){
        [self hideKeyboard];
    }
}
@end
