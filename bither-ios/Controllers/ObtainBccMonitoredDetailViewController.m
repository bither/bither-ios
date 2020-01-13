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
#define kSignTypeLength (2)
#define kCompressPubKeyLength (68)
#define kUncompressedPubKeyLength (132)

@interface ObtainBccMonitoredDetailViewController () <UITextFieldDelegate, ScanQrCodeDelegate, DialogSendTxConfirmDelegate> {
    DialogProgressChangable *dp;
}

@property (weak, nonatomic) IBOutlet UIView *vTopBar;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property(weak, nonatomic) IBOutlet UITextField *tfAddress;
@property(weak, nonatomic) IBOutlet UIButton *btnObtain;
@property NSArray *txs;
@property (weak, nonatomic) IBOutlet UILabel *lblAddressTitle;

@end

@implementation ObtainBccMonitoredDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lblTitle.text = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"get_split_coin", nil), [UnitUtil stringForAmount:_amount unit:[self getBitcoinUnit]], [self getSplitCoinName]];
    NSString *addressTitle = [NSString stringWithFormat:NSLocalizedString(@"bitpie_split_coin_address", nil), [self getSplitCoinName]];
    self.lblAddressTitle.text = addressTitle;
    self.tfAddress.placeholder = addressTitle;
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
    [self hideKeyboard];
    [dp showInWindow:self.view.window completion:^{
        [[BitherApi instance] getHasSplitCoinAddress:[self getToAddress] splitCoin:self.splitCoin callback:^(NSDictionary *dict) {
            NSNumber *numResult = dict[@"result"];
            BOOL result = numResult.intValue > 0;
            if (!result) {
                [self showMsg:[NSString stringWithFormat:NSLocalizedString(@"not_bitpie_split_coin_address", nil), [self getSplitCoinName]]];
                return;
            }
            if(_splitCoin == SplitBCD) {
                [self getBcdPreBlockHash];
            }else{
                [self signTransactionPreBlockHash:NULL];
            }
            
        } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
            [self showMsg:NSLocalizedString(@"Network failure.", nil)];
            return;
        }];
    }];
}

- (void) getBcdPreBlockHash{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[BitherApi instance] getBcdPreBlockHashCallback:^(NSDictionary *dict) {
            NSString* preBlockHash = dict[@"current_block_hash"];
            if(preBlockHash == NULL || [preBlockHash isEqualToString:@""]) {
                [self showMsg:NSLocalizedString(@"get_bcd_block_hash_error", nil)];
            }else{
                [self signTransactionPreBlockHash:preBlockHash];
            }
        } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
            [self showMsg:NSLocalizedString(@"Network failure.", nil)];
        }];
    });
}
-(void)signTransactionPreBlockHash:(NSString*)hash{
    [dp showInWindow:self.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            u_int64_t value = self.amount;
            NSError *error;
            NSString *toAddress = [self getToAddress];
            NSArray *txs;
            if ([self.btAddress isMemberOfClass:[BTHDAccount class]]) {
                txs = [(BTHDAccount *)self.btAddress newSplitCoinTxsToAddresses:@[toAddress] withAmounts:@[@(value)] andError:&error andChangeAddress:toAddress coin:[self getCoin]];
            } else {
                txs = [self.btAddress splitCoinTxsForAmounts:@[@(value)] andAddress:@[toAddress] andChangeAddress:toAddress andError:&error coin:[self getCoin]];
            }
            for (BTTx *tx in txs) {
                if(hash != NULL && ![hash isEqualToString:@""]) {
                    tx.blockHash = [hash hexToData];
                }
            }
            if (error) {
                NSString *msg = [TransactionsUtil getCompleteTxForError:error];
                [self showMsg:msg];
            } else {
                if (!txs) {
                    [self showSendFailed];
                    return;
                }
                self.txs = txs;
                __block NSString *addressBlock = toAddress;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dp dismissWithCompletion:^{
                        [dp changeToMessage:NSLocalizedString(@"Please wait…", nil)];
                        DialogHDSendTxConfirm *dialogHDSendTxConfirm = [[DialogHDSendTxConfirm alloc] initWithTxs:txs to:addressBlock delegate:self unitName:[self getSplitCoinName]];
                        dialogHDSendTxConfirm.touchOutSideToDismiss = false;
                        [dialogHDSendTxConfirm showInWindow:self.view.window];
                    }];
                });
            }
        });
    }];
    
}

- (void)onGetBccSendTxConfirmed:(NSArray *)txs {
    if (!txs) {
        self.btnObtain.enabled = YES;
        return;
    }
    QrCodeViewController *qr = [self.storyboard instantiateViewControllerWithIdentifier:@"QrCode"];
    qr.qrCodeTitle = NSLocalizedString(@"Sign Transaction", nil);
    qr.qrCodeMsg = NSLocalizedString(@"Scan with Bither Cold", nil);
    qr.cancelWarning = NSLocalizedString(@"Give up signing?", nil);
    QRCodeTxTransport *txTrans = [[QRCodeTxTransport alloc] init];
    
    int64_t amount = 0;
    int64_t fee = 0;
    for (BTTx *tx in txs) {
        amount += [tx amountSentTo:[self getToAddress]];
        fee += tx.feeForTransaction;
    }
    txTrans.fee = fee;
    txTrans.to = amount;
    
    txTrans.myAddress = self.btAddress.address;
    txTrans.toAddress = self.tfAddress.text;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if ([self.btAddress isMemberOfClass:[BTHDAccount class]]) {
        NSMutableArray *paths = [NSMutableArray new];
        for (BTTx *tx in txs) {
            NSArray *hashDataArray = tx.unsignedInHashes;
            for (NSData *data in hashDataArray) {
                [array addObject:[NSString hexWithData:data]];
            }
            NSArray *addresses = [(BTHDAccount *)self.btAddress getSigningAddressesForInputs:tx.ins];
            for (BTHDAccountAddress *a in addresses) {
                PathTypeIndex *path = [[PathTypeIndex alloc] init];
                path.index = a.index;
                path.pathType = a.pathType;
                [paths addObject:path];
            }
        }
        txTrans.hashList = array;
        txTrans.pathTypeIndexes = paths;
        txTrans.txTransportType = TxTransportTypeColdHD;
        qr.content = [QRCodeTxTransport getPreSignString:txTrans];
    } else {
        for (BTTx *tx in txs) {
            NSArray *hashDataArray = tx.unsignedInHashes;
            for (NSData *data in hashDataArray) {
                [array addObject:[NSString hexWithData:data]];
            }
        }
        txTrans.hashList = array;
        qr.content = [QRCodeTxTransport getPreSignString:txTrans];
        qr.oldContent = [QRCodeTxTransport oldGetPreSignString:txTrans];
        qr.hasChangeAddress = ![StringUtil compareString:[self getToAddress] compare:self.btAddress.address];
    }
    [qr setFinishAction:NSLocalizedString(@"Scan Bither Cold to sign", nil) target:self selector:@selector(scanBitherColdToSign)];
    [self.navigationController pushViewController:qr animated:YES];
}

- (void)onSendTxCanceled {
    self.btnObtain.enabled = YES;
    self.txs = nil;
}

- (void)scanBitherColdToSign {
    self.btnObtain.enabled = NO;
    ScanQrCodeTransportViewController *scan = [[ScanQrCodeTransportViewController alloc] initWithDelegate:self title:NSLocalizedString(@"Scan Bither Cold to sign", nil) pageName:NSLocalizedString(@"Signed TX QR Code", nil)];
    scan.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:scan animated:YES completion:^{
        [self.navigationController popToViewController:self animated:NO];
        self.btnObtain.enabled = YES;
    }];
}

- (void)finalSend {
    [dp changeToMessage:NSLocalizedString(@"Please wait…", nil) completion:^{
        [dp showInWindow:self.view.window completion:^{
            dispatch_group_t group = dispatch_group_create();
            __block NSString *errorMsg;
            for (BTTx *tx in self.txs) {
                dispatch_group_enter(group);
                [[BitherApi instance] postSplitCoinBroadcast:tx splitCoin:self.splitCoin callback:^(NSDictionary *dict) {
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
                [self saveIsObtainBcc];
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

- (void)saveIsObtainBcc {
    NSString *coinName = self.splitCoin == SplitBCC ? @"" : [self getSplitCoinName];
    if ([self.btAddress isMemberOfClass:[BTHDAccount class]]) {
        [[UserDefaultsUtil instance] setIsObtainBccKey:[NSString stringWithFormat:@"HDMonitored%@", coinName] value:@"1"];
    } else {
        [[UserDefaultsUtil instance] setIsObtainBccKey:[NSString stringWithFormat:@"%@%@", self.btAddress.address, coinName] value:@"1"];
    }
}

- (IBAction)scanPressed:(id)sender {
    ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc] initWithDelegate:self title:[NSString stringWithFormat:NSLocalizedString(@"Scan Bitpie Split Coin Address", nil), [SplitCoinUtil getSplitCoinName:self.splitCoin]] message:NSLocalizedString(@"Scan QR Code for Bitcoin address", nil)];
    scan.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:scan animated:YES completion:nil];
}

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
    if (![reader isKindOfClass:[ScanQrCodeTransportViewController class]]) {
        BOOL isValidBitcoinAddress = [SplitCoinUtil validSplitCoinAddress:self.splitCoin address:result];
        if (isValidBitcoinAddress) {
            [reader playSuccessSound];
            [reader vibrate];
            self.tfAddress.text = result;
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [reader vibrate];
            [self dismissViewControllerAnimated:YES completion:nil];
            [self showMsg:[NSString stringWithFormat:NSLocalizedString(@"not_bitpie_split_coin_address", nil), [self getSplitCoinName]]];
        }
    } else {
        [reader.presentingViewController dismissViewControllerAnimated:YES completion:^{
            self.btnObtain.enabled = NO;
            NSArray *strs = [BTQRCodeUtil splitQRCode:result];
            NSUInteger insCount = 0;
            for (BTTx *tx in self.txs) {
                insCount += tx.ins.count;
            }
            BOOL success = strs.count == insCount;
            if (success) {
                int strIndex = 0;
                for (int i = 0; i < self.txs.count; i++) {
                    BTTx *tx = self.txs[i];
                    NSMutableArray *compressSigs = [[NSMutableArray alloc] init];
                    NSMutableArray *uncompressedSigs = [[NSMutableArray alloc] init];
                    if (success) {
                        for (int j = 0; j < tx.ins.count; j++) {
                            NSString *s = strs[strIndex + j];
                            if(_splitCoin != SplitBCD) {
                                NSString *compressChangeStr = s.length > kSignTypeLength + kCompressPubKeyLength ? [s stringByReplacingCharactersInRange:NSMakeRange(s.length - (kSignTypeLength + kCompressPubKeyLength), kSignTypeLength) withString:[NSString stringWithFormat:@"%0x", [tx getSigHashType]]] : s;
                                NSString *uncompressedChangeStr = s.length > kSignTypeLength + kUncompressedPubKeyLength ? [s stringByReplacingCharactersInRange:NSMakeRange(s.length - (kSignTypeLength + kUncompressedPubKeyLength), kSignTypeLength) withString:[NSString stringWithFormat:@"%0x", [tx getSigHashType]]] : s;
                                NSData *compressData = [compressChangeStr hexToData];
                                NSData *uncompressedData = [uncompressedChangeStr hexToData];
                                if(!compressData || !uncompressedData){
                                    success = NO;
                                    break;
                                }
                                [compressSigs addObject:compressData];
                                [uncompressedSigs addObject:uncompressedData];
                            }else{
                                [compressSigs addObject:[s hexToData]];
                                [uncompressedSigs addObject:[s hexToData]];
                            }
                            
                        }
                    }
                    if (success) {
                        if ([tx signWithSignatures:compressSigs]) {
                            success = YES;
                        } else {
                            success = [tx signWithSignatures:uncompressedSigs];
                        }
                    }
                    if (!success) {
                        break;
                    }
                    strIndex += tx.ins.count;
                }
            }
            
            if (success) {
                [dp showInWindow:self.view.window completion:^{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        [self finalSend];
                    });
                }];
            } else {
                self.btnObtain.enabled = YES;
                self.txs = nil;
                [self showSendFailed];
            }
        }];
    }
}

- (void)handleScanCancelByReader:(ScanQrCodeViewController *)reader {
    self.txs = nil;
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

- (NSString *)getSplitCoinName {
    return [SplitCoinUtil getSplitCoinName:self.splitCoin];
}
-(BitcoinUnit)getBitcoinUnit {
    return [SplitCoinUtil getBitcoinUnit:self.splitCoin];
}

- (Coin)getCoin {
    return [SplitCoinUtil getCoin:self.splitCoin];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.tfAddress) {
        [self obtainPressed:self.btnObtain];
    }
    return YES;
}

- (NSString *)checkValues {
    BOOL validAddress = [[self getToAddress] isValidBitcoinAddress] || [[self getToAddress] isValidBitcoinGoldAddress];
    if (!validAddress) {
        return NSLocalizedString(@"not_bitpie_bcc_address", nil);
    }
    
    if (_amount <= 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"you_do_not_have_get_split_coin", nil), [self getSplitCoinName]];
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
