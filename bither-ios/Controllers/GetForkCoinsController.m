//
//  GetForkCoinsController.m
//  bither-ios
//
//  Created by 张陆军 on 2018/1/19.
//  Copyright © 2018年 Bither. All rights reserved.
//

#import "GetForkCoinsController.h"
#import "SettingListCell.h"
#import "DialogEditPassword.h"
#import "UIViewController+ConfigureTableView.h"
#import "DialogAddressQrCopy.h"

@interface GetForkCoinsController () <UITableViewDataSource, UITableViewDelegate, DialogEditPasswordDelegate>
@property(weak, nonatomic) IBOutlet UIView *vTopBar;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@end

@implementation GetForkCoinsController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView reloadData];
    _lblTitle.text = NSLocalizedString(@"get_fork_coins",nil);
    [self configureHeaderAndFooter];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//DialogEditPassword
- (void)showMsg:(NSString *)msg {
    [self showBannerWithMessage:msg belowView:self.vTopBar];
}

- (void)showBannerWithMessage:(NSString *)msg {
    [self showMsg:msg];
}

//tableview delgate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.settings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingListCell *cell = (SettingListCell *) [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell setSetting:[self.settings objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)reload {
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Setting *setting = [self.settings objectAtIndex:indexPath.row];
    if (setting.selectBlock) {
        setting.selectBlock(self);
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [tableView reloadData];
}

- (UIView *)donateView {
    CGFloat addressHeight = 13;
    CGFloat addressTop = 1;
    CGFloat rowHeight = 44;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(10, -1, self.tableView.frame.size.width - 20, rowHeight + addressHeight + addressTop)];
    v.backgroundColor = [UIColor whiteColor];
    UIButton *btnCopy = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, v.frame.size.width, v.frame.size.height)];
    [btnCopy setBackgroundImage:nil forState:UIControlStateNormal];
    [btnCopy setBackgroundImage:[UIImage imageNamed:@"card_foreground_pressed"] forState:UIControlStateHighlighted];
    btnCopy.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [btnCopy addTarget:self action:@selector(donateQr:) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:btnCopy];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, v.frame.size.width - 8, rowHeight)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = NSLocalizedString(@"bither_team_address", nil);
    lbl.textColor = [UIColor blackColor];
    lbl.font = [UIFont systemFontOfSize:18];
    CGSize lblSize = [lbl sizeThatFits:CGSizeMake(v.frame.size.width, CGFLOAT_MAX)];
    CGFloat paddingVertical = (rowHeight - lblSize.height) / 2;
    lbl.frame = CGRectMake(8, paddingVertical, v.frame.size.width - 8, lblSize.height);
    
    [v addSubview:lbl];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(8, CGRectGetMaxY(lbl.frame) + addressTop, self.tableView.frame.size.width, addressHeight)];
    lbl.textColor = [UIColor colorWithWhite:0.4 alpha:1];
    lbl.text = DONATE_ADDRESS;
    lbl.font = [UIFont systemFontOfSize:12];
    lbl.backgroundColor = [UIColor clearColor];
    [v addSubview:lbl];
    
    CGFloat iconSize = 25;
    CGFloat iconInsetsRight = 14;
    CGFloat iconInsetsLeft = 10;
    UIButton *btnQr = [[UIButton alloc] initWithFrame:CGRectMake(v.frame.size.width - iconInsetsRight - iconInsetsLeft - iconSize, 0, iconSize + iconInsetsLeft + iconInsetsRight, v.frame.size.height)];
    [btnQr setBackgroundImage:nil forState:UIControlStateNormal];
    [btnQr setBackgroundImage:[UIImage imageNamed:@"card_foreground_pressed"] forState:UIControlStateHighlighted];
    btnQr.contentEdgeInsets = UIEdgeInsetsMake(0, iconInsetsLeft, 0, iconInsetsRight);
    [btnQr setImage:[UIImage imageNamed:@"qr_code_button_icon"] forState:UIControlStateNormal];
    [btnQr addTarget:self action:@selector(donateQr:) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:btnQr];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, v.frame.size.width, 1)];
    separator.backgroundColor = [UIColor colorWithWhite:0 alpha:0.15];
    [v addSubview:separator];
    return v;
}

- (void)donateQr:(id)sender {
    [[[DialogAddressQrCopy alloc] initWithAddress:DONATE_ADDRESS andTitle:NSLocalizedString(@"bither_team_address", nil)] showInWindow:self.view.window];
}

- (void)toRawPrivateKey {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"RawPrivateKey"] animated:YES];
}

- (void)configureHeaderAndFooter {
    
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
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width,  ivBottom.frame.size.height)];
    footer.backgroundColor = [UIColor clearColor];
    vBottomCover.backgroundColor = ColorBg;
    [footer addSubview:vBottomCover];
    
    
    ivBottom.frame = CGRectMake(10, -1 , self.tableView.frame.size.width - 20, ivBottom.frame.size.height);
    [footer addSubview:ivBottom];
    ivBottomLeft.frame = CGRectMake(10, -1 - ivBottomLeft.frame.size.height , ivBottomLeft.frame.size.width, ivBottomLeft.frame.size.height);
    ivBottomRight.frame = CGRectMake(footer.frame.size.width - ivBottomRight.frame.size.width - 10, -1 - ivBottomRight.frame.size.height , ivBottomRight.frame.size.width, ivBottomRight.frame.size.height);
    [footer addSubview:ivBottomRight];
    [footer addSubview:ivBottomLeft];
    
    self.tableView.tableFooterView = footer;
}

@end

