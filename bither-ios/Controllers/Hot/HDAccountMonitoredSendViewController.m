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

#import "HDAccountMonitoredSendViewController.h"
#import "StringUtil.h"
#import "UnitUtil.h"
#import "NSString+Base58.h"
#import "ScanQrCodeViewController.h"
#import "DialogProgressChangable.h"
#import "UserDefaultsUtil.h"
#import "UIViewController+PiShowBanner.h"
#import <Bitheri/BTPeerManager.h>
#import <Bitheri/BTQRCodeUtil.h>
#import "PeerUtil.h"
#import "TransactionsUtil.h"
#import "CurrencyCalculatorLink.h"
#import "DialogSelectChangeAddress.h"
#import "DialogSendTxConfirm.h"
#import "DialogHDSendTxConfirm.h"
#import "ScanQrCodeTransportViewController.h"
#import "QrCodeViewController.h"
#import "QRCodeTxTransport.h"

#define kBalanceFontSize (15)
#define kSendButtonQrIconSize (20)

@interface HDAccountMonitoredSendViewController () <UITextFieldDelegate, ScanQrCodeDelegate, DialogSendTxConfirmDelegate> {
    DialogProgressChangable *dp;
}
@property(weak, nonatomic) IBOutlet UILabel *lblBalancePrefix;
@property(weak, nonatomic) IBOutlet UILabel *lblBalance;
@property(weak, nonatomic) IBOutlet UILabel *lblPayTo;
@property(weak, nonatomic) IBOutlet UITextField *tfAddress;
@property(weak, nonatomic) IBOutlet CurrencyCalculatorLink *amtLink;
@property(weak, nonatomic) IBOutlet UIButton *btnSend;
@property(weak, nonatomic) IBOutlet UIView *vTopBar;
@property BTTx *tx;
@end

@implementation HDAccountMonitoredSendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *ivSendQr = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unsigned_transaction_button_icon"]];
    CGFloat ivSendQrMargin = (self.btnSend.frame.size.height - kSendButtonQrIconSize) / 2;
    ivSendQr.frame = CGRectMake(self.btnSend.frame.size.width - kSendButtonQrIconSize - ivSendQrMargin, ivSendQrMargin, kSendButtonQrIconSize, kSendButtonQrIconSize);
    [self.btnSend addSubview:ivSendQr];
    [self configureBalance];
    self.tfAddress.delegate = self;
    self.amtLink.delegate = self;
    [self configureTextField:self.tfAddress];
    if (self.toAddress) {
        self.tfAddress.text = self.toAddress;
        self.tfAddress.enabled = NO;
        if (self.amount > 0) {
            self.amtLink.amount = self.amount;
        }
    }
    dp = [[DialogProgressChangable alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    dp.touchOutSideToDismiss = NO;
    [self check];
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
    } else {
        [self.amtLink becomeFirstResponder];
    }
}

- (IBAction)sendPressed:(id)sender {
    if ([self checkValues]) {
        [self hideKeyboard];
        [dp showInWindow:self.view.window completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                u_int64_t value = self.amtLink.amount;
                NSError *error;
                NSString *toAddress = [self getToAddress];
                BTTx *tx = [self.address newTxToAddress:toAddress withAmount:value andError:&error];
                if (error) {
                    NSString *msg = [TransactionsUtil getCompleteTxForError:error];
                    [self showSendResult:msg dialog:dp];
                } else {
                    if (!tx) {
                        [self showSendResult:NSLocalizedString(@"Send failed.", nil) dialog:dp];
                        return;
                    }
                    self.tx = tx;
                    __block NSString *addressBlock = toAddress;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.btnSend.enabled = NO;
                        [dp dismissWithCompletion:^{
                            [dp changeToMessage:NSLocalizedString(@"Please wait…", nil)];
                            [[[DialogHDSendTxConfirm alloc] initWithTx:tx to:addressBlock delegate:self] showInWindow:self.view.window];
                        }];
                    });
                }
            });
        }];
    }
}

- (void)onSendTxConfirmed:(BTTx *)tx {
    if (!tx) {
        return;
    }
    QrCodeViewController *qr = [self.storyboard instantiateViewControllerWithIdentifier:@"QrCode"];
    qr.qrCodeTitle = NSLocalizedString(@"Sign Transaction", nil);
    qr.qrCodeMsg = NSLocalizedString(@"Scan with Bither Cold", nil);
    qr.cancelWarning = NSLocalizedString(@"Give up signing?", nil);
    QRCodeTxTransport *txTrans = [[QRCodeTxTransport alloc] init];
    txTrans.fee = self.tx.feeForTransaction;
    txTrans.to = [tx amountSentTo:[self getToAddress]];
    txTrans.myAddress = self.address.address;
    txTrans.toAddress = self.tfAddress.text;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *hashDataArray = tx.unsignedInHashes;
    for (NSData *data in hashDataArray) {
        [array addObject:[NSString hexWithData:data]];
    }
    txTrans.hashList = array;
    NSArray *addresses = [self.address getSigningAddressesForInputs:self.tx.ins];
    NSMutableArray *paths = [NSMutableArray new];
    for (BTHDAccountAddress *a in addresses) {
        PathTypeIndex *path = [[PathTypeIndex alloc] init];
        path.index = a.index;
        path.pathType = a.pathType;
        [paths addObject:path];
    }
    txTrans.pathTypeIndexes = paths;
    txTrans.txTransportType = TxTransportTypeColdHD;
    qr.content = [QRCodeTxTransport getPreSignString:txTrans];
    [qr setFinishAction:NSLocalizedString(@"Scan Bither Cold to sign", nil) target:self selector:@selector(scanBitherColdToSign)];
    [self.navigationController pushViewController:qr animated:YES];
}

- (void)onSendTxCanceled {
    self.btnSend.enabled = YES;
    self.tx = nil;
}

- (void)scanBitherColdToSign {
    self.btnSend.enabled = NO;
    ScanQrCodeTransportViewController *scan = [[ScanQrCodeTransportViewController alloc] initWithDelegate:self title:NSLocalizedString(@"Scan Bither Cold to sign", nil) pageName:NSLocalizedString(@"Signed TX QR Code", nil)];
    [self presentViewController:scan animated:YES completion:^{
        [self.navigationController popToViewController:self animated:NO];
    }];
}

- (void)finalSend {
    [dp changeToMessage:NSLocalizedString(@"Please wait…", nil) completion:^{
        [dp showInWindow:self.view.window completion:^{
            [[BTPeerManager instance] publishTransaction:self.tx completion:^(NSError *error) {
                if (!error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [dp dismissWithCompletion:^{
                            [self.navigationController popViewControllerAnimated:YES];
                            if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(sendSuccessed:)]) {
                                [self.sendDelegate sendSuccessed:self.tx];
                            }
                        }];
                    });
                } else {
                    [self showSendResult:NSLocalizedString(@"Send failed.", nil) dialog:dp];
                }
            }];
        }];
    }];
}

- (void)showSendResult:(NSString *)msg dialog:(DialogProgressChangable *)dpc {
    dispatch_async(dispatch_get_main_queue(), ^{
        [dpc dismissWithCompletion:^{
            [self showBannerWithMessage:msg belowView:self.vTopBar];
        }];
    });
}

- (NSString *)getToAddress {
    return [StringUtil removeBlankSpaceString:self.tfAddress.text];
}

- (IBAction)scanPressed:(id)sender {
    ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc] initWithDelegate:self title:NSLocalizedString(@"Scan Bitcoin Address", nil) message:NSLocalizedString(@"Scan QR Code for Bitcoin address", nil)];
    [self presentViewController:scan animated:YES completion:nil];
}

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
    if (![reader isKindOfClass:[ScanQrCodeTransportViewController class]]) {
        BOOL isValidBitcoinAddress = result.isValidBitcoinAddress;
        BOOL isValidBitcoinBIP21Address = [StringUtil isValidBitcoinBIP21Address:result];
        if (isValidBitcoinAddress || isValidBitcoinBIP21Address) {
            [reader playSuccessSound];
            [reader vibrate];
            if (isValidBitcoinAddress) {
                self.tfAddress.text = result;
                [self dismissViewControllerAnimated:YES completion:^{
                    [self check];
                    [self.amtLink becomeFirstResponder];
                }];
            }
            if (isValidBitcoinBIP21Address) {
                self.tfAddress.text = [StringUtil getAddressFormBIP21Address:result];
                [self dismissViewControllerAnimated:YES completion:^{
                    [self check];
                    [self.amtLink becomeFirstResponder];
                }];
            }
        } else {
            [reader vibrate];
        }
    } else {
        [reader.presentingViewController dismissViewControllerAnimated:YES completion:^{
            self.btnSend.enabled = NO;
            NSArray *strs = [BTQRCodeUtil splitQRCode:result];
            BOOL success = strs.count == self.tx.ins.count;
            NSMutableArray *sigs = [[NSMutableArray alloc] init];
            if(success){
                for (NSString *s in strs) {
                    NSData* d = [s hexToData];
                    if(!d){
                        success = NO;
                        break;
                    }
                    [sigs addObject:d];
                }
            }
            if(success){
                success = [self.tx signWithSignatures:sigs];
            }
            if (success) {
                [dp showInWindow:self.view.window completion:^{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        [self finalSend];
                    });
                }];
            } else {
                self.btnSend.enabled = YES;
                self.tx = nil;
                [self showBannerWithMessage:NSLocalizedString(@"Send failed.", nil) belowView:self.vTopBar];
            }
        }];
    }
}

- (void)handleScanCancelByReader:(ScanQrCodeViewController *)reader {
    self.tx = nil;
    [self check];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self check];
    });
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.tfAddress) {
        [self.amtLink becomeFirstResponder];
    }
    if ([self.amtLink isLinked:textField]) {
        [self sendPressed:self.btnSend];
    }
    return YES;
}

- (BOOL)checkValues {
    BOOL validAddress = [[self getToAddress] isValidBitcoinAddress];
    int64_t amount = self.amtLink.amount;
    return validAddress && amount > 0;
}

- (void)check {
    self.btnSend.enabled = [self checkValues];
    if ([StringUtil compareString:[self getToAddress] compare:DONATE_ADDRESS]) {
        [self.btnSend setTitle:NSLocalizedString(@"Donate", nil) forState:UIControlStateNormal];
        self.lblPayTo.text = NSLocalizedString(@"Donate to developers", nil);
    } else {
        [self.btnSend setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
        self.lblPayTo.text = NSLocalizedString(@"Pay to", nil);
    }
}

- (void)configureBalance {
    self.lblBalance.attributedText = [UnitUtil stringWithSymbolForAmount:self.address.balance withFontSize:kBalanceFontSize color:self.lblBalance.textColor];
    [self configureBalanceLabelWidth:self.lblBalance];
    [self configureBalanceLabelWidth:self.lblBalancePrefix];
    self.lblBalance.frame = CGRectMake(CGRectGetMaxX(self.lblBalancePrefix.frame) + 5, self.lblBalance.frame.origin.y, self.lblBalance.frame.size.width, self.lblBalance.frame.size.height);
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)configureBalanceLabelWidth:(UILabel *)lbl {
    CGRect frame = lbl.frame;
    [lbl sizeToFit];
    frame.size.width = lbl.frame.size.width;
    lbl.frame = frame;
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    if (touch.view != self.tfAddress && touch.view != self.amtLink.tfCurrency && touch.view != self.amtLink.tfBtc) {
        [self hideKeyboard];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    if (touch.view != self.tfAddress && touch.view != self.amtLink.tfCurrency && touch.view != self.amtLink.tfBtc) {
        [self hideKeyboard];
    }
}

- (IBAction)topBarPressed:(id)sender {
    self.amtLink.amount = self.address.balance;
}
@end
