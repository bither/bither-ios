//
//  TabButton.m
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

#import "TabButton.h"

#define kTabButtonBottomHeight (2)
#define kTabButtonBadgetLeftOffset (8)
#define kTabButtonBadgetTopOffset (3)
#define kTabButtonBadgetSize (16)
#define kTabButtonBadgetFontSize (7)

@interface TabButton ()
@property(strong, nonatomic) UIImageView *ivBottom;
@property(strong, nonatomic) UIView *vBadget;
@property(strong, nonatomic) UIImageView *ivBadgetBg;
@property(strong, nonatomic) UILabel *lblBadget;
@end

@implementation TabButton

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
    self.backgroundColor = [UIColor clearColor];

    self.button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    UIImage *image = [UIImage imageNamed:@"topnav_overlay_pressed"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2, 0, image.size.height / 2, 0)];
    [self.button setBackgroundImage:image forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.button];

    self.iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - kTabButtonBottomHeight)];
    self.iv.contentMode = UIViewContentModeCenter;
    [self addSubview:self.iv];

    self.ivBottom = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - kTabButtonBottomHeight, self.frame.size.width, kTabButtonBottomHeight)];
    image = [UIImage imageNamed:@"topnav_tab_bar"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2, 0, image.size.height / 2, 0)];
    self.ivBottom.image = image;
    self.ivBottom.hidden = YES;
    [self addSubview:self.ivBottom];

    self.vBadget = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 + kTabButtonBadgetLeftOffset, kTabButtonBadgetTopOffset, kTabButtonBadgetSize, kTabButtonBadgetSize)];
    self.ivBadgetBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.vBadget.frame.size.width, self.vBadget.frame.size.height)];
    self.ivBadgetBg.image = [UIImage imageNamed:@"new_message_bg"];
    self.lblBadget = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.vBadget.frame.size.width, self.vBadget.frame.size.height)];
    self.lblBadget.backgroundColor = [UIColor clearColor];
    self.lblBadget.textAlignment = UITextAlignmentCenter;
    self.lblBadget.textColor = [UIColor whiteColor];
    self.lblBadget.font = [UIFont boldSystemFontOfSize:kTabButtonBadgetFontSize];
    [self.vBadget addSubview:self.ivBadgetBg];
    [self.vBadget addSubview:self.lblBadget];
    [self addSubview:self.vBadget];
    self.vBadget.hidden = YES;

    self.selected = NO;
}

- (void)setBadget:(NSInteger)badget {
    if (_badget != badget) {
        _badget = badget;
        self.vBadget.hidden = !(badget > 0);
        if (badget < 9) {
            self.lblBadget.text = [NSString stringWithFormat:@"%d", badget];
        } else {
            self.lblBadget.text = @"9+";
        }
    }
}

- (void)buttonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate tabButtonPressed:self.index];
    }
}

- (UIImage *)imageSelected {
    return self.iv.highlightedImage;
}

- (void)setImageSelected:(UIImage *)imageSelected {
    if (self.iv.highlightedImage != imageSelected) {
        self.iv.highlightedImage = imageSelected;
    }
}

- (UIImage *)imageUnselected {
    return self.iv.image;
}

- (void)setImageUnselected:(UIImage *)imageUnselected {
    if (self.iv.image != imageUnselected) {
        self.iv.image = imageUnselected;
    }
}

- (void)setSelected:(BOOL)selected {
    if (selected != _selected) {
        _selected = selected;
        self.iv.highlighted = _selected;
        self.ivBottom.hidden = !_selected;
    }
}

@end
