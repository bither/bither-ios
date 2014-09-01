//
//  TrendingGraphicData.m
//  bither-ios
//
//  Created by noname on 14-8-13.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "TrendingGraphicData.h"
#import "ExchangeUtil.h"
#import "BitherApi.h"

static TrendingGraphicData * _emptyData;
static NSMutableDictionary * tgds;
@interface TrendingGraphicData(){
    NSTimeInterval _createTime;
   
}

@end

@implementation TrendingGraphicData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _createTime=-1;
    }
    return self;
}

-(BOOL)isExpired{
    return _createTime==-1||_createTime+EXPORED_TIME<[[NSDate new] timeIntervalSince1970];
}
-(void)setCreateTime:(NSTimeInterval) time{
    _createTime=time;

}
-(void)caculateRate{
    self.rates=[NSMutableArray new];
    double interval=self.high-self.low;
    for(int i=0;i<self.prices.count;i++){
        double price=[[self.prices objectAtIndex:i] doubleValue];
        [self.rates addObject:@(MAX(0, price-self.low)/interval)];
    }
    
}

+(TrendingGraphicData *)format:(NSArray *)array{
    TrendingGraphicData *tgd=[[TrendingGraphicData alloc] init];
    double high=0;
    double low=UINT32_MAX;
    double rate=[ExchangeUtil getExchangeRate];
    NSMutableArray * prices=[NSMutableArray new];
    for (int i=0; i<array.count; i++) {
        double price=[[array objectAtIndex:i] doubleValue]/100*rate;
        [prices addObject:@(price)];
        if (high<price) {
            high=price;
        }
        if (low>price) {
            low=price;
        }
        
    }
    tgd.prices=prices;
    tgd.high=high;
    tgd.low=low;
    [tgd caculateRate];
    [tgd setCreateTime:[[NSDate new] timeIntervalSince1970]];
    return tgd;
}

+(instancetype)getEmptyData{
    
    if (_emptyData==nil) {
        _emptyData=[[TrendingGraphicData alloc] init];
        NSMutableArray * prices=[NSMutableArray new];
        for (int i=0; i<TRENDING_GRAPIC_COUNT; i++) {
            [prices addObject:@(0.5)];
        }
        _emptyData.high=1;
        _emptyData.low=0;
        _emptyData.prices=prices;
        [_emptyData caculateRate];
    }

    return _emptyData;
}

+(void)getTrendingGraphicData:(MarketType ) marketType callback:(IdResponseBlock)callback andErrorCallback:(ErrorBlock)errorCallback{
    if (tgds==nil) {
        tgds=[NSMutableDictionary new];
    }
    
    if (tgds.count>marketType) {
        TrendingGraphicData * tgd=[tgds objectForKey:@(marketType)];
        if (tgd&&![tgd isExpired]) {
            if (callback) {
                callback(tgd);
                return;
            }
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
        [[BitherApi instance] getExchangeTrend:marketType callback:^(NSArray *array) {
            TrendingGraphicData * tgd=[TrendingGraphicData format:array];
            [tgds setObject:tgd forKey:@(marketType)];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(tgd);
                }
            });
            
        } andErrorCallBack:^(MKNetworkOperation *errorOp, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (errorCallback) {
                    errorCallback(error);
                }
            });
        }];
        
    
    });

}

@end

























