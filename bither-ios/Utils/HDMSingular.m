//
//  HDMSingular.m
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
//  Created by songchenwen on 2015/3/13.
//

#import <Bitheri/BTBIP39.h>
#import <Bitheri/BTQRCodeUtil.h>
#import "HDMSingular.h"
#import "BTEncryptData.h"
#import "BTBIP32Key.h"
#import "BTHDMBid+Api.h"
#import "BTAddressManager.h"
#import "UEntropyViewController.h"
#import "KeyUtil.h"
#import "PeerUtil.h"

#define kSaveProgress (0.1)
#define kStartProgress (0.01)
#define kProgressKeyRate (0.5)
#define kProgressEncryptRate (0.5)
#define kMinGeneratingTime (2.4)

@interface HDMSingular () <UEntropyViewControllerDelegate> {
    BOOL running;
    BOOL isSingularMode;
    NSString *password;
    NSData *hotMnemonicSeed;
    NSData *coldMnemonicSeed;
    BTEncryptData *encryptedColdMnemonicSeed;

    NSString *hotFirstAddress;
    NSData *coldRoot;
    BTBIP32Key *coldFirst;
    BTHDMBid *hdmBid;

    NSArray *coldWords;
    NSString *coldQr;
}
@property(weak) UIViewController *controller;
@property(weak) NSObject <HDMSingularDelegate> *delegate;
@end

@implementation HDMSingular
- (instancetype)initWithController:(UIViewController *)controller andDelegate:(NSObject <HDMSingularDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.controller = controller;
        self.delegate = delegate;
        if (![BTAddressManager instance].hdmKeychain) {
            [delegate setSingularModeAvailable:YES];
            running = NO;
            isSingularMode = NO;
        } else {
            [delegate setSingularModeAvailable:NO];
            running = YES;
            isSingularMode = NO;
        }
    }
    return self;
}

- (void)runningWithoutSingularMode {
    isSingularMode = NO;
    running = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate setSingularModeAvailable:NO];
    });
}

- (BOOL)isInSingularMode {
    return running && isSingularMode;
}

- (BOOL)shouldGoSingularMode {
    return self.delegate.shouldGoSingularMode;
}

- (void)setPassword:(NSString *)p {
    password = p;
}

- (void)hot:(BOOL)xrandom {
    if (!password) {
        [NSException raise:@"hdm singular mode cannot run without password" format:nil];
    }
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    running = YES;
    isSingularMode = YES;
    if (xrandom) {
        [self.delegate onSingularModeBegin];
        UEntropyViewController *uentropy = [[UEntropyViewController alloc] initWithPassword:password andDelegate:self];
        [self.controller presentViewController:uentropy animated:YES completion:nil];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate onSingularModeBegin];
        });
        XRandom *xRandom = [[XRandom alloc] initWithDelegate:nil];
        [self setSeed1:[xRandom randomWithSize:32] andSeed2:[xRandom randomWithSize:32] withXRandom:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate singularHotFinish];
        });
    }
}

- (void)setSeed1:(NSData *)seed1 andSeed2:(NSData *)seed2 withXRandom:(BOOL)xrandom {
    if (seed1.length < 32 || seed2.length < 32) {
        [self finishCleanUp];
        [NSException raise:@"hdm singular need 64 bytes entropy" format:nil];
    }
    hotMnemonicSeed = seed1;
    coldMnemonicSeed = seed2;
    [self initHotFirst];
    encryptedColdMnemonicSeed = [[BTEncryptData alloc] initWithData:coldMnemonicSeed andPassowrd:password andIsXRandom:xrandom];
    coldQr = [HDM_QR_CODE_FLAG stringByAppendingString:[BTEncryptData encryptedString:encryptedColdMnemonicSeed.toEncryptedString addIsCompressed:YES andIsXRandom:xrandom]];
}

- (void)cold {
    if (!password) {
        [self finishCleanUp];
        [NSException raise:@"hdm singular mode cannot run without password" format:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        coldWords = [[BTBIP39 sharedInstance] toMnemonicArray:coldMnemonicSeed];
        [self initColdFirst];
        hdmBid = [[BTHDMBid alloc] initWithHDMBid:coldFirst.key.address];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.delegate singularColdFinish];
        });
    });
}

- (void)server {
    if (!password) {
        [self finishCleanUp];
        [NSException raise:@"hdm singular mode cannot run without password" format:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError *error;
        NSString *pre = [hdmBid getPreSignHashAndError:&error];
        if (error) {
            NSLog(error.debugDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate singularShowNetworkFailure];
            });
            [self finishCleanUp];
            return;
        }
        NSData *sig = [coldFirst.key signHash:pre.hexToData];
        [hdmBid changeBidPasswordWithSignature:[sig base64EncodedStringWithOptions:0] andPassword:password andHotAddress:hotFirstAddress andError:&error];
        if (error) {
            NSLog(error.debugDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate singularShowNetworkFailure];
            });
            [self finishCleanUp];
            return;
        }
        BTHDMKeychain *keychain = [[BTHDMKeychain alloc] initWithMnemonicSeed:hotMnemonicSeed password:password andXRandom:encryptedColdMnemonicSeed.isXRandom];
        [keychain setSingularModeBackup:encryptedColdMnemonicSeed.toEncryptedString];
        [hdmBid save];
        [KeyUtil setHDKeyChain:keychain];
        [[PeerUtil instance] stopPeer];
        __block HDMSingular *s = self;
        __block BTHDMBid *bid = hdmBid;
        int count = HDM_ADDRESS_PER_SEED_PREPARE_COUNT - keychain.uncompletedAddressCount;
        if (count > 0) {
            [keychain prepareAddressesWithCount:count password:password andColdExternalPub:coldRoot];
        }
        [keychain completeAddressesWithCount:1 password:password andFetchBlock:^(NSString *password, NSArray *partialPubs) {
            NSError *e;
            [bid createHDMAddress:partialPubs andPassword:password andError:&e];
            if (e) {
                NSLog(error.debugDescription);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [s.delegate singularShowNetworkFailure];
                });
                [s finishCleanUp];
            }
        }];
        [[PeerUtil instance] startPeer];
        running = NO;
        isSingularMode = YES;
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [self.delegate singularServerFinishWithWords:coldWords andColdQr:coldQr];
    });
}

- (void)initHotFirst {
    BTBIP32Key *hotEx = [self rootFromMnemonic:hotMnemonicSeed];
    BTBIP32Key *hotFirst = [hotEx deriveSoftened:0];
    hotFirstAddress = hotFirst.key.address;
    [hotEx wipe];
    [hotFirst wipe];
}

- (void)initColdFirst {
    BTBIP32Key *coldEx = [self rootFromMnemonic:coldMnemonicSeed];
    coldRoot = coldEx.getPubKeyExtended;
    coldFirst = [coldEx deriveSoftened:0];
    [coldEx wipe];
}

- (void)onUEntropyGeneratingWithController:(UEntropyViewController *)controller collector:(UEntropyCollector *)collector andPassword:(NSString *)password {
    float progress = kStartProgress;
    float itemProgress = 1.0 - kStartProgress - kSaveProgress;
    NSTimeInterval startGeneratingTime = [[NSDate date] timeIntervalSince1970];
    [collector onResume];
    [collector start];
    [controller onProgress:progress];
    XRandom *xrandom = [[XRandom alloc] initWithDelegate:collector];
    if (controller.testShouldCancel) {
        return;
    }
    NSData *seed1 = [xrandom randomWithSize:32];
    NSData *seed2 = [xrandom randomWithSize:32];
    progress += itemProgress * kProgressKeyRate;
    [controller onProgress:progress];
    if (controller.testShouldCancel) {
        return;
    }
    [self setSeed1:seed1 andSeed2:seed2 withXRandom:YES];
    progress += itemProgress * kProgressEncryptRate;
    [controller onProgress:progress];
    [collector stop];
    while ([[NSDate new] timeIntervalSince1970] - startGeneratingTime < kMinGeneratingTime) {

    }
    [controller onSuccess];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.delegate singularHotFinish];
    });
}

- (BTBIP32Key *)rootFromMnemonic:(NSData *)mnemonic {
    NSData *seed = [[BTBIP39 sharedInstance] toSeed:[[BTBIP39 sharedInstance] toMnemonic:mnemonic] withPassphrase:@""];
    BTBIP32Key *master = [[BTBIP32Key alloc] initWithSeed:seed];
    BTBIP32Key *purpose = [master deriveHardened:44];
    BTBIP32Key *coinType = [purpose deriveHardened:0];
    BTBIP32Key *account = [coinType deriveHardened:0];
    BTBIP32Key *external = [account deriveSoftened:0];
    [master wipe];
    [purpose wipe];
    [coinType wipe];
    [account wipe];
    return external;
}

- (void)finishCleanUp {
    isSingularMode = NO;
    running = NO;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}
@end