//
//  DialogTxConfirmation.m
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

#import "DialogTxConfirmation.h"

#define kFontSize (15)
#define kMaxWidth (280)

@implementation DialogTxConfirmation

-(instancetype)initWithConfirmationCnt:(int)cnt{
    
    NSString *str;
    if(cnt <= 100){
        str = [NSString stringWithFormat:NSLocalizedString(@"Confirmation: %d", nil), cnt];
    }else{
        str = NSLocalizedString(@"Confirmation: 100+", nil);
    }
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(kMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kFontSize], NSParagraphStyleAttributeName:[NSParagraphStyle defaultParagraphStyle]} context:nil].size;
    size.height = ceilf(size.height);
    size.width = ceilf(size.width);
    
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    if(self){
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        lbl.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        lbl.font = [UIFont systemFontOfSize:kFontSize];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = str;
        [self addSubview:lbl];
    }
    
    return self;
}

@end
