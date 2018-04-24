//
//  ObtainBccViewController.m
//  bither-ios
//
//  Created by 韩珍 on 2017/7/26.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "ObtainBccViewController.h"
#import "HotAddressListSectionHeader.h"
#import "DialogProgress.h"
#import "BTAddressManager.h"
#import "BitherSetting.h"
#import "UIViewController+PiShowBanner.h"
#import "ObtainBccCell.h"
#import "ObtainBccDetailViewController.h"
#import "BTHDAccountAddressProvider.h"
#import "BTTxBuilder.h"
#import "BTTxProvider.h"
#import "ObtainBccMonitoredDetailViewController.h"
#import "UserDefaultsUtil.h"

typedef enum {
    SectionHD = 0, SectionHdMonitored = 1, SectionPrivate = 2, SectionWatchOnly = 3
} SectionType;

@interface ObtainBccViewController () <UITableViewDataSource, UITableViewDelegate, SectionHeaderPressedDelegate, SendDelegate> {
    NSMutableArray *_privateKeys;
    NSMutableArray *_watchOnlys;
    NSMutableIndexSet *_foldedSections;
    DialogProgress *dp;
    NSUInteger _sections;
}

@property (weak, nonatomic) IBOutlet UIView *vTopBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@end

@implementation ObtainBccViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lblTitle.text = [NSString stringWithFormat:NSLocalizedString(@"get_split_coin_setting_name", nil), [SplitCoinUtil getSplitCoinName:self.splitCoin]];
    dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    _privateKeys = [NSMutableArray new];
    _watchOnlys = [NSMutableArray new];
    _foldedSections = [NSMutableIndexSet indexSet];
    [self.tableView reloadData];
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
    [_privateKeys addObjectsFromArray:[[BTAddressManager instance] privKeyAddresses]];
    [_watchOnlys addObjectsFromArray:[[BTAddressManager instance] watchOnlyAddresses]];
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
        case SectionPrivate:
            return _privateKeys.count;
        case SectionWatchOnly:
            return _watchOnlys.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ObtainBccCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ObtainBccCell" forIndexPath:indexPath];
    BTAddress *address;
    NSString *getIsObtainKey;
    NSString *coinName = [SplitCoinUtil getSplitCoinName:self.splitCoin];
    BOOL isShowLine;
    BOOL isLastSection = indexPath.section == (_sections - 1);
    switch ([self sectionTypeForIndex:indexPath.section]) {
        case SectionHD:
            address = [BTAddressManager instance].hdAccountHot;
            getIsObtainKey = [NSString stringWithFormat:@"HDAccountHot%@", coinName];
            isShowLine = isLastSection;
            break;
        case SectionHdMonitored:
            getIsObtainKey = [NSString stringWithFormat:@"HDMonitored%@", coinName];
            address = [BTAddressManager instance].hdAccountMonitored;
            isShowLine = isLastSection;
            break;
        case SectionPrivate:
            address = [_privateKeys objectAtIndex:indexPath.row];
            getIsObtainKey = [NSString stringWithFormat:@"%@%@", address.address, coinName];
            isShowLine = isLastSection || indexPath.row != (_privateKeys.count - 1);
            break;
        case SectionWatchOnly:
            address = [_watchOnlys objectAtIndex:indexPath.row];
            getIsObtainKey = [NSString stringWithFormat:@"%@%@", address.address, coinName];
            isShowLine = isLastSection || indexPath.row != (_watchOnlys.count - 1);
            break;
    }
    
    if ([[UserDefaultsUtil instance] getIsObtainBccForKey:getIsObtainKey]) {
        [cell setObtainedForAddress:address splitCoin: self.splitCoin isShowLine:isShowLine];
        cell.userInteractionEnabled = NO;
    } else {
        if ([address isMemberOfClass:[BTHDAccount class]]) {
            BTHDAccount *hdAccount = (BTHDAccount *) address;
            [cell setAddress:address bccBalance:[BTTxBuilder getAmount:[[BTHDAccountAddressProvider instance] getPrevCanSplitOutsByHDAccount:(int)[hdAccount getHDAccountId] coin:[SplitCoinUtil getCoin:self.splitCoin]]] splitCoin: self.splitCoin isShowLine:isShowLine];
        } else {
            [cell setAddress:address bccBalance:[BTTxBuilder getAmount:[[BTTxProvider instance] getPrevOutsWithAddress:address.address coin:[SplitCoinUtil getCoin:self.splitCoin]]] splitCoin: self.splitCoin isShowLine:isShowLine];
        }
        cell.userInteractionEnabled = YES;
    }
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
    _sections = sections;
    return sections;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SectionType type = [self sectionTypeForIndex:section];
    return [[HotAddressListSectionHeader alloc] initWithSize:CGSizeMake(tableView.frame.size.width, tableView.sectionHeaderHeight) isHD:type == SectionHD isHdMonitored:type == SectionHdMonitored isHDM:false isPrivate:type == SectionPrivate section:section delegate:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BTAddress *address = [self getBTAddressForIndexPath:indexPath];
    if (!address.isSyncComplete) {
        [self showMsg:NSLocalizedString(@"no_sync_complete", nil)];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    UIViewController *vc;
    SectionType sectionType = [self sectionTypeForIndex:indexPath.section];
    if (sectionType == SectionHdMonitored || sectionType == SectionWatchOnly) {
        ObtainBccMonitoredDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ObtainBccMonitoredDetailViewController"];
        controller.splitCoin = self.splitCoin;
        controller.btAddress = address;
        if ([address isMemberOfClass:[BTHDAccount class]]) {
            controller.amount = [BTTxBuilder getAmount:[[BTHDAccountAddressProvider instance] getPrevCanSplitOutsByHDAccount:(int)[(BTHDAccount *) address getHDAccountId] coin:[SplitCoinUtil getCoin:self.splitCoin]]];
        } else {
            controller.amount = [BTTxBuilder getAmount:[[BTTxProvider instance] getPrevOutsWithAddress:address.address coin:[SplitCoinUtil getCoin:self.splitCoin]]];
        }
        controller.sendDelegate = self;
        vc = controller;
    } else {
        ObtainBccDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ObtainBccDetailViewController"];
        controller.splitCoin = self.splitCoin;
        controller.btAddress = address;
        if ([address isMemberOfClass:[BTHDAccount class]]) {
            controller.amount = [BTTxBuilder getAmount:[[BTHDAccountAddressProvider instance] getPrevCanSplitOutsByHDAccount:(int)[(BTHDAccount *) address getHDAccountId] coin:[SplitCoinUtil getCoin:self.splitCoin]]];
        } else {
            controller.amount = [BTTxBuilder getAmount:[[BTTxProvider instance] getPrevOutsWithAddress:address.address coin:[SplitCoinUtil getCoin:self.splitCoin]]];
        }
        controller.sendDelegate = self;
        vc = controller;
    }
    UINavigationController *nav = self.navigationController;
    [nav pushViewController:vc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BTAddress *)getBTAddressForIndexPath:(NSIndexPath *)indexPath {
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
    }
    return address;
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

- (SectionType)sectionTypeForIndex:(NSUInteger)section {
    if (section == [self sectionIndexForType:SectionHD]) {
        return SectionHD;
    }
    if (section == [self sectionIndexForType:SectionHdMonitored]) {
        return SectionHdMonitored;
    }
    if (section == [self sectionIndexForType:SectionPrivate]) {
        return SectionPrivate;
    }
    if (section == [self sectionIndexForType:SectionWatchOnly]) {
        return SectionWatchOnly;
    }
    return -1;
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
        if (_privateKeys.count > 0) {
            index++;
        }
        return index;
    }
    return -1;
}

- (void)sendSuccessed:(BTTx *)tx {
    [self showMsg:NSLocalizedString(@"get_success", nil)];
    [self.tableView reloadData];
}

- (void)showMsg:(NSString *)msg {
    [self showBannerWithMessage:msg belowView:self.vTopBar];
}


- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BTAddressManagerIsReady object:nil];
}

@end
