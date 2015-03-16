//
//  DialogHDMSingularColdSeedChildQrViewController.m
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
//
//  Created by songchenwen on 2015/3/16.
//

#import "DialogHDMSingularColdSeedChildQrViewController.h"
#import "QRCodeThemeUtil.h"

@interface DialogHDMSingularColdSeedChildQrViewController ()
@property(weak, nonatomic) IBOutlet UIImageView *iv;
@end

@implementation DialogHDMSingularColdSeedChildQrViewController

- (void)setWords:(NSArray *)words andQr:(NSString *)qr {
    [self loadView];
    UIImage *image = [QRCodeThemeUtil qrCodeOfContent:qr andSize:self.view.frame.size.width margin:self.view.frame.size.width * 0.02 withTheme:[QRCodeTheme black]];
    self.iv.image = image;
}
@end