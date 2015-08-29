//
//  AddressDetailViewController.m
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

#import "AddressDetailViewController.h"
#import "AddressDetailCell.h"
#import "TransactionCell.h"
#import "UIViewController+PiShowBanner.h"
#import "DialogAddressOptions.h"
#import "DialogPassword.h"
#import "KeyUtil.h"
#import "DialogAlert.h"
#import "DialogPrivateKeyEncryptedQrCode.h"
#import "NSString+Size.h"
#import "AppDelegate.h"
#import "StringUtil.h"
#import <Bitheri/BTAddressManager.h>
#import <Bitheri/BTKey+BIP38.h>
#import "DialogAddressLongPressOptions.h"
#import "BitherSetting.h"
#import "DialogProgress.h"
#import "DialogPrivateKeyDecryptedQrCode.h"
#import "DialogPrivateKeyText.h"
#import "SignMessageViewController.h"
#import "DialogHDMAddressOptions.h"
#import "AddressAliasView.h"
#import "DialogHDAccountOptions.h"

@interface AddressDetailViewController () <UITableViewDataSource, UITableViewDelegate, DialogAddressOptionsDelegate
        , DialogPasswordDelegate, DialogPrivateKeyOptionsDelegate, DialogHDAccountOptionsDelegate> {
    NSMutableArray *_txs;
    PrivateKeyQrCodeType _qrcodeType;
    DialogHDAccountOptions *dialogHDAccountOptions;
    BOOL isMovingToTrash;
    BOOL hasMore;
    BOOL isLoading;
    int page;
}
@property(weak, nonatomic) IBOutlet UIView *vTopBar;
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(weak, nonatomic) IBOutlet AddressAliasView *btnAddressAlias;
@property(weak, nonatomic) IBOutlet UILabel *lblTitle;
@end

@implementation AddressDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    hasMore = YES;
    isLoading = NO;
    page = 1;
    _txs = [[NSMutableArray alloc] init];
    [self.lblTitle sizeToFit];
    self.btnAddressAlias.frame = CGRectMake(CGRectGetMaxX(self.lblTitle.frame) + 10, self.btnAddressAlias.frame.origin.y, self.btnAddressAlias.frame.size.width, self.btnAddressAlias.frame.size.height);
    self.btnAddressAlias.address = self.address;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self configureTableHeader];
    [self configureTableFooter];
    for (id view in self.tableView.subviews) {
        // looking for a UITableViewWrapperView
        if ([NSStringFromClass([view class]) isEqualToString:@"UITableViewWrapperView"]) {
            // this test is necessary for safety and because a "UITableViewWrapperView" is NOT a UIScrollView in iOS7
            if ([view isKindOfClass:[UIScrollView class]]) {
                // turn OFF delaysContentTouches in the hidden subview
                UIScrollView *scroll = (UIScrollView *) view;
                scroll.delaysContentTouches = NO;
            }
            break;
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:BitherBalanceChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lastBlockChanged) name:BTPeerManagerLastBlockChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([StringUtil compareString:self.address.address compare:[AppDelegate notificationWindow].notificationAddress]) {
        [[AppDelegate notificationWindow] removeNotification];
    }
    if (self.address.isHDAccount && self.address.hasPrivKey && [StringUtil compareString:kHDAccountPlaceHolder compare:[AppDelegate notificationWindow].notificationAddress]) {
        [[AppDelegate notificationWindow] removeNotification];
    }
    if (self.address.isHDAccount && !self.address.hasPrivKey && [StringUtil compareString:kHDAccountMonitoredPlaceHolder compare:[AppDelegate notificationWindow].notificationAddress]) {
        [[AppDelegate notificationWindow] removeNotification];
    }
    [self refresh];
}


- (void)lastBlockChanged {
    if (self.address.isSyncComplete) {
        [self refresh];
    }
}

- (void)refresh {
    page = 1;
    [self loadTx];
}

- (void)loadTx {
    if (isLoading) {
        return;
    }
    isLoading = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSArray *txs = [self.address txs:page];
        dispatch_async(dispatch_get_main_queue(), ^{


            if (txs && txs.count > 0) {
                if (page == 1) {
                    [_txs removeAllObjects];
                    [_txs addObjectsFromArray:txs];
                    [self.tableView reloadData];
                } else {
                    NSMutableArray *indexPathSet = [[NSMutableArray alloc] init];
                    for (BTTx *tx in txs) {
                        [_txs addObject:tx];
                        [indexPathSet addObject:[NSIndexPath indexPathForRow:_txs.count - 1 inSection:1]];
                    }
                    [self.tableView insertRowsAtIndexPaths:indexPathSet withRowAnimation:UITableViewRowAnimationAutomatic];
                }

                hasMore = YES;
            } else {
                hasMore = NO;
            }
            self.tableView.tableFooterView.hidden = (_txs.count > 0);
            [((UIView *) [self.tableView.tableFooterView.subviews objectAtIndex:0]) setHidden:NO];
            [((UIActivityIndicatorView *) [self.tableView.tableFooterView.subviews objectAtIndex:1]) stopAnimating];
            isLoading = NO;

        });
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return _txs.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        AddressDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressDetailCell" forIndexPath:indexPath];
        [cell showAddress:self.address];
        return cell;
    } else if (indexPath.section == 1) {
        TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TransactionCell" forIndexPath:indexPath];
        [cell showTx:[_txs objectAtIndex:indexPath.row] byAddress:self.address];
        if (indexPath.row > (_txs.count - 2) && !isLoading && hasMore) {
            page++;
            [self loadTx];
        }
        return cell;
    }

    return nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 155;
    } else if (indexPath.section == 1) {
        return 70;
    }
    return 0;
}

- (IBAction)optionPressed:(id)sender {
    if (self.address.isHDAccount) {
        dialogHDAccountOptions = [[DialogHDAccountOptions alloc] initWithHDAccount:self.address andDelegate:self];
        [dialogHDAccountOptions showInWindow:self.view.window];
    } else if (self.address.isHDM) {
        [[[DialogHDMAddressOptions alloc] initWithAddress:self.address andAddressAliasDelegate:self.btnAddressAlias] showInWindow:self.view.window];
    } else {
        DialogAddressOptions *dialog = [[DialogAddressOptions alloc] initWithAddress:self.address delegate:self andAliasDialog:self.btnAddressAlias];
        [dialog showInWindow:self.view.window];
    }
}

- (void)stopMonitorAddress {
    [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"Sure to stop monitoring this address?", nil) confirm:^{
        [KeyUtil stopMonitor:self.address];
        [self.navigationController popViewControllerAnimated:YES];
    }                              cancel:nil] showInWindow:self.view.window];
}

- (void)showAddressOnBlockChainInfo {
    NSString *url = [NSString stringWithFormat:@"http://blockchain.info/address/%@", self.address.address];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)showAddressOnBlockMeta {
    NSString *url = [NSString stringWithFormat:@"http://www.blockmeta.com/address/%@", self.address.address];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)showPrivateKeyQrCode {
    DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
    [dialog showInWindow:self.view.window];
}

- (void)showBIP38PrivateKey {
    _qrcodeType = BIP38;
    DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
    [dialog showInWindow:self.view.window];
}


- (void)onPasswordEntered:(NSString *)password {
    __block NSString *bpassword = password;
    password = nil;
    __block __weak AddressDetailViewController *vc = self;
    if (isMovingToTrash) {
        isMovingToTrash = NO;
        DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"trashing_private_key", nil)];
        [dp showInWindow:self.view.window completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [[BTAddressManager instance] trashPrivKey:vc.address];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dp dismissWithCompletion:^{
                        [vc.navigationController popViewControllerAnimated:YES];
                    }];
                });
            });
        }];
        return;
    }
    if (_qrcodeType == Encrypted) {
        DialogPrivateKeyEncryptedQrCode *dialog = [[DialogPrivateKeyEncryptedQrCode alloc] initWithAddress:vc.address];
        [dialog showInWindow:vc.view.window];
    } else {
        DialogProgress *dialogProgress = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
        [dialogProgress showInWindow:vc.view.window];
        if (_qrcodeType == BIP38) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                BTKey *key = [BTKey keyWithBitcoinj:self.address.fullEncryptPrivKey andPassphrase:bpassword];
                __block NSString *bip38 = [key BIP38KeyWithPassphrase:bpassword];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dialogProgress dismissWithCompletion:^{
                        DialogPrivateKeyDecryptedQrCode *dialogPrivateKey = [[DialogPrivateKeyDecryptedQrCode alloc] initWithAddress:self.address.address privateKey:bip38];
                        [dialogPrivateKey showInWindow:self.view.window];
                    }];
                });
            });
            return;
        }
        [self decrypted:bpassword callback:^(id response) {
            [dialogProgress dismiss];
            if (_qrcodeType == Decrypetd) {
                DialogPrivateKeyDecryptedQrCode *dialogPrivateKey = [[DialogPrivateKeyDecryptedQrCode alloc] initWithAddress:vc.address.address privateKey:response];
                [dialogPrivateKey showInWindow:vc.view.window];

            } else {
                DialogPrivateKeyText *dialogPrivateKeyText = [[DialogPrivateKeyText alloc] initWithPrivateKeyStr:response];
                [dialogPrivateKeyText showInWindow:vc.view.window];
            }
            bpassword = nil;
            response = nil;
        }];
    }
}

- (void)showPrivateKeyManagement {
    [[[DialogAddressLongPressOptions alloc] initWithAddress:self.address andDelegate:self] showInWindow:self.view.window];
}

- (void)signMessage {
    if (!self.address.hasPrivKey) {
        return;
    }
    SignMessageViewController *sign = [self.storyboard instantiateViewControllerWithIdentifier:@"SignMessage"];
    sign.address = self.address;
    [self.navigationController pushViewController:sign animated:YES];
}

- (void)showPrivateKeyDecryptedQrCode {
    _qrcodeType = Decrypetd;
    DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
    [dialog showInWindow:self.view.window];
}

- (void)showPrivateKeyEncryptedQrCode {
    _qrcodeType = Encrypted;
    DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
    [dialog showInWindow:self.view.window];
}

- (void)showPrivateKeyTextQrCode {
    _qrcodeType = Text;
    DialogPassword *dialog = [[DialogPassword alloc] initWithDelegate:self];
    [dialog showInWindow:self.view.window];
}

- (void)moveToTrash {
    if (self.address.balance > 0) {
        [self showMessage:NSLocalizedString(@"trash_with_money_warn", nil)];
    } else {
        isMovingToTrash = YES;
        DialogPassword *dp = [[DialogPassword alloc] initWithDelegate:self];
        [dp showInWindow:self.view.window];
    }
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showMessage:(NSString *)msg {
    [self showBannerWithMessage:msg belowView:self.vTopBar];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BitherBalanceChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BTPeerManagerLastBlockChangedNotification object:nil];
}

- (void)configureTableHeader {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, -self.tableView.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    v.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting_footer_logo"]];
    iv.frame = CGRectMake((v.frame.size.width - iv.frame.size.width) / 2, v.frame.size.height - iv.frame.size.height - (155 - iv.frame.size.height) / 2, iv.frame.size.width, iv.frame.size.height);
    [v addSubview:iv];
    self.tableView.tableHeaderView = v;
    self.tableView.contentInset = UIEdgeInsetsMake(-v.frame.size.height, 0, 0, 0);
}

- (void)configureTableFooter {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    self.tableView.tableFooterView.clipsToBounds = NO;
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.tableView.frame.size.width - 20, 0)];
    lbl.textColor = [UIColor lightGrayColor];
    lbl.font = [UIFont systemFontOfSize:13];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.contentMode = UIViewContentModeTop;
    lbl.numberOfLines = 0;
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = NSLocalizedString(@"No transactions found for this address,\nit has probably not been used on the network yet.", nil);
    CGFloat height = [lbl.text sizeWithRestrict:CGSizeMake(lbl.frame.size.width, CGFLOAT_MAX) font:lbl.font].height;
    CGRect frame = lbl.frame;
    frame.size.height = height;
    lbl.frame = frame;
    lbl.hidden = YES;
    [self.tableView.tableFooterView addSubview:lbl];

    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.frame = frame;
    [self.tableView.tableFooterView addSubview:indicatorView];
    [indicatorView startAnimating];

    self.tableView.tableFooterView.hidden = NO;
}

- (void)decrypted:(NSString *)password callback:(IdResponseBlock)callback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        BTKey *key = [BTKey keyWithBitcoinj:self.address.fullEncryptPrivKey andPassphrase:password];
        __block NSString *privateKey = key.privateKey;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(privateKey);
            }
        });
        key = nil;
    });
}

- (void)showBannerWithMessage:(NSString *)msg {
    [self showMessage:msg];
}

- (void)resetMonitorAddress {

}
@end
