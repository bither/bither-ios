//
//  AdView.h
//  bither-ios
//
//  Created by 韩珍 on 2016/10/25.
//  Copyright © 2016年 Bither. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Done)();

@interface AdView : UIView

@property (nonatomic, copy) Done done;
- (instancetype)initWithFrame:(CGRect)frame adDic:(NSDictionary *)adDic;

@end
