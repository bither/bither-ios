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

@interface ColdAddressListHDMCell(){
    BTHDMKeychain* _keychain;
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
    
}

-(void)scanServerQrCode{

}

-(void)showPhrase{
    
}

-(void)showSeedQRCode{
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
