//
//  ReloadTxSetting.m
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


#import "ReloadTxSetting.h"
#import "DialogProgress.h"
#import "PeerUtil.h"
#import "BTAddressManager.h"
#import "BTTxProvider.h"
#import "DialogAlert.h"
#import "TransactionsUtil.h"
#import "BTHDAccountProvider.h"
#import "BTHDAccountAddressProvider.h"
#import "DialogCentered.h"
#import "DialogWithActions.h"
#import "UserDefaultsUtil.h"


static double reloadTime;
static Setting *reloadTxsSetting;

@implementation ReloadTxSetting

- (void)showDialogPassword {
    DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
    [dialog showInWindow:self.controller.view.window];
}
#pragma mark - reload data Prompt box
- (void)onPasswordEntered:(NSString *)password {
    [self doAction];
}
#pragma mark - from_bither Respond to events
- (void) doAction {
    DialogProgress *dialogProgrees = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    dialogProgrees.touchOutSideToDismiss = NO;
    [dialogProgrees showInWindow:self.controller.view.window completion:^{
        if([[UserDefaultsUtil instance] getApiConfig] == ApiConfigBlockchainInfo){
            [self reloadTxFrom_blockChain:dialogProgrees];
        }else{
            [self reloadTx:dialogProgrees];
        }
        
    }];
}

#pragma mark - reload tx data from blockchain.info
- (void)reloadTxFrom_blockChain:(DialogProgress *)dialogProgrees{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        reloadTime = [[NSDate new] timeIntervalSince1970];
        [[PeerUtil instance] stopPeer];
        for (BTAddress *address in [[BTAddressManager instance] allAddresses]) {
            [address setIsSyncComplete:NO];
            [address updateSyncComplete];
        }
        [[BTTxProvider instance] clearAllTx];
        [[BTHDAccountAddressProvider instance] setSyncedAllNotComplete];
        [TransactionsUtil syncWalletFrom_blockChain:^{
            [[PeerUtil instance] startPeer];
            if (dialogProgrees) {
                [dialogProgrees dismiss];
            }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if ([self.controller respondsToSelector:@selector(showMsg:)]) {
                [self.controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"Reload transactions data success", nil)];
            }
            
        }           andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
            if (dialogProgrees) {
                [dialogProgrees dismiss];
            }

            
            if ([self.controller respondsToSelector:@selector(showMsg:)]) {
                [self.controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"Network failure.", nil)];
            }
#pragma clang diagnostic pop
            
        }];
    });
    
}
#pragma mark - reload tx data from bither.net
- (void)reloadTx:(DialogProgress *)dialogProgrees {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        reloadTime = [[NSDate new] timeIntervalSince1970];
        [[PeerUtil instance] stopPeer];
        for (BTAddress *address in [[BTAddressManager instance] allAddresses]) {
            [address setIsSyncComplete:NO];
            [address updateSyncComplete];
        }
        [[BTTxProvider instance] clearAllTx];
        [[BTHDAccountAddressProvider instance] setSyncedAllNotComplete];
        [TransactionsUtil syncWallet:^{
            [[PeerUtil instance] startPeer];
            if (dialogProgrees) {
                [dialogProgrees dismiss];
            }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            
            if ([self.controller respondsToSelector:@selector(showMsg:)]) {
                [self.controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"Reload transactions data success", nil)];
            }


        }           andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
            if (dialogProgrees) {
                [dialogProgrees dismiss];
            }
            if ([self.controller respondsToSelector:@selector(showMsg:)]) {
                [self.controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"Network failure.", nil)];
            }
#pragma clang diagnostic pop

        }];


    });
}

+ (Setting *)getReloadTxsSetting {

    if (!reloadTxsSetting) {
        reloadTxsSetting = [[ReloadTxSetting alloc] initWithName:NSLocalizedString(@"Reload Transactions data", nil) icon:nil];

        [reloadTxsSetting setSelectBlock:^(UIViewController *controller) {
            if (reloadTime > 0 && reloadTime + 60 * 60 > (double) [[NSDate new] timeIntervalSince1970]) {
                [self showMessageWithController:controller msg:@"You can only reload transactions data in a hour.."];
            } else {
                if (![[BTAddressManager instance] allSyncComplete]) {
                    [self showMessageWithController:controller msg:@"no_sync_complete"];
                    return;
                }
                DialogAlert *dialogAlert = [[DialogAlert alloc] initWithMessage:NSLocalizedString(@"Reload Transactions data?\nNeed long time.\nConsume network data.\nRecommand trying only with wrong data.", nil) confirm:^{
                    __weak ReloadTxSetting *_sslf = (ReloadTxSetting *) reloadTxsSetting;
                    _sslf.controller = controller;
                    if ([BTPasswordSeed getPasswordSeed]) {
                        [_sslf showDialogPassword];
                    } else {
                        [_sslf reloadTx:nil];
                    }
                }                                                        cancel:^{
                    
                }];
                [dialogAlert showInWindow:controller.view.window];
            }

        }];


    }
    return reloadTxsSetting;
}

+ (void)showMessageWithController:(UIViewController *)controller msg:(NSString *)msg {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([controller respondsToSelector:@selector(showMsg:)]) {
        [controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(msg, nil)];
    }
#pragma clang diagnostic pop
}

@end
