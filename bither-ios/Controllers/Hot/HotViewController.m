//
//  HotViewController.m
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

#import "HotViewController.h"
#import "BitherSetting.h"
#import "IOS7ContainerViewController.h"
#import "KeyUtil.h"
#import "PeerUtil.h"
#import "HotAddressTabButton.h"
#import "BTPeerManager.h"
#import "BTAddressManager.h"
#import "UIViewController+PiShowBanner.h"
#import "UploadAndDowloadFileFactory.h"
#import "DialogFirstRunWarning.h"
#import "NetworkUtil.h"
#import "DialogAlert.h"

@interface HotViewController ()
@property(strong, nonatomic) NSArray *tabButtons;
@property(strong, nonatomic) IBOutlet TabButton *tabMarket;
@property(strong, nonatomic) IBOutlet HotAddressTabButton *tabAddress;
@property(strong, nonatomic) IBOutlet TabButton *tabSetting;
@property(weak, nonatomic) IBOutlet UIView *vTabe;
@property(weak, nonatomic) IBOutlet UIProgressView *pvSync;
@property(strong, nonatomic) PiPageViewController *page;
@property (weak, nonatomic) IBOutlet UIView *vAlert;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aivAlert;
@property (weak, nonatomic) IBOutlet UILabel *lblAlert;

@end

@implementation HotViewController

- (void)loadView {
    [super loadView];
    
    [self initTabs];
    self.page = [[PiPageViewController alloc] initWithStoryboard:self.storyboard andViewControllerIdentifiers:[[NSArray alloc] initWithObjects:@"tab_market", @"tab_hot_address", @"tab_option_hot", nil]];
    self.page.pageDelegate = self;
    [self addChildViewController:self.page];
    self.page.index = 1;
    self.page.view.frame = CGRectMake(0, TabBarHeight, self.view.frame.size.width, self.view.frame.size.height - TabBarHeight);
    [self.view insertSubview:self.page.view atIndex:0];
    self.pvSync.hidden = YES;
    self.pvSync.progress = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncProgress:) name:BTPeerManagerSyncProgressNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressTxLoading:) name:BTAddressTxLoadingNotification object:nil];
}

- (void)initTabs {
    self.tabButtons = [[NSArray alloc] initWithObjects:self.tabMarket, self.tabAddress, self.tabSetting, nil];
    self.tabMarket.imageUnselected = [UIImage imageNamed:@"tab_market"];
    self.tabMarket.imageSelected = [UIImage imageNamed:@"tab_market_checked"];
    self.tabAddress.imageUnselected = [UIImage imageNamed:@"tab_main"];
    self.tabAddress.imageSelected = [UIImage imageNamed:@"tab_main_checked"];
    self.tabAddress.selected = YES;
    self.tabSetting.imageUnselected = [UIImage imageNamed:@"tab_option"];
    self.tabSetting.imageSelected = [UIImage imageNamed:@"tab_option_checked"];
    for (int i = 0; i < self.tabButtons.count; i++) {
        TabButton *tab = [self.tabButtons objectAtIndex:i];
        tab.index = i;
        tab.delegate = self;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isInit = YES;
    cnt = 4;
    self.dict = [[NSMutableDictionary alloc] init];
    [self.view bringSubviewToFront:self.addAddressBtn];
    [self initApp];
}

#pragma mark - TabBar delegate

- (void)setTabBarSelectedItem:(int)index {
    for (int i = 0; i < self.tabButtons.count; i++) {
        TabButton *tabButton = (TabButton *) [self.tabButtons objectAtIndex:i];
        if (i == index) {
            tabButton.selected = YES;
        } else {
            tabButton.selected = NO;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (![[BTPeerManager instance] connected]) {
        [[PeerUtil instance] startPeer];
    }
    [self.tabAddress balanceChanged];
}

- (void)pageIndexChanged:(int)index {
    for (int i = 0; i < self.tabButtons.count; i++) {
        TabButton *tab = [self.tabButtons objectAtIndex:i];
        tab.selected = i == index;
    }
}

- (void)tabButtonPressed:(int)index {
    if (index != self.page.index) {
        [self.page setIndex:index animated:YES];
    }
}

- (void)viewDidUnload {
    [self setTabMarket:nil];
    [self setTabAddress:nil];
    [self setTabSetting:nil];

    self.tabButtons = nil;
    [self.page removeFromParentViewController];
    self.page = nil;
    [super viewDidUnload];
}

- (IBAction)addPressed:(id)sender {
    if ([BTAddressManager instance].privKeyAddresses.count >= PRIVATE_KEY_OF_HOT_COUNT_LIMIT && [BTAddressManager instance].watchOnlyAddresses.count >= WATCH_ONLY_COUNT_LIMIT) {
        [self showBannerWithMessage:NSLocalizedString(@"reach_address_count_limit", nil) belowView:self.vTabe];
        return;
    }
    IOS7ContainerViewController *container = [[IOS7ContainerViewController alloc] init];
    container.controller = [self.storyboard instantiateViewControllerWithIdentifier:@"HotAddressAdd"];
    container.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:container animated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [DialogFirstRunWarning show:self.view.window];
    });
}

- (void)syncProgress:(NSNotification *)notification {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayHidePvSync) object:nil];
    if (notification && notification.object && [notification.object isKindOfClass:[NSNumber class]]) {
        double progress = ((NSNumber *) notification.object).doubleValue;
        BTPeerManager *peerManager = [BTPeerManager instance];
        if (progress >= 0 && progress <= 1) {
            self.pvSync.hidden = NO;
            progress = MAX(0.2, progress);
            [UIView animateWithDuration:0.5 animations:^{
                [self.pvSync setProgress:progress animated:YES];
            }];
            int32_t unsyncBlockNumber = peerManager.downloadPeer.versionLastBlock - peerManager.lastBlockHeight;
            if (unsyncBlockNumber > 0) {
                [self showAlert:[NSString stringWithFormat:NSLocalizedString(@"tip_sync_block_height", nil), @(unsyncBlockNumber)]];
            } else {
                [self showAlert:NULL];
            }
        } else {
            [self performSelector:@selector(delayHidePvSync) withObject:nil afterDelay:0.5];
            [self showAlert:NULL];
        }
    } else {
        self.pvSync.hidden = YES;
        [self showAlert:NULL];
    }
}

- (void)addressTxLoading:(NSNotification *)notification {
    NSString *address;
    if (notification && notification.object && [notification.object isKindOfClass:[NSString class]]) {
        address = (NSString *) notification.object;
    } else {
        address = NULL;
    }
    if ([NSThread isMainThread]) {
        [self showAddressTxLoading:address];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAddressTxLoading:address];
        });
    }
}

- (void)showAddressTxLoading:(NSString *)address {
    if (address) {
        if ([address isEqual:@"ERROR"]) {
            DialogAlert *dialogAlert = [[DialogAlert alloc] initWithConfirmMessage:NSLocalizedString(@"Reload transactions data failed , Please retry again.", nil) confirmStr:NSLocalizedString(@"Retry", nil) confirm:^{
                [[PeerUtil instance] startPeer];
            }];
            dialogAlert.touchOutSideToDismiss = false;
            [dialogAlert showInWindow:self.view.window];
        } else {
            [self showAlert:[NSString stringWithFormat:NSLocalizedString(@"tip_sync_address_tx", nil), address]];
        }
    } else{
        [self showAlert:NULL];
    }
}

- (void)showAlert:(NSString *)alert {
    NSString *tAlert = alert;
    if (tAlert == NULL) {
        BOOL isNoNetwork = ![NetworkUtil isEnableWIFI] && ![NetworkUtil isEnable3G];
        if (isNoNetwork) {
            tAlert = NSLocalizedString(@"tip_network_error", nil);
            [[Reachability reachabilityForInternetConnection] startNotifier];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChange) name:kReachabilityChangedNotification object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
        }
    }
    BOOL isHiddenAlert = tAlert == NULL;
    if (!isHiddenAlert) {
        self.lblAlert.text = tAlert;
        CGSize lblSize = [alert boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 48, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.lblAlert.font, NSParagraphStyleAttributeName : [NSParagraphStyle defaultParagraphStyle]} context:nil].size;
        self.vAlert.frame = CGRectMake(0, _vAlert.frame.origin.y, _vAlert.frame.size.width, MAX(lblSize.height + 24, 36));
    }
    CGFloat pageY = isHiddenAlert ? TabBarHeight : TabBarHeight + _vAlert.frame.size.height;
    self.page.view.frame = CGRectMake(0, pageY, self.view.frame.size.width, self.view.frame.size.height - pageY);
    [self.aivAlert setHidden:isHiddenAlert];
    [self.lblAlert setHidden:isHiddenAlert];
    [self.vAlert setHidden:isHiddenAlert];
}

- (void)reachabilityChange {
    [self showAlert:NULL];
}

- (void)delayHidePvSync {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayHidePvSync) object:nil];
    self.pvSync.hidden = YES;
    self.pvSync.progress = 0;
}

- (void)initApp {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UploadAndDowloadFileFactory *uploadAndDowload = [[UploadAndDowloadFileFactory alloc] init];
        [uploadAndDowload uploadAvatar:nil andErrorCallBack:nil];
        [uploadAndDowload dowloadAvatar:nil andErrorCallBack:nil];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
