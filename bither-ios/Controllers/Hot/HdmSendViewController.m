//
//  HdmSendViewController.h
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
//
//  Created by songchenwen on 15/2/4.
//

#import <Bitheri/BTAddressProvider.h>
#import <Bitheri/BTPeerManager.h>
#import "HdmSendViewController.h"
#import "CurrencyCalculatorLink.h"
#import "DialogSelectChangeAddress.h"
#import "DialogProgressChangable.h"
#import "StringUtil.h"
#import "TransactionsUtil.h"
#import "PeerUtil.h"
#import "UserDefaultsUtil.h"
#import "UIViewController+PiShowBanner.h"
#import "ScanQrCodeViewController.h"
#import "DialogSendTxConfirm.h"
#import "DialogSendOption.h"
#import "UnitUtil.h"
#import "ScanQrCodeTransportViewController.h"
#import "DialogWithActions.h"
#import "NSError+HDMHttpErrorMessage.h"
#import "QrCodeViewController.h"
#import "QRCodeTxTransport.h"
#import "BTQRCodeUtil.h"
#import "BTHDMBid+Api.h"
#import "DialogAlert.h"
#import "HDMResetServerPasswordUtil.h"

#define kBalanceFontSize (15)
#define kSendButtonQrIconSize (20)

@interface HdmSendViewController () <UITextFieldDelegate, ScanQrCodeDelegate, DialogSendTxConfirmDelegate, ShowBannerDelegete> {
    DialogProgressChangable *dp;
    BOOL signWithCold;
    BOOL isInRecovery;
    UIImageView *ivSendQr;
    BOOL preventKeyboardForSigning;
}
@property(weak, nonatomic) IBOutlet UILabel *lblBalancePrefix;
@property(weak, nonatomic) IBOutlet UILabel *lblBalance;
@property(weak, nonatomic) IBOutlet UILabel *lblPayTo;
@property(weak, nonatomic) IBOutlet UITextField *tfAddress;
@property(weak, nonatomic) IBOutlet CurrencyCalculatorLink *amtLink;
@property(weak, nonatomic) IBOutlet UITextField *tfPassword;
@property(weak, nonatomic) IBOutlet UIButton *btnSend;
@property(weak, nonatomic) IBOutlet UIView *vTopBar;
@property DialogSelectChangeAddress *dialogSelectChangeAddress;
@end

@interface ColdSigFetcher : NSObject <ScanQrCodeDelegate, DialogSendTxConfirmDelegate>
- (instancetype)initWithIndex:(UInt32)index password:(NSString *)password unsignedHashes:(NSArray *)unsignedHashes tx:(BTTx *)tx from:(BTAddress *)from to:(NSString *)toAddress changeTo:(NSString *)changeAddress controller:(HdmSendViewController *)controller andDialogProgress:(DialogProgressChangable *)dp;

- (NSArray *)sigs;

@property BOOL userCancel;
@property NSString *errorMsg;
@end

@interface RemoteSigFetcher : NSObject
- (instancetype)initWithIndex:(UInt32)index password:(NSString *)password unsignedHashes:(NSArray *)unsignedHashes tx:(BTTx *)tx vc:(UIViewController <ShowBannerDelegete> *)vc andDp:(DialogProgressChangable *)dp;

- (NSArray *)sigs;

@property BOOL userCancel;
@property NSString *errorMsg;
@end

@implementation HdmSendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isInRecovery = self.address.isInRecovery;
    if (isInRecovery) {
        signWithCold = YES;
    } else {
        signWithCold = NO;
    }
    [self configureBalance];
    self.tfAddress.delegate = self;
    self.tfPassword.delegate = self;
    self.amtLink.delegate = self;
    [self configureTextField:self.tfAddress];
    [self configureTextField:self.tfPassword];
    if (self.toAddress) {
        self.tfAddress.text = self.toAddress;
        self.tfAddress.enabled = NO;
        if (self.amount > 0) {
            self.amtLink.amount = self.amount;
        }
    }
    dp = [[DialogProgressChangable alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    dp.touchOutSideToDismiss = NO;
    ivSendQr = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unsigned_transaction_button_icon"]];
    CGFloat ivSendQrMargin = (self.btnSend.frame.size.height - kSendButtonQrIconSize) / 2;
    ivSendQr.frame = CGRectMake(self.btnSend.frame.size.width - kSendButtonQrIconSize - ivSendQrMargin, ivSendQrMargin, kSendButtonQrIconSize, kSendButtonQrIconSize);
    [self.btnSend addSubview:ivSendQr];
    self.dialogSelectChangeAddress = [[DialogSelectChangeAddress alloc] initWithFromAddress:self.address];
    [self configureForSigningPartner];
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
        if (!preventKeyboardForSigning) {
            [self.amtLink becomeFirstResponder];
        }
    }
}

- (IBAction)sendPressed:(id)sender {
    if ([self checkValues]) {
        if ([StringUtil compareString:[self getToAddress] compare:self.dialogSelectChangeAddress.changeAddress.address]) {
            [self showBannerWithMessage:NSLocalizedString(@"select_change_address_change_to_same_warn", nil) belowView:self.vTopBar];
            return;
        }
        [self hideKeyboard];
        [dp showInWindow:self.view.window completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                if (![[BTPasswordSeed getPasswordSeed] checkPassword:self.tfPassword.text]) {
                    [self showSendResult:NSLocalizedString(@"Password wrong.", nil) dialog:dp];
                    return;
                }
                u_int64_t value = self.amtLink.amount;
                NSError *error;
                NSString *toAddress = [self getToAddress];
                BTTx *tx = [self.address txForAmounts:@[@(value)] andAddress:@[toAddress] andChangeAddress:self.dialogSelectChangeAddress.changeAddress.address andError:&error];
                if (error) {
                    NSString *msg = [TransactionsUtil getCompleteTxForError:error];
                    [self showSendResult:msg dialog:dp];
                } else {
                    if (!tx) {
                        [self showSendResult:NSLocalizedString(@"Send failed.", nil) dialog:dp];
                        return;
                    }
                    BOOL signResult;
                    __block NSString *errorMsg;
                    __block BOOL userCanceled = NO;
                    NSArray *(^coldFetcher)(UInt32 index, NSString *password, NSArray *unsignHashes, BTTx *tx) = ^NSArray *(UInt32 index, NSString *password, NSArray *unsignedHashes, BTTx *tx) {
                        ColdSigFetcher *f = [[ColdSigFetcher alloc] initWithIndex:index password:password unsignedHashes:unsignedHashes tx:tx from:self.address to:toAddress changeTo:self.dialogSelectChangeAddress.changeAddress.address controller:self andDialogProgress:dp];
                        preventKeyboardForSigning = YES;
                        NSArray *sigs = f.sigs;
                        userCanceled = f.userCancel;
                        errorMsg = f.errorMsg;
                        preventKeyboardForSigning = NO;
                        return sigs;
                    };
                    NSArray *(^remoteFetcher)(UInt32 index, NSString *password, NSArray *unsignHashes, BTTx *tx) = ^NSArray *(UInt32 index, NSString *password, NSArray *unsignedHashes, BTTx *tx) {
                        RemoteSigFetcher *f = [[RemoteSigFetcher alloc] initWithIndex:index password:password unsignedHashes:unsignedHashes tx:tx vc:self andDp:dp];
                        preventKeyboardForSigning = YES;
                        NSArray *sigs = f.sigs;
                        errorMsg = f.errorMsg;
                        userCanceled = f.userCancel;
                        preventKeyboardForSigning = NO;
                        return sigs;
                    };
                    @try {
                        if (isInRecovery) {
                            signResult = [self.address signTx:tx withPassword:self.tfPassword.text coldBlock:coldFetcher andRemoteBlock:remoteFetcher];
                        } else if (signWithCold) {
                            signResult = [self.address signTx:tx withPassword:self.tfPassword.text andFetchBlock:coldFetcher];
                        } else {
                            signResult = [self.address signTx:tx withPassword:self.tfPassword.text andFetchBlock:remoteFetcher];
                        }
                    } @catch (BTHDMPasswordWrongException *e) {
                        signResult = NO;
                        errorMsg = NSLocalizedString(@"Password wrong.", nil);
                    }
                    if (signResult) {
                        __block NSString *addressBlock = toAddress;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (!signWithCold && !isInRecovery) {
                                [dp dismissWithCompletion:^{
                                    [dp changeToMessage:NSLocalizedString(@"Please wait…", nil)];
                                    DialogSendTxConfirm *dialog = [[DialogSendTxConfirm alloc] initWithTx:tx from:self.address to:addressBlock changeTo:self.dialogSelectChangeAddress.changeAddress.address delegate:self];
                                    [dialog showInWindow:self.view.window];
                                }];
                            } else {
                                [self onSendTxConfirmed:tx];
                            }
                        });
                    } else {
                        if (userCanceled) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [dp dismissWithCompletion:nil];
                            });
                            return;
                        }
                        if (errorMsg) {
                            [self showSendResult:errorMsg dialog:dp];
                        } else {
                            [self showSendResult:NSLocalizedString(@"Send failed.", nil) dialog:dp];
                        }
                    }
                }
            });
        }];
    }
}

- (void)onSendTxConfirmed:(BTTx *)tx {
    if (!tx) {
        return;
    }
    [dp changeToMessage:NSLocalizedString(@"Please wait…", nil)];
    [dp showInWindow:self.view.window completion:^{
        [[BTPeerManager instance] publishTransaction:tx completion:^(NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dp dismissWithCompletion:^{
                        [self.navigationController popViewControllerAnimated:YES];
                        if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(sendSuccessed:)]) {
                            [self.sendDelegate sendSuccessed:tx];
                        }
                    }];
                });
            } else {
                [self showSendResult:NSLocalizedString(@"Send failed.", nil) dialog:dp];
            }
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

- (void)showBannerWithMessage:(NSString *)msg {
    [self showBannerWithMessage:msg belowView:self.vTopBar];
}

- (IBAction)scanPressed:(id)sender {
    ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc] initWithDelegate:self title:NSLocalizedString(@"Scan Bitcoin Address", nil) message:NSLocalizedString(@"Scan QR Code for Bitcoin address", nil)];
    [self presentViewController:scan animated:YES completion:nil];
}

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
    BOOL isValidBitcoinAddress = result.isValidBitcoinAddress;
    BOOL isValidBitcoinBIP21Address = [StringUtil isValidBitcoinBIP21Address:result];
    if (isValidBitcoinAddress || isValidBitcoinBIP21Address) {
        [reader playSuccessSound];
        [reader vibrate];
        if (isValidBitcoinAddress) {
            self.tfAddress.text = result;
            [reader.presentingViewController dismissViewControllerAnimated:YES completion:^{
                [self check];
                [self.amtLink becomeFirstResponder];
            }];
        }
        if (isValidBitcoinBIP21Address) {
            self.tfAddress.text = [StringUtil getAddressFormBIP21Address:result];
            uint64_t amt = [StringUtil getAmtFormBIP21Address:result];
            if (amt != -1) {
                self.amtLink.amount = amt;
            }

            [reader.presentingViewController dismissViewControllerAnimated:YES completion:^{
                [self check];
                if (amt != -1) {
                    [self.tfPassword becomeFirstResponder];
                } else {
                    [self.amtLink becomeFirstResponder];
                }

            }];
        }
    } else {
        [reader vibrate];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self check];
    });
    if (textField == self.tfPassword && string.length > 0 && ![StringUtil validPartialPassword:string]) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.tfAddress) {
        [self.amtLink becomeFirstResponder];
    }
    if ([self.amtLink isLinked:textField]) {
        [self.tfPassword becomeFirstResponder];
    }
    if (textField == self.tfPassword) {
        [self sendPressed:self.btnSend];
    }
    return YES;
}

- (BOOL)checkValues {
    BOOL validPassword = [StringUtil validPassword:self.tfPassword.text];
    BOOL validAddress = [[self getToAddress] isValidBitcoinAddress];
    int64_t amount = self.amtLink.amount;
    return validAddress && validPassword && amount > 0;
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

- (IBAction)optionPressed:(id)sender {
    [self hideKeyboard];
    NSMutableArray *actions = [NSMutableArray new];
    [actions addObject:[[Action alloc] initWithName:NSLocalizedString(@"select_change_address_option_name", nil) target:self andSelector:@selector(selectChangeAddress)]];
    if (!isInRecovery) {
        if (signWithCold) {
            [actions addObject:[[Action alloc] initWithName:NSLocalizedString(@"hdm_send_with_server", nil) target:self andSelector:@selector(changeSigningPartner)]];
        } else {
            [actions addObject:[[Action alloc] initWithName:NSLocalizedString(@"hdm_send_with_cold", nil) target:self andSelector:@selector(changeSigningPartner)]];
        }
    }
    [[[DialogWithActions alloc] initWithActions:actions] showInWindow:self.view.window];
}

- (void)selectChangeAddress {
    [self.dialogSelectChangeAddress showInWindow:self.view.window];
}

- (void)changeSigningPartner {
    if (isInRecovery) {
        signWithCold = YES;
    } else {
        signWithCold = !signWithCold;
    }
    [self configureForSigningPartner];
}

- (void)configureForSigningPartner {
    if (signWithCold || isInRecovery) {
        ivSendQr.hidden = NO;
    } else {
        ivSendQr.hidden = YES;
    }
}

- (void)configureBalance {
    self.lblBalance.attributedText = [UnitUtil stringWithSymbolForAmount:self.address.balance withFontSize:kBalanceFontSize color:self.lblBalance.textColor];
    [self configureBalanceLabelWidth:self.lblBalance];
    [self configureBalanceLabelWidth:self.lblBalancePrefix];
    self.lblBalance.frame = CGRectMake(CGRectGetMaxX(self.lblBalancePrefix.frame) + 5, self.lblBalance.frame.origin.y, self.lblBalance.frame.size.width, self.lblBalance.frame.size.height);
}

- (void)hideKeyboard {
    if (self.tfAddress.isFirstResponder) {
        [self.tfAddress resignFirstResponder];
    }
    if (self.amtLink.isFirstResponder) {
        [self.amtLink resignFirstResponder];
    }
    if (self.tfPassword.isFirstResponder) {
        [self.tfPassword resignFirstResponder];
    }
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
    if (touch.view != self.tfAddress && touch.view != self.amtLink.tfCurrency && touch.view != self.amtLink.tfBtc && touch.view != self.tfPassword) {
        [self hideKeyboard];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    if (touch.view != self.tfAddress && touch.view != self.amtLink.tfCurrency && touch.view != self.amtLink.tfBtc && touch.view != self.tfPassword) {
        [self hideKeyboard];
    }
}

- (IBAction)topBarPressed:(id)sender {
    self.amtLink.amount = self.address.balance;
}
@end

@implementation ColdSigFetcher {
    UInt32 _index;
    NSString *_password;
    NSArray *_unsignedHashes;
    BTTx *_tx;
    BTAddress *_from;
    NSString *_to;
    NSString *_change;
    HdmSendViewController *_controller;
    NSCondition *fetched;
    NSArray *sigs;
    DialogProgressChangable *_dp;
}

- (instancetype)initWithIndex:(UInt32)index password:(NSString *)password unsignedHashes:(NSArray *)unsignedHashes tx:(BTTx *)tx from:(BTAddress *)from to:(NSString *)toAddress changeTo:(NSString *)changeAddress controller:(HdmSendViewController *)controller andDialogProgress:(DialogProgressChangable *)dp {
    self = [super init];
    if (self) {
        _index = index;
        _password = password;
        _unsignedHashes = unsignedHashes;
        _tx = tx;
        _from = from;
        _to = toAddress;
        _change = changeAddress;
        _controller = controller;
        _dp = dp;
        fetched = [NSCondition new];
    }
    return self;
}

- (NSArray *)sigs {
    sigs = nil;
    self.userCancel = NO;
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_dp dismissWithCompletion:^{
            [[[DialogSendTxConfirm alloc] initWithTx:_tx from:_from to:_to changeTo:_change delegate:self] showInWindow:_controller.view.window];
        }];
    });
    [fetched lock];
    [fetched wait];
    [fetched unlock];
    return sigs;
}

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
    [reader.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [_dp showInWindow:_controller.view.window completion:^{
            NSArray *strs = [BTQRCodeUtil splitQRCode:result];
            NSMutableArray *signatures = [[NSMutableArray alloc] init];
            for (NSString *str in strs) {
                NSMutableData *s = [NSMutableData dataWithData:str.hexToData];
                [s appendUInt8:SIG_HASH_ALL];
                [signatures addObject:s];
            }
            sigs = signatures;
            [self signalFetchedCondition];
        }];
    }];
}

- (void)handleScanCancelByReader:(ScanQrCodeViewController *)reader {
    self.userCancel = YES;
    [self signalFetchedCondition];
}

- (void)scanBitherColdToSign {
    ScanQrCodeTransportViewController *scan = [[ScanQrCodeTransportViewController alloc] initWithDelegate:self title:NSLocalizedString(@"Scan Bither Cold to sign", nil) pageName:NSLocalizedString(@"Signed TX QR Code", nil)];
    [_controller presentViewController:scan animated:YES completion:^{
        [_controller.navigationController popToViewController:_controller animated:NO];
    }];
}

- (void)onSendTxConfirmed:(BTTx *)tx {
    QrCodeViewController *qr = [_controller.storyboard instantiateViewControllerWithIdentifier:@"QrCode"];
    qr.qrCodeTitle = NSLocalizedString(@"Sign Transaction", nil);
    qr.qrCodeMsg = NSLocalizedString(@"Scan with Bither Cold", nil);
    qr.cancelWarning = NSLocalizedString(@"Give up signing?", nil);
    QRCodeTxTransport *txTrans = [[QRCodeTxTransport alloc] init];
    txTrans.hdmIndex = _index;
    txTrans.fee = _tx.feeForTransaction;
    txTrans.to = [_tx amountSentTo:_to];
    txTrans.myAddress = _from.address;
    txTrans.toAddress = _to;
    if (![StringUtil isEmpty:_change] && ![StringUtil compareString:_change compare:_from.address]) {
        txTrans.changeAddress = _change;
        txTrans.changeAmt = [_tx amountSentTo:_change];
    }
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSData *data in _unsignedHashes) {
        [array addObject:[NSString hexWithData:data]];
    }
    txTrans.hashList = array;
    qr.content = [QRCodeTxTransport getPreSignString:txTrans];
    qr.oldContent = [QRCodeTxTransport oldGetPreSignString:txTrans];
    qr.hasChangeAddress = ![StringUtil compareString:_change compare:_from.address];
    [qr setFinishAction:NSLocalizedString(@"Scan Bither Cold to sign", nil) target:self selector:@selector(scanBitherColdToSign)];
    [_controller.navigationController pushViewController:qr animated:YES];
}

- (void)signalFetchedCondition {
    [fetched lock];
    [fetched signal];
    [fetched unlock];
}

- (void)onSendTxCanceled {
    self.userCancel = YES;
    [self signalFetchedCondition];
}


@end

@implementation RemoteSigFetcher {
    UInt32 _index;
    NSString *_password;
    NSArray *_unsignedHashes;
    BTTx *_tx;
    BOOL toChangePassword;
    UIViewController <ShowBannerDelegete> *vc;
    DialogProgressChangable *dp;
}

- (instancetype)initWithIndex:(UInt32)index password:(NSString *)password unsignedHashes:(NSArray *)unsignedHashes tx:(BTTx *)tx vc:(UIViewController <ShowBannerDelegete> *)v andDp:(DialogProgressChangable *)d {
    self = [super init];
    if (self) {
        _index = index;
        _password = password;
        _unsignedHashes = unsignedHashes;
        _tx = tx;
        vc = v;
        dp = d;
        toChangePassword = NO;
        self.userCancel = NO;
    }
    return self;
}

- (NSArray *)sigs {
    self.userCancel = NO;
    NSError *error;
    BTHDMBid *hdmBid = [BTHDMBid getHDMBidFromDb];
    NSArray *array = [hdmBid signatureByRemoteWithPassword:_password andUnsignHash:_unsignedHashes andIndex:_index andError:&error];
    NSMutableArray *array1 = [NSMutableArray new];
    for (NSData *data in array) {
        NSMutableData *data1 = [NSMutableData dataWithData:data];
        [data1 appendUInt8:SIG_HASH_ALL];
        [array1 addObject:data1];
    }
    if (error) {
        if (error.isHttp400) {
            if (error.code == HDMBID_PASSWORD_WRONG) {
                if (![self changePassword]) {
                    self.userCancel = YES;
                    return nil;
                }
                return [self sigs];
            } else {
                self.errorMsg = NSLocalizedString(@"hdm_address_sign_tx_server_error", nil);
            }
        } else {
            self.errorMsg = NSLocalizedString(@"Network failure.", nil);
        }
        return nil;
    }
    return array1;
}

- (BOOL)changePassword {
    toChangePassword = NO;
    __block NSCondition *condition = [NSCondition new];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"hdm_reset_server_password_password_wrong_confirm", nil) confirm:^{
            toChangePassword = YES;
            [condition lock];
            [condition signal];
            [condition unlock];
        }                              cancel:^{
            toChangePassword = NO;
            [condition lock];
            [condition signal];
            [condition unlock];
        }] showInWindow:vc.view.window];
    });
    [condition lock];
    [condition wait];
    [condition unlock];
    if (!toChangePassword) {
        return NO;
    }
    return [[[HDMResetServerPasswordUtil alloc] initWithViewController:vc dialogProgress:dp andPassword:_password] changeServerPassword];
}

@end
