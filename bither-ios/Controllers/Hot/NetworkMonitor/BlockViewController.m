//
//  BlockViewController.m
//  bither-ios
//
//  Created by noname on 14-9-1.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "BlockViewController.h"
#import "BlockCell.h"
#import "BTBlockChain.h"
#import "BitherSetting.h"
#import "UIViewController+ConfigureTableView.h"

@interface BlockViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSArray * blocks;

@end

@implementation BlockViewController


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
    self.blocks=[[BTBlockChain instance] getAllBlocks];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(receivedNotifications) name:BTPeerManagerLastBlockChangedNotification object:nil];
     [self configureHeaderAndFooterNoLogo:self.tableView background:ColorBg];
    // Do any additional setup after loading the view.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BTPeerManagerLastBlockChangedNotification object:nil];
}

-(void) receivedNotifications{
    self.blocks=[[BTBlockChain instance] getAllBlocks];
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
    return self.blocks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BlockCell *cell = (BlockCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell setBlock:[self.blocks objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}



@end
