//
//  TrashCanViewController.m
//  bither-ios
//
//  Created by noname on 14-11-19.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "TrashCanViewController.h"

@interface TrashCanViewController ()
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TrashCanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backPressed:(id)sender {
}

@end
