//
//  DialogSignMessageSelectAddress.m
//  bither-ios
//
//  Created by 宋辰文 on 14/12/26.
//  Copyright (c) 2014年 宋辰文. All rights reserved.
//

#import "DialogSignMessageSelectAddress.h"
#import "StringUtil.h"

#define kButtonHeight (44)
#define kButtonEdgeInsets (UIEdgeInsetsMake(0, 10, 0, 10))
#define kWidth ([UIScreen mainScreen].bounds.size.width * 0.6f)
#define kHeaderHeight (44)
#define kMaxHeight ([UIScreen mainScreen].bounds.size.height * 0.6f)
#define kFontSize (16)

#define kCellReuseIdentifier (@"Cell")

@interface DialogSignMessageSelectAddress () <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *addresses;
}
@end

@interface AddressCell : UITableViewCell
@property BTAddress *address;
@end

@implementation DialogSignMessageSelectAddress


- (instancetype)initWithDelegate:(NSObject <DialogSignMessageSelectAddressDelegate> *)delegate {
    NSArray *as = [BTAddressManager instance].privKeyAddresses;
    CGFloat height = as.count * (kButtonHeight + 1) - 1 + kHeaderHeight;
    height = MIN(kMaxHeight, height);
    self = [super initWithFrame:CGRectMake(0, 0, kWidth, height)];
    if (self) {
        self.delegate = delegate;
        self.bgInsets = UIEdgeInsetsMake(4, 16, 4, 16);
        addresses = [NSMutableArray new];
        [addresses addObjectsFromArray:as];
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    UILabel *lblTop = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kHeaderHeight)];
    lblTop.textColor = [UIColor whiteColor];
    lblTop.font = [UIFont systemFontOfSize:kFontSize];
    lblTop.text = NSLocalizedString(@"sign_message_select_address", nil);
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
    AddressCell *c = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    if (!c) {
        c = [[AddressCell alloc] init];
    }
    c.address = addresses[indexPath.row];
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __block __weak NSObject <DialogSignMessageSelectAddressDelegate> *d = self.delegate;
    __block __weak BTAddress *address = addresses[indexPath.row];
    if (!d || !address || ![d respondsToSelector:@selector(signMessageWithAddress:)]) {
        return;
    }
    [self dismissWithCompletion:^{
        [d signMessageWithAddress:address];
    }];
}

@end

@interface AddressCell () {
    BTAddress *_address;
}
@property UILabel *lblAddress;
@property UIImageView *ivType;
@end

@implementation AddressCell

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
    self.ivType = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"address_type_private"]];
    self.ivType.frame = CGRectMake(self.frame.size.width - kButtonEdgeInsets.right - self.ivType.frame.size.width, (self.frame.size.height - self.ivType.frame.size.height) / 2, self.ivType.frame.size.width, self.ivType.frame.size.height);
    self.ivType.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:self.lblAddress];
    [self addSubview:self.ivType];
}

- (void)setAddress:(BTAddress *)address {
    _address = address;
    self.lblAddress.text = [StringUtil shortenAddress:address.address];
    if (address.hasPrivKey) {
        self.ivType.image = [UIImage imageNamed:@"address_type_private"];
    } else {
        self.ivType.image = [UIImage imageNamed:@"address_type_watchonly"];
    }
}

- (BTAddress *)address {
    return _address;
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
