//
//  KeychainSetting.m
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

#import "KeychainSetting.h"
#import "UserDefaultsUtil.h"
#import "DialogAlert.h"
#import "KeychainBackupUtil.h"
#import "AdvanceViewController.h"

static Setting *keychainSetting;

@interface KeychainSetting ()

@property(nonatomic) BOOL needCheckKeychainPassword;
@property(nonatomic) BOOL needCheckLocalPassword;

@property(nonatomic, strong) NSString *keychainPassword;
@property(nonatomic, strong) NSString *localPassword;

@end

@implementation KeychainSetting

+ (Setting *)getKeychainSetting; {
    if (!keychainSetting) {
        KeychainSetting *setting = [[KeychainSetting alloc] initWithName:NSLocalizedString(@"keychain_backup", nil) icon:nil];
        [setting setGetValueBlock:^() {
            return [BitherSetting getKeychainMode:[[UserDefaultsUtil instance] getKeychainMode]];
        }];
        __block __weak KeychainSetting *weakSetting = setting;
        [setting setSelectBlock:^(UIViewController *controller) {
            weakSetting.controller = controller;
            KeychainMode keychainMode = [[UserDefaultsUtil instance] getKeychainMode];
            if (keychainMode == Off) {
                [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"keychain_backup_enable", nil) confirm:^{
                    [[KeychainBackupUtil instance] update];
                    NSArray *changes = [[KeychainBackupUtil instance] checkWithKeychain];
                    if ([[KeychainBackupUtil instance] isFirstUseKeychain]) {
                        if ([[KeychainBackupUtil instance] uploadKeychain]) {
                            [[UserDefaultsUtil instance] setKeychainMode:On];
                            [[Setting getKeychainSetting] setGetValueBlock:^() {
                                return [BitherSetting getKeychainMode:[[UserDefaultsUtil instance] getKeychainMode]];
                            }];
                            AdvanceViewController *advanceViewController = (AdvanceViewController *) controller;
                            [advanceViewController.tableView reloadData];
                        } else {
                            // sync failed
                            // alert
                            [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"sync_with_keychain_failed", nil) confirm:nil cancel:nil] showInWindow:controller.view.window];
                        }
                    } else if ([changes count] == 0) {
                        [[UserDefaultsUtil instance] setKeychainMode:On];
                        [[Setting getKeychainSetting] setGetValueBlock:^() {
                            return [BitherSetting getKeychainMode:[[UserDefaultsUtil instance] getKeychainMode]];
                        }];
                        AdvanceViewController *advanceViewController = (AdvanceViewController *) controller;
                        [advanceViewController.tableView reloadData];
                    } else {
                        // show changes
                        // in call back do sth below
                        DialogKeychainBackupDiff *dialog = [[DialogKeychainBackupDiff alloc] initWithDiffs:changes andDelegate:weakSetting];
                        [dialog showInWindow:controller.view.window];
                    }
                }                              cancel:nil] showInWindow:controller.view.window];
            } else {
                [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"keychain_backup_disable", nil) confirm:^{
                    [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"keychain_backup_clean", nil) confirm:^{
                        [[KeychainBackupUtil instance] cleanKeychain];
                        [[UserDefaultsUtil instance] setKeychainMode:Off];
                        [[Setting getKeychainSetting] setGetValueBlock:^() {
                            return [BitherSetting getKeychainMode:[[UserDefaultsUtil instance] getKeychainMode]];
                        }];
                        AdvanceViewController *advanceViewController = (AdvanceViewController *) controller;
                        [advanceViewController.tableView reloadData];
                    }                              cancel:^{
                        [[UserDefaultsUtil instance] setKeychainMode:Off];
                        [[Setting getKeychainSetting] setGetValueBlock:^() {
                            return [BitherSetting getKeychainMode:[[UserDefaultsUtil instance] getKeychainMode]];
                        }];
                        AdvanceViewController *advanceViewController = (AdvanceViewController *) controller;
                        [advanceViewController.tableView reloadData];
                    }] showInWindow:controller.view.window];
                }                              cancel:nil] showInWindow:controller.view.window];
            }
            AdvanceViewController *advanceViewController = (AdvanceViewController *) controller;
            [advanceViewController.tableView reloadData];
        }];
        keychainSetting = setting;
    }
    return keychainSetting;
}

#pragma mark - DialogPasswordDelegate

- (void)onPasswordEntered:(NSString *)password; {
    if (self.needCheckKeychainPassword && self.needCheckLocalPassword) {
        self.needCheckKeychainPassword = NO;
        self.keychainPassword = password;
        DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
        [dialog showInWindow:self.controller.view.window];
    } else if (!self.needCheckKeychainPassword && self.needCheckLocalPassword) {
        self.needCheckLocalPassword = NO;
        self.localPassword = password;
        if ([[KeychainBackupUtil instance] syncKeysWithKeychainPassword:self.keychainPassword andLocalPassword:self.localPassword]) {
            [[UserDefaultsUtil instance] setKeychainMode:On];
            [[Setting getKeychainSetting] setGetValueBlock:^() {
                return [BitherSetting getKeychainMode:[[UserDefaultsUtil instance] getKeychainMode]];
            }];
            AdvanceViewController *advanceViewController = (AdvanceViewController *) self.controller;
            [advanceViewController.tableView reloadData];
        } else {
            // sync failed
            // alert
            [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"sync_with_keychain_failed", nil) confirm:nil cancel:nil] showInWindow:self.controller.view.window];
        }
    }
}

- (BOOL)checkPassword:(NSString *)password; {
    if (self.needCheckKeychainPassword) {
        // check keychain password
        return YES;
    } else if (self.needCheckLocalPassword) {
        // check local password
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)passwordTitle; {
    if (self.needCheckKeychainPassword) {
        return NSLocalizedString(@"input_keychain_password", nil);
    } else if (self.needCheckLocalPassword) {
        return NSLocalizedString(@"input_local_password", nil);
    } else {
        return @"";
    }
}

#pragma mark - DialogKeychainBackupDiffDelegate

- (void)onAccept; {
    if ([[KeychainBackupUtil instance] existKeySame]) {
        if ([[KeychainBackupUtil instance] syncKeysWithoutPassword]) {
            [[UserDefaultsUtil instance] setKeychainMode:On];
            [[Setting getKeychainSetting] setGetValueBlock:^() {
                return [BitherSetting getKeychainMode:[[UserDefaultsUtil instance] getKeychainMode]];
            }];
            AdvanceViewController *advanceViewController = (AdvanceViewController *) self.controller;
            [advanceViewController.tableView reloadData];
        } else {
            // sync failed
            // alert
            [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"sync_with_keychain_failed", nil) confirm:nil cancel:nil] showInWindow:self.controller.view.window];
        }
    } else {
        // ask local password & keychain password
        // when success do sth below
        self.needCheckKeychainPassword = YES;
        self.needCheckLocalPassword = YES;
        DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
        [dialog showInWindow:self.controller.view.window];
    }
}

- (void)onDeny; {

}

@end
