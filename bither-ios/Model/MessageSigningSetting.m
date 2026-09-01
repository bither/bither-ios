//
//  MessageSigningSetting.m
//  bither-ios
//
//  Created by 宋辰文 on 14/12/26.
//  Copyright (c) 2014年 宋辰文. All rights reserved.
//

#import "MessageSigningSetting.h"
#import "BTAddressManager.h"
#import "DialogSignMessageSelectAddress.h"
#import "SignMessageViewController.h"
#import "SignMessageSelectAddressViewController.h"
#import "DialogPassword.h"
#import "StringUtil.h"
#import "BitherActionSheet.h"

@interface MessageSigningSetting () <DialogSignMessageSelectAddressDelegate, DialogPasswordDelegate>

@property(weak) UIViewController *controller;
@property PathType path;

@end

static MessageSigningSetting *S;

@implementation MessageSigningSetting

+ (MessageSigningSetting *)getMessageSigningSetting {
    if (!S) {
        S = [[MessageSigningSetting alloc] init];
    }
    return S;
}

- (instancetype)init {
    self = [super initWithName:NSLocalizedString(@"sign_message_setting_name", nil) icon:nil];
    if (self) {
        __weak MessageSigningSetting *s = self;
        [self setSelectBlock:^(UIViewController *controller) {
            s.controller = controller;
            [s show];
        }];
    }
    return self;
}

- (void)show {
    BTAddressManager *addressManager = [BTAddressManager instance];
    BOOL canSign = addressManager.hasHDAccountHot || addressManager.hasHDAccountCold || addressManager.privKeyAddresses.count > 0;
    NSArray *titles = canSign
        ? @[NSLocalizedString(@"sign_message_activity_name", nil), NSLocalizedString(@"verify_message_signature_activity_name", nil)]
        : @[NSLocalizedString(@"verify_message_signature_activity_name", nil)];
    BitherActionSheet *sheet = [[BitherActionSheet alloc] initWithTitle:NSLocalizedString(@"sign_message_setting_name", nil)
                                                           buttonTitles:titles
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                                 handler:^(NSInteger buttonIndex) {
        if (canSign && buttonIndex == 0) {
            [[[DialogSignMessageSelectAddress alloc] initWithDelegate:self] showInWindow:self.controller.view.window];
        } else {
            [self.controller.navigationController pushViewController:[self.controller.storyboard instantiateViewControllerWithIdentifier:@"VerifyMessageSignature"] animated:YES];
        }
    }];
    [sheet showInViewController:self.controller];
}

- (void)signMessageWithSignAddressType:(SignAddressType)signAddressType {
    if (signAddressType == Private) {
        SignMessageSelectAddressViewController *sign = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"SignMessageSelectAddress"];
        [sign showAddresses:[BTAddressManager instance].privKeyAddresses];
        [self.controller.navigationController pushViewController:sign animated:YES];
        return;
    }
    
    self.path = signAddressType == HDExternal ? EXTERNAL_ROOT_PATH : INTERNAL_ROOT_PATH;
    [[[DialogPassword alloc] initWithDelegate:self] showInWindow:self.controller.view.window];
}

- (void)onPasswordEntered:(NSString *)password {
    if ([StringUtil isEmpty:password]) {
        return;
    }
    
    SignMessageSelectAddressViewController *sign = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"SignMessageSelectAddress"];
    [sign showHdAddresses:_path password:password];
    [self.controller.navigationController pushViewController:sign animated:YES];
}


@end
