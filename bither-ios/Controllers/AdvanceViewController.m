//  AdvanceViewController.m
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

#import "AdvanceViewController.h"
#import "SettingListCell.h"
#import "DialogEditPassword.h"
#import "UIViewController+PiShowBanner.h"
#import "UIViewController+ConfigureTableView.h"
#import "BTSettings.h"

@interface AdvanceViewController ()<UITableViewDataSource,UITableViewDelegate,DialogEditPasswordDelegate>
@property (weak, nonatomic) IBOutlet UIView *vTopBar;

@end

@implementation AdvanceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.tableView reloadData];

    NSString * version= [NSString stringWithFormat:NSLocalizedString(@"Based on %@ %@", nil),BITHERI_NAME,BITHERI_VERSION ];
    BOOL isHot=[[BTSettings instance] getAppMode]==HOT;
    [self configureHeaderAndFooter:self.tableView background:ColorBg isHot:isHot version:version logoTarget:self logoSelector:@selector(toRawPrivateKey)];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//DialogEditPassword
-(void)showMsg:(NSString *)msg{
    [self showBannerWithMessage:msg belowView:self.vTopBar];
}

-(void)showBannerWithMessage:(NSString *)msg {
    [self showMsg:msg];
}

//tableview delgate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.settings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SettingListCell *cell = (SettingListCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell setSetting:[self.settings objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Setting *setting=[self.settings objectAtIndex:indexPath.row];
    if (setting.selectBlock) {
        setting.selectBlock(self);
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [tableView reloadData];
}

-(void)toRawPrivateKey{
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"RawPrivateKey"] animated:YES];
}

@end
