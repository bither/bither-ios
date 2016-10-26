//
//  UIView+Extension.m
//  bither-ios
//
//  Created by 韩珍 on 2016/10/26.
//  Copyright © 2016年 Bither. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

- (void)cornerRadius:(CGFloat)radius
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius  = radius;
}

- (void)cornerRadius:(CGFloat)radius borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius  = radius;
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = borderWidth;
}

@end
