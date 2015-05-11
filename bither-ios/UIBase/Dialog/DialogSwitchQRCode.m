//
//  DialogSwitchQRCode.m
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

#import "DialogSwitchQRCode.h"
#import "NSString+Size.h"

#define kButtonHeight (44)
#define kButtonEdgeInsets (UIEdgeInsetsMake(0, 10, 0, 10))

#define kHeight (kButtonHeight * 3 + 2)

#define kFontSize (16)

@interface DialogSwitchQRCode () {
    NSString *switchQRCodeStr;
}
@end

@implementation DialogSwitchQRCode

- (instancetype)initWithDelegate:(NSObject <DialogSwitchQRCodeDelegate> *)delegate {
    NSString *viewStr = NSLocalizedString(@"Switch QRCode", nil);
    self = [super initWithFrame:CGRectMake(0, 0, [viewStr sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, kButtonHeight) font:[UIFont systemFontOfSize:kFontSize]].width + kButtonEdgeInsets.left + kButtonEdgeInsets.right, kHeight)];
    if (self) {
        switchQRCodeStr = viewStr;
        self.delegate = delegate;
        [self firstConfigureHasPrivateKey];
    }
    return self;
}

- (void)firstConfigureHasPrivateKey {
    self.bgInsets = UIEdgeInsetsMake(4, 16, 4, 16);
    CGFloat bottom = 0;
    bottom = [self createButtonWithText:switchQRCodeStr top:bottom action:@selector(viewOnBlockChainInfoPressed:)];
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

- (void)viewOnBlockChainInfoPressed:(id)sender {
    [self dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(switchQRCode)]) {
            [self.delegate switchQRCode];
        }
    }];
}


- (void)cancelPressed:(id)sender {
    [self dismiss];
}


@end
