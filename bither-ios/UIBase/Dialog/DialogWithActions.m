//
//  DialogWithActions.m
//  bither-ios
//
//  Created by 宋辰文 on 15/1/30.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import "DialogWithActions.h"
#import "NSString+Size.h"

#define kButtonHeight (44)
#define kButtonEdgeInsets (UIEdgeInsetsMake(0, 10, 0, 10))

#define kHeight (kButtonHeight * 3 + 2)

#define kFontSize (16)

@implementation Action
- (instancetype)initWithName:(NSString *)name target:(NSObject *)target andSelector:(SEL)selector {
    self = [super init];
    if (self) {
        self.name = name;
        self.target = target;
        self.selector = selector;
    }
    return self;
}

- (void)perform {
    if (self.selector && self.target && [self.target respondsToSelector:self.selector]) {
        [self.target performSelector:self.selector];
    }
}

@end

@interface DialogWithActions () {
}
@end

@implementation DialogWithActions

- (instancetype)initWithActions:(NSArray *)actions {
    self = [super initWithFrame:CGRectMake(0, 0, [DialogWithActions maxWidth:actions] + kButtonEdgeInsets.left + kButtonEdgeInsets.right, (actions.count + 1) * (kButtonHeight + 1) - 1)];
    if (self) {
        self.actions = actions;
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.bgInsets = UIEdgeInsetsMake(4, 16, 4, 16);
    CGFloat bottom = 0;
    for (NSUInteger i = 0; i < self.actions.count; i++) {
        Action *a = self.actions[i];
        if (!a.target) {
            a.target = self;
        }
        bottom = [self createButtonWithName:a.name index:i top:bottom];
        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, self.frame.size.width, 1)];
        seperator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        seperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self addSubview:seperator];
        bottom += 1;
    }
    [self createButtonWithName:NSLocalizedString(@"Cancel", nil) index:-1 top:bottom];
}

- (CGFloat)createButtonWithName:(NSString *)action index:(NSInteger)index top:(CGFloat)top {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, top, self.frame.size.width, kButtonHeight)];
    [btn setBackgroundImage:nil forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"card_foreground_pressed"] forState:UIControlStateHighlighted];
    btn.contentEdgeInsets = kButtonEdgeInsets;
    btn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateHighlighted];
    [btn setTitle:action forState:UIControlStateNormal];
    [btn setTag:index];
    [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    return CGRectGetMaxY(btn.frame);
}

- (void)buttonPressed:(UIButton *)sender {
    NSInteger tag = sender.tag;
    Action *selectedAction = nil;
    if (tag >= 0 && tag < self.actions.count) {
        selectedAction = self.actions[tag];
    }
    [self dismissWithCompletion:^{
        if (selectedAction) {
            [selectedAction perform];
        }
    }];
}

+ (CGFloat)maxWidth:(NSArray *)actions {
    CGFloat max = 0;
    for (Action *a in actions) {
        CGFloat w = [a.name sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, kButtonHeight) font:[UIFont systemFontOfSize:kFontSize]].width;
        if (w > max) {
            max = w;
        }
    }
    return ceilf(max);
}

@end
