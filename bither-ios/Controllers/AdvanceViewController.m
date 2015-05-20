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
#import "UIViewController+ConfigureTableView.h"
#import "DialogBlackQrCode.h"

@interface AdvanceViewController () <UITableViewDataSource, UITableViewDelegate, DialogEditPasswordDelegate>
@property(weak, nonatomic) IBOutlet UIView *vTopBar;

@end

@implementation AdvanceViewController

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

    NSString *version = [NSString stringWithFormat:NSLocalizedString(@"Based on %@ %@", nil), BITHERI_NAME, BITHERI_VERSION];
    BOOL isHot = [[BTSettings instance] getAppMode] == HOT;
    if (isHot) {
        [self configureHeaderAndFooter];
    } else {
        [self configureHeaderAndFooter:self.tableView background:ColorBg isHot:isHot version:version logoTarget:self logoSelector:@selector(toRawPrivateKey)];
    }
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
    [btnCopy addTarget:self action:@selector(donateCopy:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)donateCopy:(id)sender {
    [UIPasteboard generalPasteboard].string = DONATE_ADDRESS;
    [self showMsg:NSLocalizedString(@"bither_team_address_copied", nil)];
}

- (void)donateQr:(id)sender {
    [[[DialogBlackQrCode alloc] initWithContent:DONATE_ADDRESS andTitle:NSLocalizedString(@"bither_team_address", nil)] showInWindow:self.view.window];
}

- (void)toRawPrivateKey {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"RawPrivateKey"] animated:YES];
}

- (void)configureHeaderAndFooter {
    NSString *version = [NSString stringWithFormat:NSLocalizedString(@"Based on %@ %@", nil), BITHERI_NAME, BITHERI_VERSION];

    UIImageView *ivTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_item_card_shadow_top"]];
    ivTop.contentMode = UIViewContentModeScaleToFill;
    UIView *vBottomCover = [[UIView alloc] initWithFrame:CGRectMake(0, -1, self.tableView.frame.size.width, 1)];
    UIImageView *ivBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_item_card_shadow_bottom"]];
    ivBottom.contentMode = UIViewContentModeScaleToFill;
    UIImageView *ivTopLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_item_card_corner_top_left"]];
    UIImageView *ivTopRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_item_card_corner_top_right"]];
    UIImageView *ivBottomLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_item_card_corner_bottom_left"]];
    UIImageView *ivBottomRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_item_card_corner_bottom_right"]];
    UIImageView *ivLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting_footer_logo"]];

    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, ivTop.frame.size.height)];
    header.backgroundColor = [UIColor clearColor];
    ivTop.frame = CGRectMake(10, 0, self.tableView.frame.size.width - 20, ivTop.frame.size.height);
    [header addSubview:ivTop];
    ivTopLeft.frame = CGRectMake(10, header.frame.size.height, ivTopLeft.frame.size.width, ivTopLeft.frame.size.height);
    ivTopRight.frame = CGRectMake(header.frame.size.width - ivTopRight.frame.size.width - 10, header.frame.size.height, ivTopRight.frame.size.width, ivTopRight.frame.size.height);
    [header addSubview:ivTopRight];
    [header addSubview:ivTopLeft];
    self.tableView.tableHeaderView = header;

    UIView *vDonation = [self donateView];

    CGFloat logoTopMargin = 8;
    CGFloat logoBottomMargin = 6;
    UILabel *lblVersion = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    lblVersion.textAlignment = NSTextAlignmentCenter;
    lblVersion.textColor = [UIColor colorWithWhite:1 alpha:0.6f];
    lblVersion.font = [UIFont systemFontOfSize:12];
    lblVersion.text = version;
    [lblVersion sizeToFit];

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, vDonation.frame.size.height + ivBottom.frame.size.height + logoTopMargin + ivLogo.frame.size.height + logoBottomMargin + lblVersion.frame.size.height)];
    footer.backgroundColor = [UIColor clearColor];
    vBottomCover.backgroundColor = ColorBg;
    [footer addSubview:vBottomCover];

    [footer addSubview:vDonation];

    ivBottom.frame = CGRectMake(10, -1 + vDonation.frame.size.height, self.tableView.frame.size.width - 20, ivBottom.frame.size.height);
    [footer addSubview:ivBottom];
    ivBottomLeft.frame = CGRectMake(10, -1 - ivBottomLeft.frame.size.height + vDonation.frame.size.height, ivBottomLeft.frame.size.width, ivBottomLeft.frame.size.height);
    ivBottomRight.frame = CGRectMake(footer.frame.size.width - ivBottomRight.frame.size.width - 10, -1 - ivBottomRight.frame.size.height + vDonation.frame.size.height, ivBottomRight.frame.size.width, ivBottomRight.frame.size.height);
    [footer addSubview:ivBottomRight];
    [footer addSubview:ivBottomLeft];
    ivLogo.frame = CGRectMake((footer.frame.size.width - ivLogo.frame.size.width) / 2, CGRectGetMaxY(ivBottom.frame) + logoTopMargin, ivLogo.frame.size.width, ivLogo.frame.size.height);
    [footer addSubview:ivLogo];
    lblVersion.frame = CGRectMake((footer.frame.size.width - lblVersion.frame.size.width) / 2, CGRectGetMaxY(ivLogo.frame) + logoBottomMargin, lblVersion.frame.size.width, lblVersion.frame.size.height);
    [footer addSubview:lblVersion];

    ivLogo.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureTel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toRawPrivateKey)];
    [ivLogo addGestureRecognizer:tapGestureTel];

    self.tableView.tableFooterView = footer;
}

@end
