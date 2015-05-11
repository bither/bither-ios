//
//  MarketInterfaceController.m
//  ;
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
//
//  Created by songchenwen on 2015/2/27.
//

#import "MarketInterfaceController.h"
#import "WatchMarket.h"
#import "WatchTrendingGraphicDrawer.h"
#import "WatchMarketBgDrawer.h"
#import "WatchUnitUtil.h"
#import "WatchApi.h"
#import "WatchPageConfiguration.h"

@interface MarketInterfaceController () {
    WatchMarket *market;
    WatchTrendingGraphicDrawer *tDrawer;
    WatchTrendingGraphicData *trending;
    NSTimer *autoRefresh;
}
@property(weak, nonatomic) IBOutlet WKInterfaceGroup *gContainer;
@property(weak, nonatomic) IBOutlet WKInterfaceButton *btnName;
@property(weak, nonatomic) IBOutlet WKInterfaceLabel *lblPrice;
@property(weak, nonatomic) IBOutlet WKInterfaceImage *ivTrending;
@property(weak, nonatomic) IBOutlet WKInterfaceLabel *lblHigh;
@property(weak, nonatomic) IBOutlet WKInterfaceLabel *lblLow;

@end

@implementation MarketInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    market = [WatchMarket getDefaultMarket];
    tDrawer = [[WatchTrendingGraphicDrawer alloc] init];
    trending = [WatchTrendingGraphicData getEmptyData];
    [tDrawer setEmptyImage:self.ivTrending];
    [self showMarket];
    [self showMarketBgFrom:nil];
}

- (IBAction)namePressed {
    UIColor *fromColor = market.color;
    NSArray *markets = [WatchMarket getMarkets];
    NSUInteger index = [markets indexOfObject:market];
    if (index < markets.count - 1) {
        index++;
    } else {
        index = 0;
    }
    market = [markets objectAtIndex:index];
    [self showMarket];
    [self showMarketBgFrom:fromColor];
    [self refreshTrending];
    [self refreshTicker];
}

- (void)showMarket {
    [self.btnName setTitle:market.getName];
    [self.lblPrice setText:[self stringForMoney:market.ticker.getDefaultExchangePrice]];
    [self.lblHigh setText:[self stringForMoney:market.ticker.getDefaultExchangeHigh]];
    [self.lblLow setText:[self stringForMoney:market.ticker.getDefaultExchangeLow]];
}

- (void)showMarketBgFrom:(UIColor *)from {
    if (from) {
        NSArray *images = [[WatchMarketBgDrawer alloc] initWithFrom:from to:market.color].images;
        [self.gContainer setBackgroundImage:[UIImage animatedImageWithImages:images duration:kWatchMarketBgAnimationDuration]];
        [self.gContainer startAnimatingWithImagesInRange:NSMakeRange(0, images.count) duration:kWatchMarketBgAnimationDuration repeatCount:1];
    } else {
        [self.gContainer setBackgroundColor:market.color];
    }
}

- (void)willActivate {
    NSArray *pages = @[@"Market", @"Balance"];
    NSString *payment = [GroupUserDefaultUtil instance].paymentAddress;
    if (payment && payment.length > 0) {
        pages = @[@"Market", @"Balance", @"Payment"];
    }
    if ([WatchPageConfiguration configurePagesFor:pages]) {
        return;
    }
    [super willActivate];
    autoRefresh = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(autoRefresh) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:autoRefresh forMode:NSDefaultRunLoopMode];
    [autoRefresh fire];
}

- (void)autoRefresh {
    [self refreshTrending];
    [self refreshTicker];
}

- (void)refreshTicker {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshTicker) object:nil];
    [[WatchApi instance] getExchangeTicker:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showMarket];
        });
    }                     andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(refreshTicker) withObject:nil afterDelay:2];
        });
    }];
}

- (void)refreshTrending {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshTrending) object:nil];
    [WatchTrendingGraphicData getTrendingGraphicData:market.marketType callback:^(WatchTrendingGraphicData *data) {
        [self.ivTrending setImage:[tDrawer animatingImageFromData:trending toData:data]];
        [self.ivTrending startAnimatingWithImagesInRange:NSMakeRange(0, kTrendingAnimationFrameCount) duration:kTrendingAnimationDuration repeatCount:1];
        trending = data;
    }                               andErrorCallback:^(NSError *error) {
        [self performSelector:@selector(refreshTrending) withObject:nil afterDelay:5];
    }];
}

- (NSString *)stringForMoney:(double)money {
    return [NSString stringWithFormat:@"%@ %.2f", [WatchMarket getCurrencySymbol:[[GroupUserDefaultUtil instance] defaultCurrency]], money];
}

- (void)didDeactivate {
    [autoRefresh invalidate];
    autoRefresh = nil;
    [super didDeactivate];
}

@end
