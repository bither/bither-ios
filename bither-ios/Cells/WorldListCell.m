
#import "WorldListCell.h"

#define Margin 5

@interface WorldListCell()

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
    CGRect ivRect = CGRectMake(5, 15, self.frame.size.width , 20);

    self.labWorld = [[UILabel alloc]initWithFrame:ivRect];
    [self addSubview:self.labWorld];
    [self setBackgroundColor:[UIColor whiteColor]];

}
-(void)setWorld:(NSString *)world index:(NSInteger)index{
    self.labWorld.text=[NSString stringWithFormat:@"%d.%@",index+1,world];

}

@end
