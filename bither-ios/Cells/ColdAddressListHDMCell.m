//
//  ColdAddressListHDMCell.m
//  bither-ios
//
//  Created by 宋辰文 on 15/1/30.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import "ColdAddressListHDMCell.h"
#import "DialogXrandomInfo.h"
#import "DialogWithActions.h"
#import "DialogPassword.h"
#import "DialogBlackQrCode.h"
#import "DialogProgress.h"

@interface ColdAddressListHDMCell()<DialogPasswordDelegate>{
    BTHDMKeychain* _keychain;
    NSString* password;
    SEL passwordSelector;
    DialogProgress *dp;
}
@property (weak, nonatomic) IBOutlet UIImageView *ivXRandom;
@property (weak, nonatomic) IBOutlet UIImageView *ivType;

@property (strong, nonatomic) UILongPressGestureRecognizer * longPress;
@property (strong, nonatomic) UILongPressGestureRecognizer * xrandomLongPress;
@end

@implementation ColdAddressListHDMCell

-(void)setKeychain:(BTHDMKeychain *)keychain{
    _keychain = keychain;
    if(!self.longPress){
        self.longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleTableviewCellLongPressed:)];
    }
    if(!self.xrandomLongPress){
        self.xrandomLongPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleXrandomLabelLongPressed:)];
    }
    if(![self.ivType.gestureRecognizers containsObject:self.longPress]){
        [self.ivType addGestureRecognizer:self.longPress];
    }
    if(![self.ivXRandom.gestureRecognizers containsObject:self.xrandomLongPress]){
        [self.ivXRandom addGestureRecognizer:self.xrandomLongPress];
    }
    if(!dp){
        dp = [[DialogProgress alloc]initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    }
    self.ivXRandom.hidden = !_keychain.isFromXRandom;
}

-(BTHDMKeychain*)keychain{
    return _keychain;
}

- (IBAction)seedPressed:(id)sender {
    [[[DialogWithActions alloc]initWithActions:@[
            [[Action alloc] initWithName:NSLocalizedString(@"hdm_cold_seed_qr_code", nil) target:self andSelector:@selector(showSeedQRCode)],
            [[Action alloc] initWithName:NSLocalizedString(@"hdm_cold_seed_word_list", nil) target:self andSelector:@selector(showPhrase)]
            ]] showInWindow:self.window];
}


- (IBAction)qrPressed:(id)sender {
    [[[DialogWithActions alloc]initWithActions:@[
            [[Action alloc] initWithName:NSLocalizedString(@"hdm_cold_pub_key_qr_code_name", nil) target:self andSelector:@selector(showAccountQrCode)],
            [[Action alloc] initWithName:NSLocalizedString(@"hdm_server_qr_code_name", nil) target:self andSelector:@selector(scanServerQrCode)]
            ]] showInWindow:self.window];
}

-(void)showAccountQrCode{
    if(!password){
        passwordSelector = @selector(showAccountQrCode);
        [[[DialogPassword alloc]initWithDelegate:self] showInWindow:self.window];
        return;
    }
    NSString* p = password;
    password = nil;
    __weak __block DialogProgress* d = dp;
    [d showInWindow:self.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString* pub = [self.keychain externalChainRootPubExtendedAsHex:p];
            dispatch_async(dispatch_get_main_queue(), ^{
                [d dismissWithCompletion:^{
                    DialogBlackQrCode* d = [[DialogBlackQrCode alloc]initWithContent:pub andTitle:NSLocalizedString(@"hdm_cold_pub_key_qr_code_name", nil)];
                    [d showInWindow:self.window];
                }];
            });
        });
    }];
}

-(void)scanServerQrCode{
    
    
}

-(void)showPhrase{
    if(!password){
        passwordSelector = @selector(showPhrase);
        [[[DialogPassword alloc]initWithDelegate:self] showInWindow:self.window];
        return;
    }
    NSString* p = password;
    password = nil;
    __weak __block DialogProgress* d = dp;
    [d showInWindow:self.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSArray* words = [self.keychain seedWords:p];
            dispatch_async(dispatch_get_main_queue(), ^{
                [d dismissWithCompletion:^{
                    
                }];
            });
        });
    }];
}

-(void)showSeedQRCode{
    if(!password){
        passwordSelector = @selector(showSeedQRCode);
        [[[DialogPassword alloc]initWithDelegate:self] showInWindow:self.window];
        return;
    }
    NSString* p = password;
    password = nil;
    __weak __block DialogProgress* d = dp;
    [d showInWindow:self.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString* pub = [self.keychain externalChainRootPubExtendedAsHex:p]; //TODO: set this qr code to full encrypt private key
            dispatch_async(dispatch_get_main_queue(), ^{
                [d dismissWithCompletion:^{
                    DialogBlackQrCode* d = [[DialogBlackQrCode alloc]initWithContent:pub andTitle:NSLocalizedString(@"hdm_cold_pub_key_qr_code_name", nil)];
                    [d showInWindow:self.window];
                }];
            });
        });
    }];
}


-(void)onPasswordEntered:(NSString*)p{
    password = p;
    if(passwordSelector && [self respondsToSelector:passwordSelector]){
        [self performSelector:passwordSelector];
    }
    passwordSelector = nil;
}

-(void)handleXrandomLabelLongPressed:(UILongPressGestureRecognizer*)gesture{
    if(gesture.state == UIGestureRecognizerStateBegan){
        [[[DialogXrandomInfo alloc]init] showInWindow:self.window];
    }
}

- (void) handleTableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state==UIGestureRecognizerStateBegan) {
        [self seedPressed:nil];
    }
}

@end
