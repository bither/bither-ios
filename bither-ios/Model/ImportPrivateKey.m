//
//  ImportPrivateKey.m
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

#import <Bitheri/BTAddressProvider.h>
#import "ImportPrivateKey.h"
#import "DialogProgress.h"
#import "BTAddressManager.h"
#import "KeyUtil.h"
#import "BTPrivateKeyUtil.h"
#import "BTQRCodeUtil.h"

@interface ImportPrivateKey ()
@property(nonatomic, strong) NSString *passwrod;
@property(nonatomic, strong) NSString *content;
@property(nonatomic, readwrite) ImportPrivateKeyType importPrivateKeyType;
@property(nonatomic, weak) UIViewController *controller;
@property(nonatomic, strong) DialogProgress *dp;
@end

@implementation ImportPrivateKey
- (instancetype)initWithController:(UIViewController *)controller content:(NSString *)content passwrod:(NSString *)passwrod importPrivateKeyType:(ImportPrivateKeyType)importPrivateKeyType {
    self = [super init];
    if (self) {
        self.passwrod = passwrod;
        self.content = content;
        self.importPrivateKeyType = importPrivateKeyType;
        self.controller = controller;
    }
    return self;
}

- (void)importPrivateKey {
    self.dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    [self.dp showInWindow:self.controller.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            BTKey *key = [self getKey];
            if (key == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self exit];
                    if (self.importPrivateKeyType == BitherQrcode) {
                        [self showMsg:NSLocalizedString(@"Password wrong.", nil)];
                    } else {
                        [self showMsg:NSLocalizedString(@"Import failed.", nil)];
                    }

                });
                return;
            }
            if ([self checkKey:key]) {
                [self addKey:key];
            }
        });

    }];

}

- (BOOL)checkKey:(BTKey *)key {
    if (self.importPrivateKeyType == BitherQrcode) {
        BTPasswordSeed *passwordSeed = [BTPasswordSeed getPasswordSeed];
        if (passwordSeed) {
            BOOL checkPassword = [passwordSeed checkPassword:self.passwrod];
            if (!checkPassword) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self exit];
                    [self showMsg:NSLocalizedString(@"Password of the private key to import is different from ours. Import failed.", nil)];
                });
                return NO;
            }
        }
    }
    BTAddress *address = [[BTAddress alloc] initWithKey:key encryptPrivKey:nil isSyncComplete:NO isXRandom:key.isFromXRandom];
    if ([[[BTAddressManager instance] privKeyAddresses] containsObject:address]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self exit];
            [self showMsg:NSLocalizedString(@"This private key already exists.", nil)];

        });
        return NO;
    } else if ([[[BTAddressManager instance] watchOnlyAddresses] containsObject:address]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self exit];
            [self showMsg:NSLocalizedString(@"Can\'t import Bither Cold private key.", nil)];
        });
        return NO;
    }
    return YES;
}

- (void)addKey:(BTKey *)key {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        BTAddress *address;
        if (self.importPrivateKeyType == BitherQrcode) {
            NSString *encryptKey = [BTQRCodeUtil replaceNewQRCode:self.content];
            address = [[BTAddress alloc] initWithKey:key encryptPrivKey:encryptKey isSyncComplete:NO isXRandom:key.isFromXRandom];
        } else {
            NSString *encryptKey = [BTPrivateKeyUtil getPrivateKeyString:key passphrase:self.passwrod];
            if (encryptKey != nil) {
                address = [[BTAddress alloc] initWithKey:key encryptPrivKey:encryptKey isSyncComplete:NO isXRandom:key.isFromXRandom];;
            }
        }
        if (address) {
            [KeyUtil addAddressList:[[NSArray alloc] initWithObjects:address, nil]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self exit];
                [self showMsg:NSLocalizedString(@"Import success.", nil)];

            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self exit];
                [self showMsg:NSLocalizedString(@"Import failed.", nil)];
            });
        }
    });


}

- (BTKey *)getKey {
    switch (self.importPrivateKeyType) {
        case PrivateText:
            return [BTKey keyWithPrivateKey:self.content];
        case Bip38:
            return [BTKey keyWithPrivateKey:self.content];
        case BitherQrcode:
            return [BTKey keyWithBitcoinj:self.content andPassphrase:self.passwrod];
        default:
            break;
    }
    return nil;
}

- (void)showMsg:(NSString *)msg {
    if ([self.controller respondsToSelector:@selector(showMsg:)]) {
        [self.controller performSelector:@selector(showMsg:) withObject:msg];
    }

}

- (void)exit {
    self.passwrod = nil;
    self.content = nil;
    [self.dp dismiss];

}
@end
