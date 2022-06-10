//
//  DialogNetworkCustomPeerOption.m
//  bither-ios
//
//  Created by 韩珍珍 on 2022/6/2.
//  Copyright © 2022 Bither. All rights reserved.
//

#import "DialogNetworkCustomPeerOption.h"
#import "BTPeerManager.h"
#import "NSString+Size.h"

#define kButtonHeight (44)
#define kButtonEdgeInsets (UIEdgeInsetsMake(0, 10, 0, 10))
#define kHeight (kButtonHeight * 3 + 2)
#define kMinWidth (160)
#define kFontSize (16)

@implementation DialogNetworkCustomPeerOption

- (instancetype)initWithDelegate:(NSObject <DialogNetworkCustomPeerOptionDelegate> *)delegate {
    NSString *str = NSLocalizedString(@"network_custom_peer_clear", nil);
    CGFloat width = [str sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, kButtonHeight) font:[UIFont systemFontOfSize:kFontSize]].width + kButtonEdgeInsets.left + kButtonEdgeInsets.right;
    width = MAX(kMinWidth, width);
    self = [super initWithFrame:CGRectMake(0, 0, width, kHeight)];
    if (self) {
        self.delegate = delegate;
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.bgInsets = UIEdgeInsetsMake(4, 16, 4, 16);
    CGFloat bottom = 0;
    bottom = [self createButtonWithText:NSLocalizedString(@"network_custom_peer_clear", nil) top:bottom action:@selector(clearPeerPressed:)];
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, self.frame.size.width, 1)];
    seperator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    seperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self addSubview:seperator];

    bottom += 1;
    bottom = [self createButtonWithText:NSLocalizedString(@"Cancel", nil) top:bottom action:@selector(cancelPressed:)];
    CGRect frame = self.frame;
    frame.size.height = bottom;
    self.frame = frame;
}

- (void)clearPeerPressed:(id)sender {   
    __weak __block NSObject <DialogNetworkCustomPeerOptionDelegate> *d = self.delegate;
    [self dismissWithCompletion:^{
        if (d && [d respondsToSelector:@selector(clearPeer)]) {
            [d clearPeer];
        }
    }];
    
}

- (void)cancelPressed:(id)sender {
    [self dismiss];
}

- (CGFloat)createButtonWithText:(NSString *)text top:(CGFloat)top action:(SEL)selector {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, top, self.frame.size.width, kButtonHeight)];
    [btn setBackgroundImage:nil forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"card_foreground_pressed"] forState:UIControlStateHighlighted];
    btn.contentEdgeInsets = kButtonEdgeInsets;
    btn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateHighlighted];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    return CGRectGetMaxY(btn.frame);
}

@end
