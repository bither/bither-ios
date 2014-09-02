//
//  NetworkMonitorViewController.m
//  bither-ios
//
//  Created by noname on 14-9-1.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "NetworkMonitorViewController.h"
#import "PiPageViewController.h"

@interface NetworkMonitorViewController ()<PiPageViewControllerDelegate>

@property (strong, nonatomic)PiPageViewController *page;
@property (weak, nonatomic) IBOutlet UISegmentedControl *vTab;
@property (weak, nonatomic) IBOutlet UIView *vTopBar;

@end

@implementation NetworkMonitorViewController

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
    [self configurePage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)configurePage{
    self.page = [[PiPageViewController alloc]initWithStoryboard:self.storyboard andViewControllerIdentifiers:[[NSArray alloc] initWithObjects:@"PeerViewController", @"BlockViewController", nil]];
    self.page.pageDelegate = self;
    [self addChildViewController:self.page];
    self.page.view.frame = CGRectMake(0, CGRectGetMaxY(self.vTopBar.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.vTopBar.frame));
    [self.view insertSubview:self.page.view atIndex:0];
    self.vTab.selectedSegmentIndex = 0;
}


-(void)pageIndexChanged:(int) index{
    self.vTab.selectedSegmentIndex = index;
}

- (IBAction)tabChanged:(id)sender {
    if(self.vTab.selectedSegmentIndex != self.page.index){
        [self.page setIndex:(int)self.vTab.selectedSegmentIndex animated:YES];
    }
}
@end















