//
//  NSError+HDMHttpErrorMessage.m
//  bither-ios
//
//  Created by 宋辰文 on 15/2/2.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import <Bitheri/BTUtils.h>
#import "NSError+HDMHttpErrorMessage.h"
#import "BitherSetting.h"

@implementation NSError (HDMHttpErrorMessage)

- (NSString *)msg {
    if (self.isHttp400) {
        switch (self.code) {
            case HDMBID_IS_ALREADY_EXISTS:
                return NSLocalizedString(@"hdm_exception_bid_already_exists", nil);
            case MESSAGE_SIGNATURE_IS_WRONG:
                return NSLocalizedString(@"hdm_keychain_add_sign_server_qr_code_error", nil);
            default:
                return NSLocalizedString(@"Network failure.", nil);
        }
    }
    return NSLocalizedString(@"Network failure.", nil);
}

- (BOOL)isHttp400 {
    return [BTUtils compareString:self.domain compare:ERR_API_400_DOMAIN];
}
@end
