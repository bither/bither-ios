//
//  DialogAddressAlias.m
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
//  Created by songchenwen on 2015/3/16.
//

#import <Bitheri/BTUtils.h>
#import "DialogAddressAlias.h"
#import "BTAddress.h"
#import "DialogAddressAliasInput.h"
#import "DialogAlert.h"

@interface DialogAddressAlias () {
    BTAddress *address;
}
@property(weak) NSObject <DialogAddressAliasDelegate> *delegate;
@property(weak) UIWindow *containerWindow;
@end

@implementation DialogAddressAlias
- (instancetype)initWithAddress:(BTAddress *)a andDelegate:(NSObject <DialogAddressAliasDelegate> *)delegate {
    BOOL hasAlias = ![BTUtils isEmpty:a.alias];
    self = [super initWithActions:@[
            [[Action alloc] initWithName:NSLocalizedString(hasAlias ? @"address_alias_edit" : @"address_alias_add", nil) target:self andSelector:@selector(setAlias)],
            [[Action alloc] initWithName:NSLocalizedString(@"address_alias_remove", nil) target:self andSelector:@selector(removeAlias)]
    ]];
    if (self) {
        self.delegate = delegate;
        address = a;
    }
    return self;
}

- (void)setAlias {
    [[[DialogAddressAliasInput alloc] initWithAddress:address andDelegate:self.delegate] showInWindow:self.containerWindow];
}

- (void)removeAlias {
    [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"address_alias_remove_confirm", nil) confirm:^{
        if (self.delegate) {
            [self.delegate onAddressAliasChanged:address alias:nil];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [address removeAlias];
        });
    }                              cancel:nil] showInWindow:self.containerWindow];
}

- (void)showInWindow:(UIWindow *)window completion:(void (^)())completion {
    self.containerWindow = window;
    BOOL hasAlias = ![BTUtils isEmpty:address.alias];
    if (!hasAlias) {
        [[[DialogAddressAliasInput alloc] initWithAddress:address andDelegate:self.delegate] showInWindow:window completion:completion];
        return;
    }
    [super showInWindow:window completion:completion];
}
@end