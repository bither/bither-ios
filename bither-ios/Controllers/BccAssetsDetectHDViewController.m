//
//  BccAssetsDetectHDViewController.m
//  bither-ios
//
//  Created by LTQ on 2017/9/28.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "BccAssetsDetectHDViewController.h"
#import "BTBIP32Key.h"
#import "BTUtils.h"
#import "SignMessageSelectAddressCell.h"
#import "BTAddressManager.h"
#import "DetectAnotherAssetsUtil.h"
#import "UIViewController+PiShowBanner.h"
#import "BCCAssetsDetectTableViewController.h"
#import "HotAddressListSectionHeader.h"
#import "DialogProgress.h"
#import "BTAddressManager.h"
#import "BitherSetting.h"
#import "UIViewController+PiShowBanner.h"
#import "SendViewController.h"


@interface BccAssetsDetectHDViewController () <UITableViewDataSource, UITableViewDelegate, SendDelegate> {
    NSMutableArray *_addresses;
    int hdAccountId;
}
@property (weak, nonatomic) IBOutlet UIView *vTopBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property BTBIP32Key *bip32Key;
@property PathType pathType;
@property BTHDAccount *account;
@property BTHDAccount *hdAccountMonitored;
@property BOOL isMonitored;
@end

@implementation BccAssetsDetectHDViewController

- (void)showHdAddresses:(PathType)path password:(NSString *)password isMonitored: (BOOL) isMonitored {
    self.pathType = path;
    self.isMonitored = isMonitored;
    _addresses = [NSMutableArray new];
    BTAddressManager *addressManager = [BTAddressManager instance];
    if (!isMonitored) {
        self.bip32Key = [[addressManager.hdAccountHot xPub:password] deriveSoftened:path];
        hdAccountId = (int)addressManager.hdAccountHot.getHDAccountId;
        _account = [addressManager getHDAccountByHDAccountId:hdAccountId];
    }else {
        self.bip32Key = [[addressManager.hdAccountMonitored xPub:password] deriveSoftened:path];
        hdAccountId = (int)addressManager.hdAccountMonitored.getHDAccountId;
        _hdAccountMonitored = [addressManager getHDAccountByHDAccountId:hdAccountId];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lblTitle.text = NSLocalizedString(@"detect_another_BCC_assets_select_address", nil);
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_isMonitored) {
        if (_pathType == EXTERNAL_ROOT_PATH) {
            return _account.issuedExternalIndex + 1;
        } else {
            return _account.issuedInternalIndex + 1;
        }
    } else {
        if (_pathType == EXTERNAL_ROOT_PATH) {
            return _hdAccountMonitored.issuedExternalIndex + 1;
        } else {
            return _hdAccountMonitored.issuedInternalIndex + 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SignMessageSelectAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SignMessageSelectAddressCell" forIndexPath:indexPath];
    if (!_isMonitored) {
        [cell showByHDAccountAddress:[_account addressForPath: _pathType atIndex:indexPath.row]];
    } else {
        [cell showByHDAccountAddress:[_hdAccountMonitored addressForPath: _pathType atIndex:indexPath.row]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 81;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PathTypeIndex *pathTypeIndex = [[PathTypeIndex alloc]init];
    pathTypeIndex.pathType = _pathType;
    pathTypeIndex.index = indexPath.row;
    DetectAnotherAssetsUtil *detectUtil = [DetectAnotherAssetsUtil instance];
    detectUtil.controller = self;
    if (!_isMonitored) {
        [detectUtil getBCCHDUnspentOutputs:[_account addressForPath: _pathType atIndex:indexPath.row].address andPathType:pathTypeIndex andIsMonitored:_isMonitored];
    } else {
        [detectUtil getBCCHDUnspentOutputs:[_hdAccountMonitored addressForPath: _pathType atIndex:indexPath.row].address andPathType:pathTypeIndex andIsMonitored:_isMonitored];
    }
}

- (void)sendSuccessed:(BTTx *)tx {
    [self showMsg:NSLocalizedString(@"extract_success", nil)];
    [self.tableView reloadData];
}

- (void)showMsg:(NSString *)msg {
    [self showBannerWithMessage:msg belowView:self.vTopBar];
}


@end

