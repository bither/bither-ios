//
//  HotAddressViewController.m
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

#import "HotAddressViewController.h"
#import <Bitheri/BTAddressManager.h>
#import "HotAddressListCell.h"
#import "HotAddressListSectionHeader.h"
#import "AddressDetailViewController.h"
#import "UIViewController+PiShowBanner.h"
#import "BitherSetting.h"
#import "DialogWithActions.h"
#import "DialogPassword.h"
#import "DialogProgress.h"
#import "DialogHDMSeedWordList.h"
#import "DialogBlackQrCode.h"
#import "IOS7ContainerViewController.h"

typedef enum {
    SectionHD = 0, SectionHdMonitored = 1, SectionHDM = 2, SectionPrivate = 3, SectionWatchOnly = 4
} SectionType;

@interface HotAddressViewController () <UITableViewDataSource, UITableViewDelegate, SectionHeaderPressedDelegate, DialogPasswordDelegate> {
    NSMutableArray *_privateKeys;
    NSMutableArray *_watchOnlys;
    NSMutableArray *_hdms;
    NSMutableIndexSet *_foldedSections;
    NSString *password;
    SEL passwordSelector;
    DialogProgress *dp;
}
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(weak, nonatomic) IBOutlet UIImageView *ivNoAddress;

@end

@implementation HotAddressViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    _privateKeys = [NSMutableArray new];
    _watchOnlys = [NSMutableArray new];
    _hdms = [NSMutableArray new];
    _foldedSections = [NSMutableIndexSet indexSet];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotifications) name:BitherBalanceChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotifications) name:BTPeerManagerLastBlockChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotifications) name:BitherMarketUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:BTAddressManagerIsReady object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reload];
}

- (void)reload {
    if (![[BTAddressManager instance] isReady]) {
        return;
    }
    [_privateKeys removeAllObjects];
    [_watchOnlys removeAllObjects];
    [_hdms removeAllObjects];
    [_privateKeys addObjectsFromArray:[[BTAddressManager instance] privKeyAddresses]];
    [_watchOnlys addObjectsFromArray:[[BTAddressManager instance] watchOnlyAddresses]];
    if ([BTAddressManager instance].hasHDMKeychain) {
        [_hdms addObjectsFromArray:[BTAddressManager instance].hdmKeychain.addresses];
    }
    [self.tableView reloadData];
    self.ivNoAddress.hidden = !(_privateKeys.count == 0 && _watchOnlys.count == 0 && _hdms.count == 0 && ![BTAddressManager instance].hasHDAccountHot && ![BTAddressManager instance].hasHDAccountMonitored);
}

- (void)receivedNotifications {
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isSectionFolded:section]) {
        return 0;
    }
    switch ([self sectionTypeForIndex:section]) {
        case SectionHD:
            return 1;
        case SectionHdMonitored:
            return 1;
        case SectionHDM:
            return _hdms.count;
        case SectionPrivate:
            return _privateKeys.count;
        case SectionWatchOnly:
            return _watchOnlys.count;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HotAddressListCell *cell = (HotAddressListCell *) [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    switch ([self sectionTypeForIndex:indexPath.section]) {
        case SectionHD:
            [cell setAddress:[BTAddressManager instance].hdAccountHot];
            break;
        case SectionHdMonitored:
            [cell setAddress:[BTAddressManager instance].hdAccountMonitored];
            break;
        case SectionPrivate:
            [cell setAddress:[_privateKeys objectAtIndex:indexPath.row]];
            break;
        case SectionWatchOnly:
            [cell setAddress:[_watchOnlys objectAtIndex:indexPath.row]];
            break;
        case SectionHDM:
            [cell setAddress:[_hdms objectAtIndex:indexPath.row]];
            break;
    }
    cell.viewController = self;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = 0;
    if ([BTAddressManager instance].hasHDAccountHot) {
        sections++;
    }
    if ([BTAddressManager instance].hasHDAccountMonitored) {
        sections++;
    }
    if (_privateKeys.count > 0) {
        sections++;
    }
    if (_watchOnlys.count > 0) {
        sections++;
    }
    if (_hdms.count > 0) {
        sections++;
    }
    return sections;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SectionType type = [self sectionTypeForIndex:section];
    return [[HotAddressListSectionHeader alloc] initWithSize:CGSizeMake(tableView.frame.size.width, tableView.sectionHeaderHeight) isHD:type == SectionHD isHdMonitored:type == SectionHdMonitored isHDM:type == SectionHDM isPrivate:type == SectionPrivate section:section delegate:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BTAddress *address;
    switch ([self sectionTypeForIndex:indexPath.section]) {
        case SectionHD:
            address = [BTAddressManager instance].hdAccountHot;
            break;
        case SectionHdMonitored:
            address = [BTAddressManager instance].hdAccountMonitored;
            break;
        case SectionPrivate:
            address = [_privateKeys objectAtIndex:indexPath.row];
            break;
        case SectionWatchOnly:
            address = [_watchOnlys objectAtIndex:indexPath.row];
            break;
        case SectionHDM:
            address = [_hdms objectAtIndex:indexPath.row];
            break;
        default:
            return;
    }
    AddressDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressDetail"];
    controller.address = address;
    UINavigationController *nav = self.navigationController;
    [nav pushViewController:controller animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)isSectionFolded:(NSUInteger)section {
    return [_foldedSections containsIndex:section];
}

- (void)sectionHeaderPressed:(NSUInteger)section {
    if ([self isSectionFolded:section]) {
        [_foldedSections removeIndex:section];
    } else {
        [_foldedSections addIndex:section];
    }
    NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:section];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)hdmAddPressed {
    if ([BTAddressManager instance].hdmKeychain.isInRecovery) {
        [self showMsg:NSLocalizedString(@"hdm_keychain_recovery_warn", nil)];
        return;
    }
    if ([BTAddressManager instance].hdmKeychain.allCompletedAddresses.count >= HDM_ADDRESS_PER_SEED_COUNT_LIMIT) {
        [self showMsg:NSLocalizedString(@"hdm_address_count_limit", nil)];
        return;
    }
    UIViewController *add = [self.storyboard instantiateViewControllerWithIdentifier:@"AddHDMAddress"];
    IOS7ContainerViewController *container = [[IOS7ContainerViewController alloc] init];
    container.controller = add;
    [self presentViewController:container animated:YES completion:nil];
}

- (void)hdmSeedPressed {
    if ([BTAddressManager instance].hdmKeychain.isInRecovery) {
        [self showMsg:NSLocalizedString(@"hdm_keychain_recovery_warn", nil)];
        return;
    }
    [[[DialogWithActions alloc] initWithActions:@[
            [[Action alloc] initWithName:NSLocalizedString(@"hdm_hot_seed_qr_code", nil) target:self andSelector:@selector(showSeedQRCode)],
            [[Action alloc] initWithName:NSLocalizedString(@"hdm_hot_seed_word_list", nil) target:self andSelector:@selector(showPhrase)]
    ]] showInWindow:self.view.window];
}

- (void)showPhrase {
    if (!password) {
        passwordSelector = @selector(showPhrase);
        [[[DialogPassword alloc] initWithDelegate:self] showInWindow:self.view.window];
        return;
    }
    NSString *p = password;
    password = nil;
    __weak __block DialogProgress *d = dp;
    [d showInWindow:self.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSArray *words = [[BTAddressManager instance].hdmKeychain seedWords:p];
            dispatch_async(dispatch_get_main_queue(), ^{
                [d dismissWithCompletion:^{
                    [[[DialogHDMSeedWordList alloc] initWithWords:words] showInWindow:self.view.window];
                }];
            });
        });
    }];
}

- (void)showSeedQRCode {
    if (!password) {
        passwordSelector = @selector(showSeedQRCode);
        [[[DialogPassword alloc] initWithDelegate:self] showInWindow:self.view.window];
        return;
    }
    password = nil;
    __weak __block DialogProgress *d = dp;
    [d showInWindow:self.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            __block NSString *pub = [[BTAddressManager instance].hdmKeychain getFullEncryptPrivKeyWithHDMFlag];
            dispatch_async(dispatch_get_main_queue(), ^{
                [d dismissWithCompletion:^{
                    DialogBlackQrCode *d = [[DialogBlackQrCode alloc] initWithContent:pub andTitle:NSLocalizedString(@"hdm_cold_seed_qr_code", nil)];
                    [d showInWindow:self.view.window];
                }];
            });
        });
    }];
}

- (SectionType)sectionTypeForIndex:(NSUInteger)section {
    if (section == [self sectionIndexForType:SectionHD]) {
        return SectionHD;
    }
    if (section == [self sectionIndexForType:SectionHdMonitored]) {
        return SectionHdMonitored;
    }
    if (section == [self sectionIndexForType:SectionHDM]) {
        return SectionHDM;
    }
    if (section == [self sectionIndexForType:SectionPrivate]) {
        return SectionPrivate;
    }
    if (section == [self sectionIndexForType:SectionWatchOnly]) {
        return SectionWatchOnly;
    }
    return nil;
}

- (NSUInteger)sectionIndexForType:(SectionType)type {
    if (type == SectionHD) {
        if ([BTAddressManager instance].hasHDAccountHot) {
            return 0;
        } else {
            return -1;
        }
    }
    if (type == SectionHdMonitored) {
        if (![BTAddressManager instance].hasHDAccountMonitored) {
            return -1;
        }
        NSUInteger index = 0;
        if ([BTAddressManager instance].hasHDAccountHot) {
            index++;
        }
        return index;
    }
    if (type == SectionHDM) {
        if (_hdms.count == 0) {
            return -1;
        }
        NSUInteger index = 0;
        if ([BTAddressManager instance].hasHDAccountHot) {
            index++;
        }
        if ([BTAddressManager instance].hasHDAccountMonitored) {
            index++;
        }
        return index;
    }
    if (type == SectionPrivate) {
        if (_privateKeys.count == 0) {
            return -1;
        }
        NSUInteger index = 0;
        if ([BTAddressManager instance].hasHDAccountHot) {
            index++;
        }
        if ([BTAddressManager instance].hasHDAccountMonitored) {
            index++;
        }
        if (_hdms.count > 0) {
            index++;
        }
        return index;
    }
    if (type == SectionWatchOnly) {
        if (_watchOnlys.count == 0) {
            return -1;
        }
        NSUInteger index = 0;
        if ([BTAddressManager instance].hasHDAccountHot) {
            index++;
        }
        if ([BTAddressManager instance].hasHDAccountMonitored) {
            index++;
        }
        if (_hdms.count > 0) {
            index++;
        }
        if (_privateKeys.count > 0) {
            index++;
        }
        return index;
    }
    return -1;
}

- (void)onPasswordEntered:(NSString *)p {
    password = p;
    if (passwordSelector && [self respondsToSelector:passwordSelector]) {
        [self performSelector:passwordSelector];
    }
    passwordSelector = nil;
}


- (void)showMsg:(NSString *)msg {
    [self showBannerWithMessage:msg belowView:nil belowTop:0 autoHideIn:1 withCompletion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BitherBalanceChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BTPeerManagerLastBlockChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BTAddressManagerIsReady object:nil];
}
@end
