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
#import "UIBaseUtil.h"
#import "KeyUtil.h"
#import "BitherSetting.h"

@interface HotAddressViewController ()<UITableViewDataSource, UITableViewDelegate,SectionHeaderPressedDelegate>{
    NSMutableArray *_privateKeys;
    NSMutableArray *_watchOnlys;
    NSMutableIndexSet *_foldedSections;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *ivNoAddress;

@end

@implementation HotAddressViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _privateKeys = [[NSMutableArray alloc]initWithArray:[[BTAddressManager instance]privKeyAddresses]];
    _watchOnlys = [[NSMutableArray alloc]initWithArray:[[BTAddressManager instance]watchOnlyAddresses]];
    _foldedSections = [NSMutableIndexSet indexSet];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(receivedNotifications) name:BitherBalanceChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(receivedNotifications) name:BTPeerManagerLastBlockChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedNotifications) name:BitherMarketUpdateNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self reload];
}

-(void)reload{
    [_privateKeys removeAllObjects];
    [_watchOnlys removeAllObjects];
    [_privateKeys addObjectsFromArray:[[BTAddressManager instance]privKeyAddresses]];
    [_watchOnlys addObjectsFromArray:[[BTAddressManager instance]watchOnlyAddresses]];
    [self.tableView reloadData];
    self.ivNoAddress.hidden = !(_privateKeys.count == 0 && _watchOnlys.count == 0);
}

-(void)receivedNotifications{
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([self isSectionFolded:section]){
        return 0;
    }
    if([self isPrivateKeySection:section]){
        return _privateKeys.count;
    }else{
        return _watchOnlys.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HotAddressListCell*cell = (HotAddressListCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if([self isPrivateKeySection:indexPath.section]){
        [cell setAddress:[_privateKeys objectAtIndex:indexPath.row]];
    }else{
        [cell setAddress:[_watchOnlys objectAtIndex:indexPath.row]];
        cell.viewController=self;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger sections = 0;
    if(_privateKeys.count > 0){
        sections++;
    }
    if(_watchOnlys.count > 0){
        sections++;
    }
    return sections;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[HotAddressListSectionHeader alloc]initWithSize:CGSizeMake(tableView.frame.size.width, tableView.sectionHeaderHeight) isPrivate:[self isPrivateKeySection:section] section:section delegate:self];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BTAddress* address;
    if([self isPrivateKeySection:indexPath.section]){
        address = [_privateKeys objectAtIndex:indexPath.row];
    }else{
        address = [_watchOnlys objectAtIndex:indexPath.row];
    }
    AddressDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressDetail"];
    controller.address = address;
    UINavigationController *nav = self.navigationController;
    [nav pushViewController:controller animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(BOOL)isSectionFolded:(NSUInteger)section{
    return [_foldedSections containsIndex:section];
}

-(void)sectionHeaderPressed:(NSUInteger)section{
    if([self isSectionFolded:section]){
        [_foldedSections removeIndex:section];
    }else{
        [_foldedSections addIndex:section];
    }
    NSIndexSet *set = [[NSIndexSet alloc]initWithIndex:section];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(BOOL)isPrivateKeySection:(NSUInteger)section{
    NSInteger sectionCount = [self numberOfSectionsInTableView:self.tableView];
    if(sectionCount == 2){
        if(section == 0){
            return YES;
        }
    }else if(sectionCount == 1){
        if(_privateKeys.count > 0){
            return YES;
        }
    }
    return NO;
}

-(void)showMsg:(NSString *)msg{
    [self showBannerWithMessage:msg belowView:nil belowTop:0 autoHideIn:1 withCompletion:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter ] removeObserver:self name:BitherBalanceChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter ] removeObserver:self name:BTPeerManagerLastBlockChangedNotification object:nil];
}
@end
