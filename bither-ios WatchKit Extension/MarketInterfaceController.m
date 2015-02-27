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
#import "WatchUnitUtil.h"

@interface MarketInterfaceController (){
    WatchMarket* market;
    WatchTrendingGraphicDrawer* tDrawer;
    WatchTrendingGraphicData *trending;
}
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *gContainer;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lblName;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lblPrice;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *ivTrending;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lblHigh;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lblLow;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lblSell;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lblBuy;

@end

@implementation MarketInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    market = [WatchMarket getDefaultMarket];
    tDrawer = [[WatchTrendingGraphicDrawer alloc]init];
    [self.gContainer setBackgroundColor:market.color];
    [self.lblName setText:market.getName];
    [self.lblPrice setText:[self stringForMoney:market.ticker.getDefaultExchangePrice]];
    [self.lblHigh setText:[self stringForMoney:market.ticker.getDefaultExchangeHigh]];
    [self.lblLow setText:[self stringForMoney:market.ticker.getDefaultExchangeLow]];
    [self.lblBuy setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"buy", nil), [self stringForMoney:market.ticker.getDefaultExchangeBuy]]];
    [self.lblSell setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"sell", nil), [self stringForMoney:market.ticker.getDefaultExchangeSell]]];
    trending = [WatchTrendingGraphicData getEmptyData];
    [tDrawer setEmptyImage:self.ivTrending];
}

- (void)willActivate {
    [super willActivate];
    [self refreshTrending];
}

-(void)refreshTrending{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshTrending) object:nil];
    [WatchTrendingGraphicData getTrendingGraphicData:market.marketType callback:^(WatchTrendingGraphicData *data) {
        [self.ivTrending setImage:[tDrawer animatingImageFromData:trending toData:data]];
        [self.ivTrending startAnimatingWithImagesInRange:NSMakeRange(0, kTrendingAnimationFrameCount) duration:kTrendingAnimationDuration repeatCount:1];
        trending = data;
    } andErrorCallback:^(NSError *error) {
        [self performSelector:@selector(refreshTrending) withObject:nil afterDelay:5];
    }];
}

-(NSString*)stringForMoney:(double)money{
    return [NSString stringWithFormat:@"%@ %.2f", [WatchMarket getCurrencySymbol:[GroupFileUtil defaultCurrency]], money];
}

- (void)didDeactivate {
    [super didDeactivate];
}

@end



