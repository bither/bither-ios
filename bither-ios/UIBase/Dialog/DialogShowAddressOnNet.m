//
//  DialogShowAddressOnNet.m
//  bither-ios
//
//  Created by 宋辰文 on 15/7/20.
//  Copyright (c) 2015年 Bither. All rights reserved.
//

#import "DialogShowAddressOnNet.h"
#import "UserDefaultsUtil.h"

@interface DialogShowAddressOnNet () {
    NSString *_address;
}
@end

@implementation DialogShowAddressOnNet

- (instancetype)initWithAddress:(NSString *)address {
    NSMutableArray *array = [NSMutableArray new];
    [array addObject:[[Action alloc] initWithName:NSLocalizedString(@"View on Blockchain.info", nil) target:nil andSelector:@selector(showOnBlockchain)]];
    if ([UserDefaultsUtil instance].localeIsChina || [[UserDefaultsUtil instance] localeIsZHHant]) {
        [array addObject:[[Action alloc] initWithName:NSLocalizedString(@"address_option_view_on_blockmeta", nil) target:nil andSelector:@selector(showOnBlockMeta)]];
    }
    self = [super initWithActions:array];
    if (self) {
        _address = address;
    }
    return self;
}

- (void)showOnBlockchain {
    NSString *url = [NSString stringWithFormat:@"http://blockchain.info/address/%@", _address];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)showOnBlockMeta {
    NSString *url = [NSString stringWithFormat:@"http://www.blockmeta.com/address/%@", _address];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
