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

@interface AddressDetailViewController ()<UITableViewDataSource,UITableViewDelegate,DialogAddressOptionsDelegate,DialogPasswordDelegate>{
    NSMutableArray *_txs;
}
@property (weak, nonatomic) IBOutlet UIView *vTopBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation AddressDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _txs = [[NSMutableArray alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self configureTableHeader];
    [self configureTableFooter];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:BitherBalanceChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lastBlockChanged) name:BTPeerManagerLastBlockChangedNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if([StringUtil compareString:self.address.address compare:[AppDelegate notificationWindow].notificationAddress]){
        [[AppDelegate notificationWindow] removeNotification];
    }
    [self refresh];
}


-(void)lastBlockChanged{
    if(self.address.isSyncComplete){
        [self refresh];
    }
}

-(void)refresh{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *txs = [self.address txs];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_txs removeAllObjects];
            [_txs addObjectsFromArray:txs];
            [self.tableView reloadData];
            self.tableView.tableFooterView.hidden = (_txs.count > 0);
        });
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }else if(section == 1){
        return _txs.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        AddressDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressDetailCell" forIndexPath:indexPath];
        [cell showAddress:self.address];
        return cell;
    }else if(indexPath.section == 1){
        TransactionCell *cell =[tableView dequeueReusableCellWithIdentifier:@"TransactionCell" forIndexPath:indexPath];
        [cell showTx:[_txs objectAtIndex:indexPath.row] byAddress:self.address];
        return cell;
    }
    return nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 155;
    }else if(indexPath.section == 1){
        return 70;
    }
    return 0;
}

- (IBAction)optionPressed:(id)sender {
    DialogAddressOptions *dialog = [[DialogAddressOptions alloc]initWithAddress:self.address andDelegate:self];
    [dialog showInWindow:self.view.window];
}

-(void)stopMonitorAddress{
    [[[DialogAlert alloc]initWithMessage:NSLocalizedString(@"Sure to stop monitoring this address?", nil) confirm:^{
        [KeyUtil stopMonitor:self.address];
        [self.navigationController popViewControllerAnimated:YES];
    } cancel:nil]showInWindow:self.view.window];
}

-(void)showAddressOnBlockChainInfo{
    NSString *url = [NSString stringWithFormat:@"http://blockchain.info/address/%@",self.address.address];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

-(void)showPrivateKeyQrCode{
    DialogPassword *dialog = [[DialogPassword alloc]initWithDelegate:self];
    [dialog showInWindow:self.view.window];
}

-(void)onPasswordEntered:(NSString *)password{
    DialogPrivateKeyEncryptedQrCode *dialog = [[DialogPrivateKeyEncryptedQrCode alloc]initWithAddress:self.address];
    [dialog showInWindow:self.view.window];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showMessage:(NSString *)msg{
    [self showBannerWithMessage:msg belowView:self.vTopBar];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BitherBalanceChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BTPeerManagerLastBlockChangedNotification object:nil];
}

-(void)configureTableHeader{
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0, -self.tableView.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    v.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1];
    UIImageView *iv = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"setting_footer_logo"]];
    iv.frame = CGRectMake((v.frame.size.width - iv.frame.size.width) / 2, v.frame.size.height - iv.frame.size.height - (155 - iv.frame.size.height)/2, iv.frame.size.width, iv.frame.size.height);
    [v addSubview:iv];
    self.tableView.tableHeaderView = v;
    self.tableView.contentInset = UIEdgeInsetsMake(-v.frame.size.height, 0, 0, 0);
}

-(void)configureTableFooter{
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    self.tableView.tableFooterView.clipsToBounds = NO;
    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, self.tableView.frame.size.width - 20, 0)];
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
    [self.tableView.tableFooterView addSubview:lbl];
    self.tableView.tableFooterView.hidden = YES;
}
@end
