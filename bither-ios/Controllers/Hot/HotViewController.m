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


@interface HotViewController ()
@property(strong, nonatomic) NSArray *tabButtons;
@property(strong, nonatomic) IBOutlet TabButton *tabMarket;
@property(strong, nonatomic) IBOutlet HotAddressTabButton *tabAddress;
@property(strong, nonatomic) IBOutlet TabButton *tabSetting;
@property(weak, nonatomic) IBOutlet UIView *vTabe;
@property(weak, nonatomic) IBOutlet UIProgressView *pvSync;
@property(strong, nonatomic) PiPageViewController *page;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated; {
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
    } else {
        UIViewController *controller = [self.page viewControllerAtIndex:index];
        if (controller) {
            // [controller refresh];
        }
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fromPushNoification {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers && viewControllers.count > 0) {
        if (self != [viewControllers objectAtIndex:viewControllers.count - 1]) {
            [self.navigationController popToViewController:self animated:NO];
        }
    }
    int index = 3;
    if (index != self.page.index) {
        self.page.pageEnabled = NO;
        [self performSelector:@selector(toMeViewController) withObject:self afterDelay:0.8];
    } else {
        UIViewController *controller = [self.page viewControllerAtIndex:index];
        if ([controller respondsToSelector:@selector(refresh)]) {
            // [controller refresh];
        }
    }
}

- (void)toMeViewController {
    self.page.pageEnabled = YES;
    [self.page setIndex:3 animated:YES];
}

- (IBAction)addPressed:(id)sender {
    if ([BTAddressManager instance].privKeyAddresses.count >= PRIVATE_KEY_OF_HOT_COUNT_LIMIT && [BTAddressManager instance].watchOnlyAddresses.count >= WATCH_ONLY_COUNT_LIMIT) {
        [self showBannerWithMessage:NSLocalizedString(@"reach_address_count_limit", nil) belowView:self.vTabe];
        return;
    }
    IOS7ContainerViewController *container = [[IOS7ContainerViewController alloc] init];
    container.controller = [self.storyboard instantiateViewControllerWithIdentifier:@"HotAddressAdd"];
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
        if (progress >= 0 && progress <= 1) {
            self.pvSync.hidden = NO;
            progress = MAX(0.2, progress);
            [UIView animateWithDuration:0.5 animations:^{
                [self.pvSync setProgress:progress animated:YES];
            }];
        }
        if (progress < 0 || progress >= 1) {
            [self performSelector:@selector(delayHidePvSync) withObject:nil afterDelay:0.5];
        }
    } else {
        self.pvSync.hidden = YES;
    }
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

@end
