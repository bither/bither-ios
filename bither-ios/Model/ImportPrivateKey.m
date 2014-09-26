//
//  ImportPrivateKey.m
//  bither-ios
//
//  Created by noname on 14-9-25.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "ImportPrivateKey.h"
#import "BTKey+Bitcoinj.h"
#import "DialogProgress.h"
#import "BTPasswordSeed.h"
#import "UserDefaultsUtil.h"
#import "BTSettings.h"
#import "BTAddressManager.h"
#import "TransactionsUtil.h"
#import "KeyUtil.h"
#import "BTPrivateKeyUtil.h"
#import "BTQRCodeUtil.h"

@interface ImportPrivateKey()
@property(nonatomic,strong) NSString * passwrod;
@property(nonatomic,strong) NSString * content;
@property(nonatomic,readwrite) ImportPrivateKeyType importPrivateKeyType;
@property(nonatomic,weak) UIViewController * controller;
@property(nonatomic,strong) DialogProgress * dp;
@end

@implementation ImportPrivateKey
-(instancetype) initWithController:(NSString *)content passwrod:(NSString *)passwrod importPrivateKeyType:(ImportPrivateKeyType) importPrivateKeyType{
    self=[super init];
    if (self) {
        self.passwrod=passwrod;
        self.content=content;
        self.importPrivateKeyType=importPrivateKeyType;
    }
    return self;
}
-(void)importPrivateKey{
    self.dp= [[DialogProgress alloc]initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    [self.dp showInWindow:self.controller.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            BTKey * key=[self getKey];
            if (key==nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.importPrivateKeyType==BitherQrcode) {
                        [self showMsg:NSLocalizedString(@"Password wrong.",nil)];
                    }else{
                        [self showMsg:NSLocalizedString(@"Import failed.",nil)];
                    }
                    [self.dp dismiss];
                });
                return;
            }
            if ([self checkKey:key]) {
                [self checkSpecialAddress:key callback:^{
                    [self addKey:key];
                }];
                
            }
        });
        
    }];
    
}
-(void)checkSpecialAddress:(BTKey *)key callback:(VoidBlock) callback{
    if ([[BTSettings instance] getAppMode]==COLD) {
        if (callback) {
            callback();
        }
    }else{
        NSMutableArray * array=[NSMutableArray new];
        [array addObject:key.address];
        [TransactionsUtil checkAddress:array callback:^(id response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                AddressType addressType=(AddressType)[response integerValue];
                if (addressType==AddressNormal) {
                    if (callback) {
                        callback();
                    }
                }else if(addressType==AddressTxTooMuch){
                    [self showMsg:NSLocalizedString(@"Cannot import private key with large amount of transactions.", nil)];
                    
                    
                }else{
                    [self showMsg:NSLocalizedString(@"Cannot import private key with special transactions.", nil)];
                    
                }
                [self.dp dismiss];
            });
        }andErrorCallback:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMsg:NSLocalizedString(@"Network failure.", nil)];
                [self.dp dismiss];
            });
        }];
        
    }
}
-(BOOL)checkKey:(BTKey *)key {
    if (self.importPrivateKeyType==BitherQrcode) {
        BTPasswordSeed * passwrodSeed=[[UserDefaultsUtil instance] getPasswordSeed];
        if (passwrodSeed) {
            BOOL checkPassword=[passwrodSeed checkPassword:self.passwrod];
            if (checkPassword) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showMsg:NSLocalizedString(@"Password of the private key to import is different from ours. Import failed.", nil)];
                    [self.dp dismiss];
                    
                });
                return NO;
            }
            
        }
    }
    BTAddress *address=[[BTAddress alloc] initWithKey:key encryptPrivKey:nil isXRandom:key.isFromXRandom];
    if ([[[BTAddressManager instance] privKeyAddresses] containsObject:address]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showMsg:NSLocalizedString(@"This private key already exists.", nil)];
            [self.dp dismiss];
            
        });
        return NO;
    }else if([[[BTAddressManager instance] watchOnlyAddresses] containsObject:address]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showMsg:NSLocalizedString(@"Can\'t import Bither Cold private key.", nil)];
            [self.dp dismiss];
        });
        return NO;
    }
    return YES;
}
-(void)addKey:(BTKey *)key{
    BTAddress *address;
    if (self.importPrivateKeyType==BitherQrcode) {
        NSString * encryptKey=[BTQRCodeUtil replaceNewQRCode:self.content];
         address=[[BTAddress alloc] initWithAddress:encryptKey pubKey:key.publicKey hasPrivKey:YES isXRandom:key.isFromXRandom];
    }else{
        NSString * encryptKey=[BTPrivateKeyUtil getPrivateKeyString:key passphrase:self.passwrod];
        address=[[BTAddress alloc] initWithAddress:encryptKey pubKey:key.publicKey hasPrivKey:YES isXRandom:key.isFromXRandom];
    }
    if (address) {
        [KeyUtil addAddressList:[[NSArray alloc] initWithObjects:address, nil]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showMsg:NSLocalizedString(@"Import success.", nil)];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showMsg:NSLocalizedString(@"Import failed.", nil)];
        });
    }
    
   
}

-(BTKey *)getKey{
    switch (self.importPrivateKeyType) {
        case PrivateText:
            return [BTKey keyWithPrivateKey:self.content];
        case Bip38:
            return [BTKey keyWithPrivateKey:self.content];
        case BitherQrcode:
            return [ BTKey  keyWithBitcoinj:self.content andPassphrase:self.passwrod];
        default:
            break;
    }
    return nil;
}

-(void) showMsg:(NSString *)msg{
    if([self.controller respondsToSelector:@selector(showMsg:)]){
        [self.controller performSelector:@selector(showMsg:) withObject:msg];
    }
    
}

@end
