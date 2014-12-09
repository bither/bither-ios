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

#import "ColdAddressViewController.h"
#import "ColdAddressListCell.h"
#import "UIViewController+PiShowBanner.h"
#import <Bitheri/BTAddress.h>
#import <Bitheri/BTAddressManager.h>

@interface ColdAddressViewController ()<UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *ivNoAddress;
@property NSMutableArray *addresses;
@end

@implementation ColdAddressViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.addresses = [[NSMutableArray alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:BTAddressManagerIsReady object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reload];
}

-(void)reload{
    if (![[BTAddressManager instance] isReady]) {
        return;
    }
    [self.addresses removeAllObjects];
    [self.addresses addObjectsFromArray:[BTAddressManager instance].privKeyAddresses];
    [self.tableView reloadData];
    self.ivNoAddress.hidden = !(self.addresses.count == 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.addresses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ColdAddressListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell showAddress:[self.addresses objectAtIndex:indexPath.row]];
    return cell;
}

-(void)showMsg:(NSString*)msg{
    [self showBannerWithMessage:msg belowView:nil belowTop:0 autoHideIn:1 withCompletion:nil];
}
-(void)dealloc{
 [[NSNotificationCenter defaultCenter ] removeObserver:self name:BTAddressManagerIsReady object:nil];
}


@end
