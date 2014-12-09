//
//  RawDataView.m
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

#import "RawDataView.h"
#import "UIColor+Util.h"

@interface RawDataView(){
    NSUInteger restrictedWidth;
    NSUInteger restrictedHeight;
    NSUInteger column;
    NSUInteger row;
    NSMutableArray* data;
}

@end

@implementation RawDataView

-(void)addData:(BOOL)d{
    if(self.filledDataLength < self.dataLength){
        UIView* v = ((UIView*)((UIView*)self.subviews[1]).subviews[self.filledDataLength]).subviews[0];
        [data addObject:@(d)];
        if(d){
            v.backgroundColor = [UIColor parseColor:0xff9329];
        }else{
            v.backgroundColor = [UIColor parseColor:0x3bbf59];
        }
        CGPoint center = CGPointMake(CGRectGetMidX(v.frame), CGRectGetMidY(v.frame));
        v.layer.anchorPoint = CGPointMake(0.5, 0.5);
        v.layer.position = center;
        v.transform = CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:0.5 animations:^{
            v.transform = CGAffineTransformIdentity;
        }];
    }
}

-(NSData*)data{
    return [NSMutableData new];
}

-(void)organizeView{
    if(restrictedWidth <= 0 || restrictedHeight <= 0 || row <= 0 || column <= 0){
        return;
    }
    for(NSInteger i = self.subviews.count - 1; i >= 0; i--){
        [self.subviews[i] removeFromSuperview];
    }
    [self configureSize];
    
    UIImageView *ivBg = [[UIImageView alloc]initWithFrame:CGRectMake(1, 1, self.frame.size.width - 1, self.frame.size.height - 1)];
    ivBg.image = [UIImage imageNamed:@"border_bottom_right"];
    ivBg.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:ivBg];
    
    UIView* vContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width - 1, self.frame.size.height - 1)];
    vContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:vContainer];
    
    CGFloat width = (self.frame.size.width - 1) / column;
    CGFloat height = (self.frame.size.height - 1) / row;
    for(NSInteger y = 0; y < row; y++){
        for(NSInteger x = 0; x < column; x++){
            UIView* v = [[UIView alloc]initWithFrame:CGRectMake(x * width, y * height, width, height)];
            v.backgroundColor = [UIColor clearColor];
            ivBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
            ivBg.image = [UIImage imageNamed:@"border_top_left"];
            ivBg.contentMode = UIViewContentModeScaleToFill;
            UIView* inner = [[UIView alloc]initWithFrame:CGRectMake(1, 1, width - 1, height -1)];
            inner.backgroundColor = [UIColor clearColor];
            [v addSubview:inner];
            [v addSubview:ivBg];
            [vContainer addSubview:v];
        }
    }
}

-(void)configureSize{
    NSUInteger width = restrictedWidth - 1;
    NSUInteger height = restrictedHeight - 1;
    width = width - width % column + 1;
    height = height - height % row + 1;
    self.frame = CGRectMake(self.frame.origin.x - (width - self.frame.size.width)/2, self.frame.origin.y, width, height);
}

-(void)setRestrictedSize:(CGSize)restrictedSize{
    restrictedWidth = floorf(restrictedSize.width);
    restrictedHeight = floorf(restrictedSize.height);
    [self organizeView];
}

-(CGSize)restrictedSize{
    return CGSizeMake(restrictedWidth, restrictedHeight);
}

-(void)setDataSize:(CGSize)dataSize{
    column = floorf(dataSize.width);
    row = floorf(dataSize.height);
    data = [[NSMutableArray alloc]initWithCapacity:column * row];
    [self organizeView];
}

-(CGSize)dataSize{
    return CGSizeMake(column, row);
}

-(NSUInteger)dataLength{
    return column * row;
}

-(NSUInteger)filledDataLength{
    return data.count;
}


@end
