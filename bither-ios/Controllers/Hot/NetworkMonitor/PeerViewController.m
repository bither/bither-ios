//
//  PeerViewController.m
//  bither-ios
//
//  Created by noname on 14-9-1.
//  Copyright (c) 2014年 noname. All rights reserved.
//

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
