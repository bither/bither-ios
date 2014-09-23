//
//  DialogBlackQrCode.m
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

#import "DialogBlackQrCode.h"
#import "UIImage+ImageWithColor.h"
#import "QRCodeThemeUtil.h"

@implementation DialogBlackQrCode

-(instancetype)initWithContent:(NSString*)content{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
    if(self){
        self.backgroundImage = [UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0]];
        self.bgInsets = UIEdgeInsetsMake(10, 0, 10, 0);
        self.dimAmount = 0.8f;
        UIImageView* iv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)];
        iv.autoresizingMask = UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleWidth;
        iv.image = [QRCodeThemeUtil qrCodeOfContent:content andSize:iv.frame.size.width withTheme:[QRCodeTheme black]];
        [self addSubview:iv];
    }
    return self;
}
@end
