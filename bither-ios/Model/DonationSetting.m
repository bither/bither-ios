//
//  DonationSetting.m
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

#import "DonationSetting.h"
#import "BTAddressManager.h"
#import "StringUtil.h"
#import "UnitUtil.h"
#import "UnsignedTransactionViewController.h"

static Setting *DonateSetting;

@implementation DonationSetting

+ (Setting *)getDonateSetting {
    if (!DonateSetting) {
        DonateSetting = [[DonationSetting alloc] init];
    }
    return DonateSetting;
}


- (instancetype)init {
    self = [super initWithName:NSLocalizedString(@"Donate", nil) icon:[UIImage imageNamed:@"donate_button_icon"]];
    if (self) {
        __weak DonationSetting *d = self;
        [self setSelectBlock:^(UIViewController *controller) {
            d.controller = controller;
            [d show];
        }];
    }
    return self;
}

- (void)show {
    self.addresses = [[NSMutableArray alloc] init];
    NSArray *as = [BTAddressManager instance].privKeyAddresses;
    for (BTAddress *a in as) {
        if (a.balance > 0) {
            [self.addresses addObject:a];
        }
    }
    as = [BTAddressManager instance].watchOnlyAddresses;
    for (BTAddress *a in as) {
        if (a.balance > 0) {
            [self.addresses addObject:a];
        }
    }
    if (self.addresses.count == 0) {
        if ([self.controller respondsToSelector:@selector(showMsg:)]) {
            [self.controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"No bitcoins available for donation.", nil)];
        }
        return;
    }
    [self.addresses sortUsingComparator:^NSComparisonResult(BTAddress *obj1, BTAddress *obj2) {
        return [self compare:obj1 and:obj2];
    }];

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select an address to donate", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (BTAddress *a in self.addresses) {
        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@ (%@%@)", [StringUtil shortenAddress:a.address], [UnitUtil stringForAmount:a.balance], [UnitUtil unitName]]];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.cancelButtonIndex = self.addresses.count;
    [actionSheet showInView:self.controller.navigationController.view];
}

- (NSComparisonResult)compare:(BTAddress *)obj1 and:(BTAddress *)obj2 {
    if (obj1.hasPrivKey && !obj2.hasPrivKey) {
        return NSOrderedAscending;
    } else if (!obj1.hasPrivKey && obj2.hasPrivKey) {
        return NSOrderedDescending;
    }
    uint64_t balance1 = obj1.balance;
    uint64_t balance2 = obj2.balance;
    if (balance1 > balance2) {
        return NSOrderedAscending;
    } else if (balance1 == balance2) {
        return NSOrderedSame;
    } else {
        return NSOrderedDescending;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex >= 0 && buttonIndex < self.addresses.count) {
        BTAddress *a = self.addresses[buttonIndex];
        if (a.hasPrivKey) {
            SendViewController *send = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"Send"];
            send.address = a;
            send.toAddress = DONATE_ADDRESS;
            send.amount = DONATE_AMOUNT < a.balance ? DONATE_AMOUNT : a.balance;
            send.sendDelegate = self;
            [self.controller.navigationController pushViewController:send animated:YES];
        } else {
            UnsignedTransactionViewController *unsignedTx = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"UnsignedTransaction"];
            unsignedTx.address = a;
            unsignedTx.toAddress = DONATE_ADDRESS;
            unsignedTx.amount = DONATE_AMOUNT < a.balance ? DONATE_AMOUNT : a.balance;
            unsignedTx.sendDelegate = self;
            [self.controller.navigationController pushViewController:unsignedTx animated:YES];
        }
    }
}

- (void)sendSuccessed:(BTTx *)tx {
    if ([self.controller respondsToSelector:@selector(showMsg:)]) {
        [self.controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"Thank you for donating.", nil)];
    }
}

@end
