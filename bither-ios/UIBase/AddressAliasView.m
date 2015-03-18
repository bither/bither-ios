//
//  AddressAliasView.m
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

#import <Bitheri/BTUtils.h>
#import "AddressAliasView.h"
#import "DialogAddressAlias.h"

#define kMinWidth (31)
#define kMinHeight (15)

@interface AddressAliasView () <DialogAddressAliasDelegate> {
    BTAddress *_address;
}
@end

@implementation AddressAliasView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    [self setBackgroundImage:[UIImage imageNamed:@"address_alias_default"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"address_alias_pressed"] forState:UIControlStateHighlighted];
    [self setContentEdgeInsets:UIEdgeInsetsMake(0, 11, 0, 4)];
    self.titleLabel.font = [UIFont systemFontOfSize:11];
    [self setTitleColor:[UIColor colorWithWhite:0 alpha:0.7] forState:UIControlStateNormal];
    [self addTarget:self action:@selector(pressed:) forControlEvents:UIControlEventTouchUpInside];
    self.hidden = YES;
}

- (void)pressed:(id)sender {
    [[[DialogAddressAlias alloc] initWithAddress:_address andDelegate:self] showInWindow:self.window];
}

- (void)setAddress:(BTAddress *)address {
    _address = address;
    [self onAddressAliasChanged:address alias:address.alias];
}

- (void)onAddressAliasChanged:(BTAddress *)address alias:(NSString *)alias {
    if ([BTUtils isEmpty:alias]) {
        self.hidden = YES;
        return;
    }
    self.hidden = NO;
    [self setTitle:alias forState:UIControlStateNormal];
    [self autoResize];
}

- (void)autoResize {
    CGFloat width = ceil([self sizeThatFits:CGSizeMake(CGFLOAT_MAX, self.frame.size.height)].width);
    width = MAX(kMinWidth, width);
    if (self.maxWidth >= kMinWidth) {
        width = MIN(self.maxWidth, width);
    }
    CGRect frame = self.frame;
    if ((self.autoresizingMask & UIViewAutoresizingFlexibleLeftMargin) == UIViewAutoresizingFlexibleLeftMargin && (self.autoresizingMask & UIViewAutoresizingFlexibleRightMargin) == UIViewAutoresizingFlexibleRightMargin) {
        NSLog(@"AddressAliasView align center");
        frame.origin.x -= (width - frame.size.width) / 2;
        frame.size.width = width;
    } else if ((self.autoresizingMask & UIViewAutoresizingFlexibleLeftMargin) == UIViewAutoresizingFlexibleLeftMargin) {
        NSLog(@"AddressAliasView align right");
        frame.origin.x -= (width - frame.size.width);
        frame.size.width = width;
    } else if ((self.autoresizingMask & UIViewAutoresizingFlexibleRightMargin) == UIViewAutoresizingFlexibleRightMargin) {
        NSLog(@"AddressAliasView align left");
        frame.size.width = width;
    }
    self.frame = frame;
}

- (BTAddress *)address {
    return _address;
}
@end