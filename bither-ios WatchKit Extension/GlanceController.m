//
//  GlanceController.m
//  bither-ios WatchKit Extension
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
//  Created by songchenwen on 2015/2/25.
//

#import "GlanceController.h"
#import "TotalBalance.h"
#import "WatchUnitUtil.h"
#import "WatchMarket.h"
#import "WatchTrendingGraphicDrawer.h"
#import "WatchApi.h"


@interface GlanceController(){
    WatchTrendingGraphicDrawer* tDrawer;
    WatchMarket* market;
    NSTimer *autoRefresh;
}
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lblBalance;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *gMarket;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lblMarketName;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lblPrice;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *ivTrending;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *ivSymbol;

@end


@implementation GlanceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self.lblBalance setText:[WatchUnitUtil stringForAmount:[[TotalBalance alloc] init].total]];
    [self.ivSymbol setImageNamed:[WatchUnitUtil imageNameOfSymbol]];
    market = [WatchMarket getDefaultMarket];
    [self showMarket];
    tDrawer = [[WatchTrendingGraphicDrawer alloc]init];
    [tDrawer setEmptyImage:self.ivTrending];
}

- (void)showMarket{
    [self.gMarket setBackgroundColor:market.color];
    [self.lblMarketName setText:market.getName];
    [self.lblPrice setText:[NSString stringWithFormat:@"%@ %.2f", [WatchMarket getCurrencySymbol:[[GroupUserDefaultUtil instance] defaultCurrency]], market.ticker.getDefaultExchangePrice]];
}

- (void)willActivate {
    [super willActivate];
    autoRefresh = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(autoRefresh) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:autoRefresh forMode:NSDefaultRunLoopMode];
    [autoRefresh fire];
}

- (void)autoRefresh{
    [self refreshTrending];
    [self refreshTicker];
}

-(void)refreshTrending{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshTrending) object:nil];
    [WatchTrendingGraphicData getTrendingGraphicData:market.marketType callback:^(WatchTrendingGraphicData *data) {
        [self.ivTrending setImage:[tDrawer animatingImageFromData:[WatchTrendingGraphicData getEmptyData] toData:data]];
        [self.ivTrending startAnimatingWithImagesInRange:NSMakeRange(0, kTrendingAnimationFrameCount) duration:kTrendingAnimationDuration repeatCount:1];
    } andErrorCallback:^(NSError *error) {
        [self performSelector:@selector(refreshTrending) withObject:nil afterDelay:5];
    }];
}

-(void)refreshTicker{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshTicker) object:nil];
    [[WatchApi instance]getExchangeTicker:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showMarket];
        });
    } andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(refreshTicker) withObject:nil afterDelay:2];
        });
    }];
}

- (void)didDeactivate {
    [autoRefresh invalidate];
    autoRefresh = nil;
    [super didDeactivate];
}

@end



