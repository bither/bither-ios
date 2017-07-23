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

@interface MessageSigningSetting () <UIActionSheetDelegate, DialogSignMessageSelectAddressDelegate, DialogPasswordDelegate>

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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"sign_message_setting_name", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    BTAddressManager *addressManager = [BTAddressManager instance];
    if (addressManager.hasHDAccountHot || addressManager.hasHDAccountCold || addressManager.privKeyAddresses.count > 0) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"sign_message_activity_name", nil)];
    }

    [actionSheet addButtonWithTitle:NSLocalizedString(@"verify_message_signature_activity_name", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    [actionSheet showInView:self.controller.view.window];
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex < 0) {
        return;
    }
    NSInteger reverseIndex = actionSheet.numberOfButtons - 2 - buttonIndex;
    switch (reverseIndex) {
        case 0:
            [self.controller.navigationController pushViewController:[self.controller.storyboard instantiateViewControllerWithIdentifier:@"VerifyMessageSignature"] animated:YES];
            break;
        case 1:
            [[[DialogSignMessageSelectAddress alloc] initWithDelegate:self] showInWindow:self.controller.view.window];
        default:
            break;
    }
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
