//
//  TrendingGraphicView.h
//  bither-ios
//
//  Created by noname on 14-9-1.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Market.h"
#import "TrendingGraphicData.h"

@interface TrendingGraphicView : UIView
@property MarketType marketType;
-(void)setData:(TrendingGraphicData*)data;
@end
