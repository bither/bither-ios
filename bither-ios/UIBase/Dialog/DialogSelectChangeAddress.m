//
//  DialogSelectChangeAddress.m
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

#import "DialogSelectChangeAddress.h"
#import "StringUtil.h"

#define kButtonHeight (44)
#define kButtonEdgeInsets (UIEdgeInsetsMake(0, 10, 0, 10))
#define kWidth ([UIScreen mainScreen].bounds.size.width * 0.7f)
#define kHeaderHeight (44)
#define kMaxHeight ([UIScreen mainScreen].bounds.size.height * 0.6f)
#define kFontSize (16)

#define kCellReuseIdentifier (@"Cell")

@interface DialogSelectChangeAddress () <UITableViewDataSource, UITableViewDelegate> {
    BTAddress *_changeAddress;
    BTAddress *_fromAddress;
    NSMutableArray *addresses;
}
@end

@interface Cell : UITableViewCell
@property BTAddress *address;
@end

@implementation DialogSelectChangeAddress

- (instancetype)initWithFromAddress:(BTAddress *)fromAddress {
    NSArray *as = [BTAddressManager instance].allAddresses;
    CGFloat height = as.count * (kButtonHeight + 1) - 1 + kHeaderHeight;
    height = MIN(kMaxHeight, height);
    self = [super initWithFrame:CGRectMake(0, 0, kWidth, height)];
    if (self) {
        self.bgInsets = UIEdgeInsetsMake(4, 16, 4, 16);
        _fromAddress = fromAddress;
        _changeAddress = fromAddress;
        addresses = [NSMutableArray new];
        [addresses addObjectsFromArray:as];
        [addresses removeObject:_fromAddress];
        [addresses insertObject:_fromAddress atIndex:0];
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    UILabel *lblTop = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kHeaderHeight)];
    lblTop.textColor = [UIColor whiteColor];
    lblTop.font = [UIFont systemFontOfSize:kFontSize];
    lblTop.text = NSLocalizedString(@"select_change_address_label", nil);
    lblTop.backgroundColor = [UIColor clearColor];
    lblTop.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:lblTop];

    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, kHeaderHeight, self.frame.size.width, self.frame.size.height - kHeaderHeight) style:UITableViewStylePlain];
    tv.rowHeight = kButtonHeight;
    tv.dataSource = self;
    tv.delegate = self;
    tv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tv.backgroundColor = [UIColor clearColor];
    tv.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tv.separatorInset = UIEdgeInsetsZero;
    if ([tv respondsToSelector:@selector(setLayoutMargins:)]) {
        tv.layoutMargins = UIEdgeInsetsZero;
    }
    [tv selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:YES];
    [self addSubview:tv];

    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, kHeaderHeight - 1 / [UIScreen mainScreen].scale, self.frame.size.width, 1 / [UIScreen mainScreen].scale)];
    v.backgroundColor = tv.separatorColor;
    v.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:v];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return addresses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Cell *c = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    if (!c) {
        c = [[Cell alloc] init];
    }
    c.address = addresses[indexPath.row];
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _changeAddress = [addresses objectAtIndex:indexPath.row];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.3];
}

- (BTAddress *)changeAddress {
    return _changeAddress;
}

@end

@interface Cell () {
    BTAddress *_address;
}
@property UILabel *lblAddress;
@property UIImageView *ivType;
@property UIImageView *ivSelected;
@end

@implementation Cell

- (instancetype)init {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseIdentifier];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.separatorInset = UIEdgeInsetsZero;
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        self.layoutMargins = UIEdgeInsetsZero;
    }
    self.backgroundColor = [UIColor clearColor];
    self.lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(kButtonEdgeInsets.left, kButtonEdgeInsets.top, self.frame.size.width - kButtonEdgeInsets.left - kButtonEdgeInsets.right, self.frame.size.height - kButtonEdgeInsets.top - kButtonEdgeInsets.bottom)];
    self.lblAddress.font = [UIFont systemFontOfSize:kFontSize];
    self.lblAddress.textColor = [UIColor whiteColor];
    self.lblAddress.backgroundColor = [UIColor clearColor];
    self.lblAddress.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.ivSelected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
    self.ivSelected.frame = CGRectMake(self.frame.size.width - kButtonEdgeInsets.right - self.ivSelected.frame.size.width, (self.frame.size.height - self.ivSelected.frame.size.height) / 2, self.ivSelected.frame.size.width, self.ivSelected.frame.size.height);
    self.ivSelected.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    self.ivType = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"address_type_private"]];
    self.ivType.frame = CGRectMake(self.ivSelected.frame.origin.x - self.ivType.frame.size.width - 10, (self.frame.size.height - self.ivType.frame.size.height) / 2, self.ivType.frame.size.width, self.ivType.frame.size.height);
    self.ivType.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:self.lblAddress];
    [self addSubview:self.ivType];
    [self addSubview:self.ivSelected];
    self.ivSelected.hidden = YES;
}

- (void)setAddress:(BTAddress *)address {
    _address = address;
    self.lblAddress.text = [StringUtil shortenAddress:address.address];
    if (address.isHDM) {
        self.ivType.image = [UIImage imageNamed:@"address_type_hdm"];
    } else if (address.hasPrivKey) {
        self.ivType.image = [UIImage imageNamed:@"address_type_private"];
    } else {
        self.ivType.image = [UIImage imageNamed:@"address_type_watchonly"];
    }
    self.ivSelected.hidden = !self.selected;
}

- (BTAddress *)address {
    return _address;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.ivSelected.hidden = !selected;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

@end