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


@interface GlanceController(){
    WatchTrendingGraphicDrawer* tDrawer;
    WatchMarket* market;
}
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lblBalance;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *gMarket;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lblMarketName;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lblPrice;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *ivTrending;

@end


@implementation GlanceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self.lblBalance setText:[WatchUnitUtil stringForAmount:[[TotalBalance alloc] init].total]];
    market = [WatchMarket getDefaultMarket];
    [self.gMarket setBackgroundColor:market.color];
    [self.lblMarketName setText:market.getName];
    [self.lblPrice setText:[NSString stringWithFormat:@"%@ %.2f", [WatchMarket getCurrencySymbol:[GroupFileUtil defaultCurrency]], market.ticker.getDefaultExchangePrice]];
    tDrawer = [[WatchTrendingGraphicDrawer alloc]initWithSize:CGSizeMake(200, 100)];
    [self.ivTrending setImage:[tDrawer imageForData:[WatchTrendingGraphicData getEmptyData]]];
}

- (void)willActivate {
    [super willActivate];
    [self refreshTrending];
}

-(void)refreshTrending{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshTrending) object:nil];
    [WatchTrendingGraphicData getTrendingGraphicData:market.marketType callback:^(WatchTrendingGraphicData *data) {
        [self.ivTrending setImage:[tDrawer imageForData:data]];
    } andErrorCallback:^(NSError *error) {
        [self performSelector:@selector(refreshTrending) withObject:nil afterDelay:5];
    }];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



