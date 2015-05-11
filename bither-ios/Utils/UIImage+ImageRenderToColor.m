//
//  UIImage+ImageRenderToColor.m
//  bither-ios
//
//  Created by noname on 14-7-30.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "UIImage+ImageRenderToColor.h"
#import "UIImage+ImageWithColor.h"

@implementation UIImage (ImageRenderToColor)

- (UIImage *)renderToColor:(UIColor *)color {
    CIImage *bg = [CIImage imageWithCGImage:[UIImage imageWithColor:[UIColor colorWithWhite:0 alpha:0] size:self.size].CGImage];
    CIImage *fg = [CIImage imageWithCGImage:[UIImage imageWithColor:color size:self.size].CGImage];
    CIFilter *alphaBlendFilter = [CIFilter filterWithName:@"CIBlendWithAlphaMask" keysAndValues:@"inputImage", fg, @"inputBackgroundImage", bg, @"inputMaskImage", [CIImage imageWithCGImage:self.CGImage], nil];
    return [UIImage imageWithCIImage:alphaBlendFilter.outputImage];
}

@end
