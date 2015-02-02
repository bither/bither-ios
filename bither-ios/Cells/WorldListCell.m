//
//  WorldListCell.m
//  bither-ios
//
//  Created by noname on 15/2/2.
//  Copyright (c) 2015年 noname. All rights reserved.
//

#import "WorldListCell.h"

#define Margin 3

@interface WorldListCell()

@property (strong, nonatomic)UILabel* labIndex;
@property (strong, nonatomic)UILabel* labWorld;

@end

@implementation WorldListCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initConfigure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initConfigure];
    }
    return self;
}


-(void)initConfigure{
    CGRect ivRect = CGRectMake(Margin, Margin, self.frame.size.width - Margin * 2, self.frame.size.height - Margin * 2);
    self.labIndex = [[UILabel alloc]initWithFrame:ivRect];
  
    self.labWorld = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    [self addSubview:self.labIndex];
    [self addSubview:self.labWorld];
}
-(void)setWorld:(NSString *)world index:(NSInteger)index{
    self.labWorld.text=world;
    self.labIndex.text=[NSString stringWithFormat:@"%d.",index];
}

@end
