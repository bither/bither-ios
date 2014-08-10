//
//  PieChartView.h
//  bither-ios
//
//  Created by noname on 14-8-4.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PieChartView : UIView
@property NSArray* amounts;
@property CGFloat startAngle;
@property CGFloat totalAngle;
-(UIColor*)colorForIndex:(NSInteger)index;
@end
