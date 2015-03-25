//
//  DialogHDMAddressOptions.m
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
//  Created by songchenwen on 15/2/3.
//

#import "DialogHDMAddressOptions.h"
#import "UserDefaultsUtil.h"

@interface DialogHDMAddressOptions ()
@property BTAddress *address;
@property(weak) NSObject <DialogAddressAliasDelegate> *aliasDelegate;
@end

@implementation DialogHDMAddressOptions
- (instancetype)initWithAddress:(BTAddress *)address andAddressAliasDelegate:(NSObject <DialogAddressAliasDelegate> *)aliasDelegate {
    NSMutableArray *actions = [NSMutableArray new];
    [actions addObject:[[Action alloc] initWithName:NSLocalizedString(@"View on Blockchain.info", nil) target:self andSelector:@selector(viewOnBlockchain)]];
    if ([UserDefaultsUtil instance].localeIsChina || [[UserDefaultsUtil instance] localeIsZHHant]) {
        [actions addObject:[[Action alloc] initWithName:NSLocalizedString(@"address_option_view_on_blockmeta", nil) target:self andSelector:@selector(viewOnBlockmeta)]];
    }
    if (aliasDelegate) {
        [actions addObject:[[Action alloc] initWithName:NSLocalizedString(@"address_alias_manage", nil) target:self andSelector:@selector(addressAlias)]];
    }
    self = [super initWithActions:actions];
    if (self) {
        self.address = address;
        self.aliasDelegate = aliasDelegate;
    }
    return self;
}

- (void)addressAlias {
    [[[DialogAddressAlias alloc] initWithAddress:self.address andDelegate:self.aliasDelegate] showInWindow:self.window];
}

- (void)viewOnBlockchain {
    NSString *url = [NSString stringWithFormat:@"http://blockchain.info/address/%@", self.address.address];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)viewOnBlockmeta {
    NSString *url = [NSString stringWithFormat:@"http://www.blockmeta.com/address/%@", self.address.address];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end