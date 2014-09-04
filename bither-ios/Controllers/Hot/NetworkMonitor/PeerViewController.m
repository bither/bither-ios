//  PeerViewController.m
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


#import "PeerViewController.h"
#import "BTPeerManager.h"
#import "BTSettings.h"
#import "PeerCell.h"
#import "UIViewController+ConfigureTableView.h"
#import "BitherSetting.h"

@interface PeerViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray * peers;

@end

@implementation PeerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.peers=[NSMutableArray new];
    for(BTPeer * peer in  [BTPeerManager instance].connectedPeers){
        [self.peers addObject:peer];
    }
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(receivedNotifications) name:BTPeerManagerSyncFromSPVFinishedNotification object:nil];
    [self configureHeaderAndFooterNoLogo:self.tableView background:ColorBg];
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BTPeerManagerSyncFromSPVFinishedNotification object:nil];
}
-(void) receivedNotifications{
    [self.peers removeAllObjects];
    for(BTPeer * peer in  [BTPeerManager instance].connectedPeers){
        [self.peers addObject:peer];
    }
    if (self.tableView) {
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//tableview delgate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.peers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PeerCell *cell = (PeerCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell setPeer:[self.peers objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
