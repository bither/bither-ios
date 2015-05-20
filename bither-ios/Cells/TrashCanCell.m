//
//  TrashCanCell.m
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

#import "TrashCanCell.h"
#import "UIBaseUtil.h"
#import "StringUtil.h"
#import "DialogAlert.h"
#import "BTAddressManager.h"
#import "PeerUtil.h"
#import "DialogProgress.h"
#import "DialogWithActions.h"
#import "UserDefaultsUtil.h"
#import "DialogAddressAlias.h"
#import "AddressAliasView.h"


#define kAliasMaxWidth (64)

@interface TrashCanCell () {
    BTAddress *_address;
}
@property(weak, nonatomic) IBOutlet AddressAliasView *btnAlias;
@property(weak, nonatomic) IBOutlet UILabel *lblAddress;
@end

@implementation TrashCanCell

- (IBAction)viewOnNetPressed:(id)sender {
    NSMutableArray *array = [NSMutableArray new];
    [array addObject:[[Action alloc] initWithName:NSLocalizedString(@"View on Blockchain.info", nil) target:self andSelector:@selector(showOnBlockchain)]];
    if ([UserDefaultsUtil instance].localeIsChina || [[UserDefaultsUtil instance] localeIsZHHant]) {
        [array addObject:[[Action alloc] initWithName:NSLocalizedString(@"address_option_view_on_blockmeta", nil) target:self andSelector:@selector(showOnBlockMeta)]];
    }
    [array addObject:[[Action alloc] initWithName:NSLocalizedString(@"address_alias_manage", nil) target:self andSelector:@selector(alias)]];
    [[[DialogWithActions alloc] initWithActions:array] showInWindow:self.window];
}

- (void)showOnBlockchain {
    NSString *url = [NSString stringWithFormat:@"http://blockchain.info/address/%@", self.address.address];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)showOnBlockMeta {
    NSString *url = [NSString stringWithFormat:@"http://www.blockmeta.com/address/%@", self.address.address];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)alias {
    [[[DialogAddressAlias alloc] initWithAddress:self.address andDelegate:self.btnAlias] showInWindow:self.window];
}

- (IBAction)restorePressed:(id)sender {
    [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"trash_address_restore", nil) confirm:^{
        __block DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
        [dp showInWindow:self.window completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [[PeerUtil instance] stopPeer];
                [[BTAddressManager instance] restorePrivKey:self.address];
                [[PeerUtil instance] startPeer];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIViewController *vc = self.getUIViewController;
                    if ([vc respondsToSelector:@selector(refresh)]) {
                        [vc performSelector:@selector(refresh) withObject:nil];
                    }
                    [dp dismiss];
                });
            });
        }];
    }                              cancel:nil] showInWindow:self.window];
}

- (IBAction)copyPressed:(id)sender {
    [UIPasteboard generalPasteboard].string = self.address.address;
    UIViewController *vc = self.getUIViewController;
    if ([vc respondsToSelector:@selector(showMsg:)]) {
        [vc performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"Address copied.", nil) afterDelay:0];
    }
}

- (void)setAddress:(BTAddress *)address {
    _address = address;
    self.btnAlias.maxWidth = kAliasMaxWidth;
    self.lblAddress.text = [StringUtil formatAddress:address.address groupSize:4 lineSize:12];
    self.btnAlias.address = address;
}

- (BTAddress *)address {
    return _address;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        for (UIView *currentView in self.subviews) {
            if ([currentView isKindOfClass:[UIScrollView class]]) {
                ((UIScrollView *) currentView).delaysContentTouches = NO;
                break;
            }
        }
    }
    return self;
}
@end
