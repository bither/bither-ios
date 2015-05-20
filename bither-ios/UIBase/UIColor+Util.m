//
//  UIColor+Util.m
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

#import "UIColor+Util.h"

@implementation UIColor (Util)

+ (UIColor *)parseColor:(int)colorString {
    return [UIColor r:((colorString & 0xFF0000) >> 16) g:((colorString & 0xFF00) >> 8) b:(colorString & 0xFF)];
}

+ (UIColor *)r:(int)r g:(int)g b:(int)b {
    return [UIColor r:r g:g b:b a:255];
}

+ (UIColor *)r:(int)r g:(int)g b:(int)b a:(int)a {
    return [UIColor colorWithRed:[UIColor comp:r] green:[UIColor comp:g] blue:[UIColor comp:b] alpha:[UIColor comp:a]];
}

+ (float)comp:(int)i {
    return (float) i / 255.0f;
}

+ (UIImage *)gradientFromColor:(UIColor *)c1 toColor:(UIColor *)c2 withHeight:(int)height {
    CGSize size = CGSizeMake(1, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();

    NSArray *colors = [NSArray arrayWithObjects:(id) c1.CGColor, (id) c2.CGColor, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorspace, (CFArrayRef) colors, NULL);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, size.height), 0);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    UIGraphicsEndImageContext();
    return image;
}
@end
