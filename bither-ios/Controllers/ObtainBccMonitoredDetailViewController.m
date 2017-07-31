//
//  ObtainBccMonitoredDetailViewController.m
//  bither-ios
//
//  Created by 韩珍 on 2017/7/28.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "ObtainBccMonitoredDetailViewController.h"
#import "ScanQrCodeViewController.h"
#import "DialogProgressChangable.h"
#import "UserDefaultsUtil.h"
#import "UIViewController+PiShowBanner.h"
#import "DialogSendTxConfirm.h"
#import "ScanQrCodeTransportViewController.h"
#import "PeerUtil.h"
#import <Bitheri/BTPeerManager.h>
#import "BTHDAccount.h"
#import "TransactionsUtil.h"
#import "DialogHDSendTxConfirm.h"
#import "QrCodeViewController.h"
#import "QRCodeTxTransport.h"
#import "BitherApi.h"
#import "UnitUtil.h"

#define kSendButtonQrIconSize (20)

@interface ObtainBccMonitoredDetailViewController () <UITextFieldDelegate, ScanQrCodeDelegate, DialogSendTxConfirmDelegate> {
    DialogProgressChangable *dp;
}

@property (weak, nonatomic) IBOutlet UIView *vTopBar;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property(weak, nonatomic) IBOutlet UITextField *tfAddress;
@property(weak, nonatomic) IBOutlet UIButton *btnObtain;
@property BTTx *tx;

@end

@implementation ObtainBccMonitoredDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lblTitle.text = [NSString stringWithFormat:@"%@%@BCC", NSLocalizedString(@"obtainable_bcc", nil), [UnitUtil stringForAmount:_amount unit:UnitBTC]];
    UIImageView *ivSendQr = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unsigned_transaction_button_icon"]];
    CGFloat ivSendQrMargin = (self.btnObtain.frame.size.height - kSendButtonQrIconSize) / 2;
    ivSendQr.frame = CGRectMake(self.btnObtain.frame.size.width - kSendButtonQrIconSize - ivSendQrMargin, ivSendQrMargin, kSendButtonQrIconSize, kSendButtonQrIconSize);
    [self.btnObtain addSubview:ivSendQr];
    self.tfAddress.delegate = self;
    [self configureTextField:self.tfAddress];
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
    [dp showInWindow:self.view.window completion:^{
        [[BitherApi instance] getHasBccAddress:[self getToAddress] callback:^(NSDictionary *dict) {
            NSNumber *numResult = dict[@"result"];
            BOOL result = numResult.intValue > 0;
            if (!result) {
                [self showMsg:NSLocalizedString(@"not_bitpie_bcc_address", nil)];
                return;
            }
            
            [self hideKeyboard];
            [dp showInWindow:self.view.window completion:^{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    u_int64_t value = self.amount;
                    NSError *error;
                    NSString *toAddress = [self getToAddress];
                    BTTx *tx;
                    if ([self.btAddress isMemberOfClass:[BTHDAccount class]]) {
                        tx = [(BTHDAccount *)self.btAddress newTxToAddress:toAddress withAmount:value andError:&error andChangeAddress:toAddress coin:BCC];
                    } else {
                        tx = [self.btAddress txForAmounts:@[@(value)] andAddress:@[toAddress] andChangeAddress:toAddress andError:&error coin:BCC];
                    }
                    
                    if (error) {
                        NSString *msg = [TransactionsUtil getCompleteTxForError:error];
                        [self showMsg:msg];
                    } else {
                        if (!tx) {
                            [self showSendFailed];
                            return;
                        }
                        self.tx = tx;
                        __block NSString *addressBlock = toAddress;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [dp dismissWithCompletion:^{
                                [dp changeToMessage:NSLocalizedString(@"Please wait…", nil)];
                                DialogHDSendTxConfirm *dialogHDSendTxConfirm = [[DialogHDSendTxConfirm alloc] initWithTx:tx to:addressBlock delegate:self unitName:@"BCC"];
                                dialogHDSendTxConfirm.touchOutSideToDismiss = false;
                                [dialogHDSendTxConfirm showInWindow:self.view.window];
                            }];
                        });
                    }
                });
            }];
        } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
            [self showMsg:NSLocalizedString(@"Network failure.", nil)];
            return;
        }];
    }];
}

- (void)onSendTxConfirmed:(BTTx *)tx {
    if (!tx) {
        self.btnObtain.enabled = YES;
        return;
    }
    QrCodeViewController *qr = [self.storyboard instantiateViewControllerWithIdentifier:@"QrCode"];
    qr.qrCodeTitle = NSLocalizedString(@"Sign Transaction", nil);
    qr.qrCodeMsg = NSLocalizedString(@"Scan with Bither Cold", nil);
    qr.cancelWarning = NSLocalizedString(@"Give up signing?", nil);
    QRCodeTxTransport *txTrans = [[QRCodeTxTransport alloc] init];
    txTrans.fee = self.tx.feeForTransaction;
    txTrans.to = [tx amountSentTo:[self getToAddress]];
    txTrans.myAddress = self.btAddress.address;
    txTrans.toAddress = self.tfAddress.text;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *hashDataArray = tx.unsignedInHashes;
    for (NSData *data in hashDataArray) {
        [array addObject:[NSString hexWithData:data]];
    }
    txTrans.hashList = array;
    if ([self.btAddress isMemberOfClass:[BTHDAccount class]]) {
        NSArray *addresses = [(BTHDAccount *)self.btAddress getSigningAddressesForInputs:self.tx.ins];
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
    } else {
        qr.content = [QRCodeTxTransport getPreSignString:txTrans];
        qr.oldContent = [QRCodeTxTransport oldGetPreSignString:txTrans];
        qr.hasChangeAddress = ![StringUtil compareString:[self getToAddress] compare:self.btAddress.address];
    }
    [qr setFinishAction:NSLocalizedString(@"Scan Bither Cold to sign", nil) target:self selector:@selector(scanBitherColdToSign)];
    [self.navigationController pushViewController:qr animated:YES];
}

- (void)onSendTxCanceled {
    self.btnObtain.enabled = YES;
    self.tx = nil;
}

- (void)scanBitherColdToSign {
    self.btnObtain.enabled = NO;
    ScanQrCodeTransportViewController *scan = [[ScanQrCodeTransportViewController alloc] initWithDelegate:self title:NSLocalizedString(@"Scan Bither Cold to sign", nil) pageName:NSLocalizedString(@"Signed TX QR Code", nil)];
    [self presentViewController:scan animated:YES completion:^{
        [self.navigationController popToViewController:self animated:NO];
        self.btnObtain.enabled = YES;
    }];
}

- (void)finalSend {
    [dp changeToMessage:NSLocalizedString(@"Please wait…", nil) completion:^{
        [dp showInWindow:self.view.window completion:^{
            [[BitherApi instance] postBccBroadcast:self.tx callback:^(NSDictionary *dict) {
                NSNumber *numResult = dict[@"result"];
                if (numResult.intValue > 0) {
                    [self saveIsObtainBcc];
                    [dp dismissWithCompletion:^{
                        [self.navigationController popViewControllerAnimated:YES];
                        if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(sendSuccessed:)]) {
                            [self.sendDelegate sendSuccessed:self.tx];
                        }
                    }];
                } else {
                    NSDictionary *dicError = dict[@"error"];
                    NSString *code = dicError[@"code"];
                    NSString *message = dicError[@"message"];
                    [self showMsg:[NSString stringWithFormat:@"%@: %@", code, message]];
                    self.btnObtain.enabled = YES;
                }
            } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
                [self showSendFailed];
                self.btnObtain.enabled = YES;
            }];
        }];
    }];
}

- (void)saveIsObtainBcc {
    if ([self.btAddress isMemberOfClass:[BTHDAccount class]]) {
        [[UserDefaultsUtil instance] setIsObtainBccKey:@"HDMonitored" value:@"1"];
    } else {
        [[UserDefaultsUtil instance] setIsObtainBccKey:self.btAddress.address value:@"1"];
    }
}

- (IBAction)scanPressed:(id)sender {
    ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc] initWithDelegate:self title:NSLocalizedString(@"Scan Bitpie Bitcoin Cash Address", nil) message:NSLocalizedString(@"Scan QR Code for Bitcoin address", nil)];
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
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            if (isValidBitcoinBIP21Address) {
                self.tfAddress.text = [StringUtil getAddressFormBIP21Address:result];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        } else {
            [reader vibrate];
            [self dismissViewControllerAnimated:YES completion:nil];
            [self showMsg:NSLocalizedString(@"not_bitpie_bcc_address", nil)];
        }
    } else {
        [reader.presentingViewController dismissViewControllerAnimated:YES completion:^{
            self.btnObtain.enabled = NO;
            NSArray *strs = [BTQRCodeUtil splitQRCode:result];
            BOOL success = strs.count == self.tx.ins.count;
            NSMutableArray *sigs = [[NSMutableArray alloc] init];
            if(success){
                for (NSString *s in strs) {
                    NSUInteger signTypeLength = 2;
                    NSUInteger pubKeyLength = 68;
                    NSString *changeStr = s.length > signTypeLength + pubKeyLength ? [s stringByReplacingCharactersInRange:NSMakeRange(s.length - (signTypeLength + pubKeyLength), signTypeLength) withString:[NSString stringWithFormat:@"%0x", [self.tx getSigHashType]]] : s;
                    NSData* d = [changeStr hexToData];
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
                self.btnObtain.enabled = YES;
                self.tx = nil;
                [self showSendFailed];
            }
        }];
    }
}

- (void)handleScanCancelByReader:(ScanQrCodeViewController *)reader {
    self.tx = nil;
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

- (void)showSendFailed {
    [self showMsg:NSLocalizedString(@"Send failed.", nil)];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.tfAddress) {
        [self obtainPressed:self.btnObtain];
    }
    return YES;
}

- (NSString *)checkValues {
    BOOL validAddress = [[self getToAddress] isValidBitcoinAddress];
    if (!validAddress) {
        return NSLocalizedString(@"not_bitpie_bcc_address", nil);
    }
    
    if (_amount <= 0) {
        return NSLocalizedString(@"you_do_not_have_obtainable_bcc", nil);
    }
    return nil;
}

- (NSString *)getToAddress {
    return [StringUtil removeBlankSpaceString:self.tfAddress.text];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
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
    if (touch.view != self.tfAddress) {
        [self hideKeyboard];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    if (touch.view != self.tfAddress) {
        [self hideKeyboard];
    }
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
