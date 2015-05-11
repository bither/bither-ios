//
//  TrashCanViewController.m
//  bither-ios
//
//  Created by noname on 14-11-19.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "TrashCanViewController.h"
#import "BTAddress.h"
#import "BTAddressManager.h"
#import "TrashCanCell.h"
#import "UIViewController+PiShowBanner.h"

@interface TrashCanViewController () <UITableViewDataSource, UITableViewDelegate>
@property(weak, nonatomic) IBOutlet UIView *topBar;
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(weak, nonatomic) IBOutlet UILabel *lblEmpty;
@property NSMutableArray *addresses;
@end

@implementation TrashCanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    [self configureTableView];
    self.lblEmpty.text = NSLocalizedString(@"trash_can_empty", nil);
    self.lblEmpty.hidden = YES;
    self.addresses = [NSMutableArray new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self refresh];
}

- (void)refresh {
    [self.addresses removeAllObjects];
    [self.addresses addObjectsFromArray:[BTAddressManager instance].trashAddresses];
    [self.tableView reloadData];
    self.tableView.hidden = self.addresses.count == 0;
    self.lblEmpty.hidden = !self.tableView.hidden;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addresses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TrashCanCell *cell = (TrashCanCell *) [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.address = self.addresses[indexPath.row];
    return cell;
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showMsg:(NSString *)msg {
    [self showBannerWithMessage:msg belowView:self.topBar];
}

- (void)configureTableView {
    UIImageView *ivTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_item_card_shadow_top"]];
    ivTop.contentMode = UIViewContentModeScaleToFill;
    UIView *vBottomCover = [[UIView alloc] initWithFrame:CGRectMake(0, -1, self.tableView.frame.size.width, 1)];
    UIImageView *ivBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_item_card_shadow_bottom"]];
    ivBottom.contentMode = UIViewContentModeScaleToFill;
    UIImageView *ivTopLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_item_card_corner_top_left"]];
    UIImageView *ivTopRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_item_card_corner_top_right"]];
    UIImageView *ivBottomLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_item_card_corner_bottom_left"]];
    UIImageView *ivBottomRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_item_card_corner_bottom_right"]];

    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, ivTop.frame.size.height)];
    header.backgroundColor = [UIColor clearColor];

    ivTop.frame = CGRectMake(10, 0, self.tableView.frame.size.width - 20, ivTop.frame.size.height);
    [header addSubview:ivTop];
    ivTopLeft.frame = CGRectMake(10, header.frame.size.height, ivTopLeft.frame.size.width, ivTopLeft.frame.size.height);
    ivTopRight.frame = CGRectMake(header.frame.size.width - ivTopRight.frame.size.width - 10, header.frame.size.height, ivTopRight.frame.size.width, ivTopRight.frame.size.height);
    [header addSubview:ivTopRight];
    [header addSubview:ivTopLeft];
    self.tableView.tableHeaderView = header;

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, ivBottom.frame.size.height)];
    footer.backgroundColor = [UIColor clearColor];
    vBottomCover.backgroundColor = self.view.backgroundColor;
    [footer addSubview:vBottomCover];
    ivBottom.frame = CGRectMake(10, -1, self.tableView.frame.size.width - 20, ivBottom.frame.size.height);
    [footer addSubview:ivBottom];
    ivBottomLeft.frame = CGRectMake(10, -1 - ivBottomLeft.frame.size.height, ivBottomLeft.frame.size.width, ivBottomLeft.frame.size.height);
    ivBottomRight.frame = CGRectMake(footer.frame.size.width - ivBottomRight.frame.size.width - 10, -1 - ivBottomRight.frame.size.height, ivBottomRight.frame.size.width, ivBottomRight.frame.size.height);
    [footer addSubview:ivBottomRight];
    [footer addSubview:ivBottomLeft];

    self.tableView.tableFooterView = footer;
}

@end
