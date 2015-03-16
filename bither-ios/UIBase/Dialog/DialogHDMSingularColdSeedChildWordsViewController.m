//
//  DialogHDMSingularColdSeedChildWordsViewController.m
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

#import "DialogHDMSingularColdSeedChildWordsViewController.h"

#define kContainerOffset (10)

@interface DialogHDMSingularColdSeedChildWordsViewController ()
@property(weak, nonatomic) IBOutlet UIView *vContainer;
@property(weak, nonatomic) IBOutlet UILabel *lbl;
@end

@implementation DialogHDMSingularColdSeedChildWordsViewController
- (void)setWords:(NSArray *)words andQr:(NSString *)qr {
    [self loadView];
    NSString *str = CFBridgingRelease(CFStringCreateByCombiningStrings(NULL, (__bridge CFArrayRef) words, CFSTR("-")));
    self.lbl.text = str;
    CGSize size = [self.lbl sizeThatFits:CGSizeMake(self.view.frame.size.width - kContainerOffset * 4, CGFLOAT_MAX)];
    size.height = ceil(size.height) + kContainerOffset * 2;
    size.width = self.view.frame.size.width - kContainerOffset * 2;
    self.vContainer.frame = CGRectMake(kContainerOffset, (self.view.frame.size.height - size.height) / 2, size.width, size.height);
}
@end