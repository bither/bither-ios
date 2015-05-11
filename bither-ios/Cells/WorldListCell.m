#import "WorldListCell.h"
#import "UIBaseUtil.h"


@interface WorldListCell ()

@property(strong, nonatomic) UILabel *labWorld;
@property(strong, nonatomic) UIButton *btnBackground;
@property(strong, nonatomic) NSString *world;
@property(nonatomic, readwrite) int index;
@end

@implementation WorldListCell


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initConfigure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initConfigure];
    }
    return self;
}


- (void)initConfigure {
    CGRect ivRect = CGRectMake(10, 15, self.frame.size.width, 20);
    self.btnBackground = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.btnBackground setBackgroundImage:[UIImage imageNamed:@"textarea_background"] forState:UIControlStateNormal];
    [self.btnBackground setBackgroundImage:[UIImage imageNamed:@"textarea_background_pressed"] forState:UIControlStateHighlighted];

    [self.btnBackground addTarget:self action:@selector(operationWorld:) forControlEvents:UIControlEventTouchUpInside];

    [UIBaseUtil makeButtonBgResizable:self.btnBackground];

    [self addSubview:self.btnBackground];

    self.labWorld = [[UILabel alloc] initWithFrame:ivRect];
    self.labWorld.font = [UIFont systemFontOfSize:14];
    [self addSubview:self.labWorld];
    [self setBackgroundColor:[UIColor clearColor]];

}

- (void)setWorld:(NSString *)world index:(NSInteger)index {
    self.world = world;
    self.index = index;
    self.labWorld.text = [NSString stringWithFormat:@"%d.%@", index + 1, world];

}

- (void)operationWorld:(id)sender {
    if ([self.delegate respondsToSelector:@selector(beginOperation)]) {
        [self.delegate beginOperation];
    }
    DialogOperationWorld *dialogOperationWorld = [[DialogOperationWorld alloc] initWithDelegate:self.delegate world:self.world index:self.index];
    [dialogOperationWorld showInWindow:self.window];
}


@end
