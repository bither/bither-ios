//
//  DialogHDMSingularModeInfo.m
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

#import "DialogHDMSingularModeInfo.h"


@implementation DialogHDMSingularModeInfo

- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 60;
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 0)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font = [UIFont systemFontOfSize:14];
        lbl.numberOfLines = 0;
        lbl.text = NSLocalizedString(@"hdm_singular_mode_info", nil);
        CGSize size = [lbl sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
        size.width = ceil(size.width);
        size.height = ceil(size.height);
        lbl.frame = CGRectMake(0, 0, size.width, size.height);
        self.frame = CGRectMake(0, 0, size.width, size.height);
        [self addSubview:lbl];
    }
    return self;
}
@end