//
//  DialogSignMessageSelectAddress.m
//  bither-ios
//
//  Created by 宋辰文 on 14/12/26.
//  Copyright (c) 2014年 宋辰文. All rights reserved.
//

#import "DialogSignMessageSelectAddress.h"
#import "StringUtil.h"
#import "UIColor+Util.h"
#import "DialogAlert.h"
#import "UnitUtil.h"
#import "UIImage+ImageWithColor.h"

#define kCellBackgroundColor (0x262626)
#define kCellBackgroundColorPressed (0x212121)
#define kButtonHeight (44)
#define kCellHeight (50)
#define kPadding (15)
#define kButtonEdgeInsets (UIEdgeInsetsMake(0, 15, 0, 15))
#define kWidth ([UIScreen mainScreen].bounds.size.width * 0.8f)
#define kHeaderHeight (44)
#define kMaxHeight (250)
#define kFontSize (15)


#define kCellReuseIdentifier (@"Cell")
#define kHDExternalAddressesKey (@"HDExternalAddresses")
#define kHDInternalAddressesKey (@"HDInternalAddresses")
#define kPrivKeyAddressesKey (@"PrivKeyAddresses")

@interface DialogSignMessageSelectAddress () <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *types;
    NSMutableArray *addresses;
    NSArray *privKeyAddresses;
    NSArray *hdExternalAddresses;
    NSArray *hdInternalAddresses;
    NSMutableIndexSet *_foldedSections;
}

@property UITableView *tableView;

@end

@interface AddressCell : UITableViewCell

- (void)showForAddressType:(SignAddressType)addressType isLast:(BOOL)isLast;

@end

@implementation DialogSignMessageSelectAddress

- (instancetype)initWithDelegate:(NSObject <DialogSignMessageSelectAddressDelegate> *)delegate {
    self = [super initWithFrame:CGRectMake(0, 0, kWidth, kMaxHeight)];
    if (self) {
        self.delegate = delegate;
        types = [NSMutableArray new];
        BTAddressManager *addressManager = [BTAddressManager instance];
        if (addressManager.hasHDAccountHot || addressManager.hasHDAccountCold) {
            [types addObject:kHDExternalAddressesKey];
            [types addObject:kHDInternalAddressesKey];
        }
        if (addressManager.privKeyAddresses.count > 0) {
            [types addObject:kPrivKeyAddressesKey];
        }
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.bgInsets = UIEdgeInsetsMake(kPadding, 0, kPadding, 0);
    self.backgroundImage = [UIImage imageNamed:@"dialog_sign_message_bg"];
    UILabel *lblTop = [[UILabel alloc] initWithFrame:CGRectMake(kPadding, 0, self.frame.size.width, kHeaderHeight)];
    lblTop.textColor = [UIColor whiteColor];
    lblTop.font = [UIFont systemFontOfSize:kFontSize];
    lblTop.text = NSLocalizedString(@"sign_message_select_address", nil);
    lblTop.backgroundColor = [UIColor clearColor];
    lblTop.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:lblTop];

    _foldedSections = [NSMutableIndexSet indexSet];
    for (int i = 0; i < addresses.count; i++) {
        [_foldedSections addIndex:i];
    }
    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, kHeaderHeight, self.frame.size.width, self.frame.size.height - kHeaderHeight) style:UITableViewStylePlain];
    tv.rowHeight = kButtonHeight;
    tv.dataSource = self;
    tv.delegate = self;
    tv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tv.backgroundColor = [UIColor clearColor];
    tv.separatorStyle = UITableViewCellSeparatorStyleNone;
    tv.separatorInset = UIEdgeInsetsZero;
    if ([tv respondsToSelector:@selector(setLayoutMargins:)]) {
        tv.layoutMargins = UIEdgeInsetsZero;
    }
    [self addSubview:tv];
    self.tableView = tv;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return types.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressCell *c = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    if (!c) {
        c = [[AddressCell alloc] init];
    }
    
    [c showForAddressType:[self getAddressTypeForTypeStr:types[indexPath.row]] isLast:indexPath.row == (types.count - 1)];
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __block __weak NSObject <DialogSignMessageSelectAddressDelegate> *d = self.delegate;
    if (!d || ![d respondsToSelector:@selector(signMessageWithSignAddressType:)]) {
        return;
    }
    
    [self dismissWithCompletion:^{
        [d signMessageWithSignAddressType:[self getAddressTypeForTypeStr:types[indexPath.row]]];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (SignAddressType)getAddressTypeForTypeStr:(NSString *)typeStr {
    SignAddressType type;
    if ([typeStr isEqualToString:kHDExternalAddressesKey]) {
        type = HDExternal;
    } else if ([typeStr isEqualToString:kHDInternalAddressesKey]) {
        type = HDInternal;
    } else {
        type = Private;
    }
    return type;
}

@end

@interface AddressCell ()

@property UILabel *lblType;
@property UIImageView *ivType;
@property UIView *vLine;

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
    self.backgroundColor = [UIColor parseColor:kCellBackgroundColor];
    
    self.lblType = [[UILabel alloc] initWithFrame:CGRectMake(kPadding, 0, self.frame.size.width - kPadding * 2, kCellHeight)];
    self.lblType.font = [UIFont systemFontOfSize:kFontSize];
    self.lblType.textColor = [UIColor whiteColor];
    self.lblType.backgroundColor = [UIColor clearColor];
    self.lblType.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGFloat ivTypeWidth = 15;
    self.ivType = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - kPadding - ivTypeWidth, (kCellHeight - ivTypeWidth) / 2, ivTypeWidth, ivTypeWidth)];

    self.ivType.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    CGFloat lineHeight = 0.5;
    self.vLine = [[UIView alloc] initWithFrame:CGRectMake(kPadding, kCellHeight - lineHeight, self.frame.size.width - kPadding * 2, lineHeight)];
    self.vLine.backgroundColor = [UIColor r:117 g:117 b:117];
    self.vLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:self.lblType];
    [self addSubview:self.ivType];
    [self addSubview:self.vLine];
}

- (void)showForAddressType:(SignAddressType)addressType isLast:(BOOL)isLast {
    UIImage *typeImage = nil;
    NSString *typeStr;
    switch (addressType) {
        case HDExternal:
            typeImage = [UIImage imageNamed:@"address_type_hd"];
            typeStr = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"address_group_hd", nil), NSLocalizedString(@"address_receive", nil)];
            break;
        case HDInternal:
            typeImage = [UIImage imageNamed:@"address_type_hd"];
            typeStr = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"address_group_hd", nil), NSLocalizedString(@"address_changed", nil)];
            break;
        case Private:
            typeImage = [UIImage imageNamed:@"address_type_private"];
            typeStr = NSLocalizedString(@"Hot Wallet Address", nil);
            break;
        default:
            break;
    }
    
    self.lblType.text = typeStr;
    self.ivType.image = typeImage;
    [self.vLine setHidden:isLast];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.backgroundColor = [UIColor parseColor:kCellBackgroundColorPressed];
    } else {
        self.backgroundColor = [UIColor parseColor:kCellBackgroundColor];
    }
}

@end
