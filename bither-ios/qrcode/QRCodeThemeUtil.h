//
//  QrUtil.h
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

#import <Foundation/Foundation.h>
@import UIKit;

@interface QRCodeTheme : NSObject
- (instancetype)initWithFg:(UIColor *)fg bg:(UIColor *)bg;

@property UIColor *fg;
@property UIColor *bg;

+ (QRCodeTheme *)yellow;

+ (QRCodeTheme *)green;

+ (QRCodeTheme *)blue;

+ (QRCodeTheme *)red;

+ (QRCodeTheme *)purple;

+ (QRCodeTheme *)black;

+ (NSArray *)themes;

+ (NSInteger)indexOfTheme:(QRCodeTheme *)theme;
@end

@interface QRCodeThemeUtil : NSObject

+ (UIImage *)qrCodeOfContent:(NSString *)content andSize:(CGFloat)size withTheme:(QRCodeTheme *)theme;

+ (UIImage *)qrCodeOfContent:(NSString *)content andSize:(CGFloat)size margin:(CGFloat)margin withTheme:(QRCodeTheme *)theme;

@end

