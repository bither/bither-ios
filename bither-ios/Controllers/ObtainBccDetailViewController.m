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
@property (weak, nonatomic) IBOutlet UILabel *lblAddressTitle;

@end

@implementation ObtainBccDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lblTitle.text = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"get_split_coin", nil), [UnitUtil stringForAmount:_amount unit:[self getBitcoinUnit]], [self getSplitCoinName]];
    NSString *addressTitle = [NSString stringWithFormat:NSLocalizedString(@"bitpie_split_coin_address", nil), [self getSplitCoinName]];
    self.lblAddressTitle.text = addressTitle;
    self.tfAddress.placeholder = addressTitle;
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

static BTAddress * extracted(ObtainBccDetailViewController *object) {
    return object.btAddress;
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
            if(self.splitCoin == SplitBCD) {
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (![[BTPasswordSeed getPasswordSeed] checkPassword:self.tfPassword.text]) {
            [self showPasswordWrong];
            return;
        }
        NSError *error;
        NSString *toAddress = [self getToAddress];
        NSArray *txs;
        if ([self.btAddress isMemberOfClass:[BTHDAccount class]]) {
            txs = [(BTHDAccount *)extracted(self) newSplitCoinTxsToAddresses:@[toAddress] withAmounts:@[@(self.amount)] andChangeAddress:toAddress password:self.tfPassword.text andError:&error coin:[SplitCoinUtil getCoin:self.splitCoin] blockHah:hash];
        } else {
            txs = [self.btAddress splitCoinTxsForAmounts:@[@(self.amount)] andAddress:@[toAddress] andChangeAddress:toAddress andError:&error coin:[SplitCoinUtil getCoin:self.splitCoin]];
        }
        
        if (error) {
            NSString *msg = [TransactionsUtil getCompleteTxForError:error];
            [self showMsg:msg];
        } else {
            if (!txs) {
                [self showSendFailed];
                return;
            }
            if ([self.btAddress isMemberOfClass:[BTHDAccount class]]) {
                [self showDialogHDSendTxConfirmForTx:txs];
            } else {
                BOOL isPasswordWrong = NO;
                for (BTTx *tx in txs) {
                    if(hash != NULL && ![hash isEqualToString:@""]) {
                        tx.blockHash = [hash hexToData];
                    }
                    if ([self.btAddress signTransaction:tx withPassphrase:self.tfPassword.text]) {
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
    });

}

- (void)showDialogHDSendTxConfirmForTx:(NSArray *)txs {
    dispatch_async(dispatch_get_main_queue(), ^{
        [dp dismissWithCompletion:^{
            [dp changeToMessage:NSLocalizedString(@"Please wait…", nil)];
            DialogHDSendTxConfirm *dialogHDSendTxConfirm = [[DialogHDSendTxConfirm alloc] initWithTxs:txs to:[self getToAddress] delegate:self unitName:[self getSplitCoinName]];
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

- (void)onSendTxCanceled {
    self.btnObtain.enabled = YES;
}

- (void)saveIsObtainBcc {
    NSString *coinName = self.splitCoin == SplitBCC ? @"" : [self getSplitCoinName];
    if ([self.btAddress isMemberOfClass:[BTHDAccount class]]) {
        [[UserDefaultsUtil instance] setIsObtainBccKey:[NSString stringWithFormat:@"HDAccountHot%@", coinName] value:@"1"];
    } else {
        [[UserDefaultsUtil instance] setIsObtainBccKey:[NSString stringWithFormat:@"%@%@", self.btAddress.address, coinName] value:@"1"];
    }
}

- (void)showSendFailed {
    [self showMsg:NSLocalizedString(@"Send failed.", nil)];
}

- (void)showPasswordWrong {
    [self showMsg:NSLocalizedString(@"Password wrong.", nil)];
}

- (NSString *)getSplitCoinName {
    return [SplitCoinUtil getSplitCoinName:self.splitCoin];
}
-(BitcoinUnit)getBitcoinUnit {
    return [SplitCoinUtil getBitcoinUnit:self.splitCoin];
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
    ScanQrCodeViewController *scan = [[ScanQrCodeViewController alloc] initWithDelegate:self title:[NSString stringWithFormat:NSLocalizedString(@"Scan Bitpie Split Coin Address", nil), [SplitCoinUtil getSplitCoinName:self.splitCoin]] message:NSLocalizedString(@"Scan QR Code for Bitcoin address", nil)];
    [self presentViewController:scan animated:YES completion:nil];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader {
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
        return  [NSString stringWithFormat:NSLocalizedString(@"not_bitpie_split_coin_address", nil), [self getSplitCoinName]];
    }
    
    if (_amount <= 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"you_do_not_have_get_split_coin", nil), [self getSplitCoinName]];
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
