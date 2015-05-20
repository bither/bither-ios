//  MarketViewController.m
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

#import "MarketViewController.h"
#import "MarketListCell.h"
#import "MarketUtil.h"
#import "NSString+Size.h"
#import "BitherTime.h"
#import "TrendingGraphicView.h"
#import "BackgroundTransitionView.h"

#define DEFAULT_DISPALY_PRICE @"--"

@interface MarketViewController () <UITableViewDataSource, UITableViewDelegate> {
    BOOL _isCheckAnimation;
    BOOL _isAppear;
}
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(weak, nonatomic) IBOutlet UILabel *lbMarketName;
@property(weak, nonatomic) IBOutlet UILabel *lbNew;
@property(weak, nonatomic) IBOutlet UILabel *lbHigh;
@property(weak, nonatomic) IBOutlet UILabel *lbLow;
@property(weak, nonatomic) IBOutlet UILabel *lbAmount;
@property(weak, nonatomic) IBOutlet UILabel *lbBuy;
@property(weak, nonatomic) IBOutlet UILabel *lbSell;
@property(weak, nonatomic) IBOutlet BackgroundTransitionView *matketDetailView;
@property(weak, nonatomic) IBOutlet UILabel *lbSymbol;
@property(weak, nonatomic) IBOutlet UIView *vAmountContainer;
@property(weak, nonatomic) IBOutlet UIView *vLeftContainer;
@property(weak, nonatomic) IBOutlet UIView *vRightContainer;
@property(weak, nonatomic) IBOutlet UILabel *lbl24H;
@property(weak, nonatomic) IBOutlet UIImageView *ivProgress;
@property(weak, nonatomic) IBOutlet TrendingGraphicView *vTrending;


@property(weak, nonatomic) Market *market;

@end

@implementation MarketViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.market = [MarketUtil getDefaultMarket];
    [self reload];
    [self.vTrending setData:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReload) name:BitherMarketUpdateNotification object:nil];
    _isCheckAnimation = NO;

}

- (void)viewWillAppear:(BOOL)animated {
    if (self.market.ticker == nil) {
        [[BitherTime instance] resume];
    }
    [self reload];
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _isAppear = YES;
    if (_isCheckAnimation) {
        [self moveProgress];
    }
    self.vTrending.marketType = self.market.marketType;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _isAppear = NO;
}

- (void)notificationReload {
    [self reload];
    _isCheckAnimation = YES;
    if (_isAppear) {
        [self moveProgress];
    }
}

- (void)reload {
    [self.tableView reloadData];
    self.lbMarketName.text = [self.market getName];
    if (_isAppear) {
        self.matketDetailView.backgroundColor = [GroupUtil getMarketColor:self.market.marketType];
    } else {
        [self.matketDetailView setBackgroundColorWithoutTransition:[GroupUtil getMarketColor:self.market.marketType]];
    }
    if (self.market.ticker) {
        Ticker *ticker = self.market.ticker;
        self.lbSymbol.text = [BitherSetting getCurrencySymbol:[[UserDefaultsUtil instance] getDefaultCurrency]];
        self.lbNew.text = [StringUtil formatDouble:[ticker getDefaultExchangePrice]];
        self.lbHigh.text = [StringUtil formatPrice:[ticker getDefaultExchangeHigh]];
        self.lbLow.text = [StringUtil formatPrice:[ticker getDefaultExchangeLow]];
        self.lbAmount.text = [StringUtil formatDouble:ticker.amount];
        self.lbBuy.text = [NSString stringWithFormat:NSLocalizedString(@"Buy: %@", nil), [StringUtil formatPrice:[ticker getDefaultExchangeBuy]]];
        self.lbSell.text = [NSString stringWithFormat:NSLocalizedString(@"Sell: %@", nil), [StringUtil formatPrice:[ticker getDefaultExchangeSell]]];
    } else {
        self.lbSymbol.text = @"";
        self.lbNew.text = DEFAULT_DISPALY_PRICE;
        self.lbHigh.text = DEFAULT_DISPALY_PRICE;
        self.lbLow.text = DEFAULT_DISPALY_PRICE;
        self.lbAmount.text = DEFAULT_DISPALY_PRICE;
        self.lbBuy.text = DEFAULT_DISPALY_PRICE;
        self.lbSell.text = DEFAULT_DISPALY_PRICE;
    }
    [self positionViews];
    if (_isAppear) {
        self.vTrending.marketType = self.market.marketType;
    }

}

- (void)positionViews {
    CGRect frame = self.lbNew.frame;
    CGFloat width = [self.lbNew.text sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:self.lbNew.font].width;
    frame.origin.x = frame.origin.x - (width - frame.size.width);
    frame.size.width = width;
    self.lbNew.frame = frame;
    frame = self.lbSymbol.frame;
    frame.origin.x = self.lbNew.frame.origin.x - frame.size.width - 5;
    self.lbSymbol.frame = frame;

    frame = self.vLeftContainer.frame;
    frame.size.width = MAX([self.lbHigh.text sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:self.lbHigh.font].width, [self.lbLow.text sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:self.lbLow.font].width) + self.lbl24H.frame.size.width;
    self.vLeftContainer.frame = frame;

    frame = self.vAmountContainer.frame;
    width = [self.lbAmount.text sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:self.lbAmount.font].width + self.lbAmount.frame.origin.x;
    frame.origin.x = frame.origin.x - (width - frame.size.width);
    frame.size.width = width;
    self.vAmountContainer.frame = frame;

    frame = self.vRightContainer.frame;
    width = MAX(MAX([self.lbBuy.text sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:self.lbBuy.font].width, [self.lbSell.text sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:self.lbSell.font].width), self.vAmountContainer.frame.size.width);
    frame.origin.x = frame.origin.x - (width - frame.size.width);
    frame.size.width = width;
    self.vRightContainer.frame = frame;

    self.vTrending.frame = CGRectMake(CGRectGetMaxX(self.vLeftContainer.frame) + 8, self.vLeftContainer.frame.origin.y, self.vRightContainer.frame.origin.x - CGRectGetMaxX(self.vLeftContainer.frame) - 16, self.vLeftContainer.frame.size.height);
}

- (void)moveProgress {
    self.ivProgress.hidden = NO;
    [UIView animateWithDuration:1.2f animations:^{
        self.ivProgress.frame = CGRectMake(300 - 17, 0, self.ivProgress.frame.size.width, self.ivProgress.frame.size.height);
    }                completion:^(BOOL finished) {
        self.ivProgress.hidden = YES;
        _isCheckAnimation = NO;
        self.ivProgress.frame = CGRectMake(0, 0, self.ivProgress.frame.size.width, self.ivProgress.frame.size.height);
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BitherMarketUpdateNotification object:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [MarketUtil getMarkets].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MarketListCell *cell = (MarketListCell *) [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell setMarket:[[MarketUtil getMarkets] objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.market = [[MarketUtil getMarkets] objectAtIndex:indexPath.row];
    [self reload];
}

@end
