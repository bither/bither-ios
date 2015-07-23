//
//  DialogOldAddressesOfHDAccount.m
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
//  Created by songchenwen on 15/7/17.
//

#import <Bitheri/BTHDAccount.h>
#import "DialogOldAddressesOfHDAccount.h"
#import "NSString+Size.h"
#import "StringUtil.h"
#import "UIViewController+PiShowBanner.h"
#import "DialogWithActions.h"
#import "UserDefaultsUtil.h"
#import "DialogShowAddressOnNet.h"

#define kAddressFontSize (16)
#define kAddressButtonPadding (4)
#define kAmountFontSize (14)
#define kRowVerticalPadding (5)
#define kRowMinHeight (36)
#define kColumnMargin (30)

#define kAddressGroupSize (4)
#define kAddressLineSize (12)
#define kAddressExample (@"1Nc9oEokW91HUohUpHt4Y7DisQXLuEBi77")

@protocol CellDelegate <ShowBannerDelegete>
- (void)dismissWithCompletion:(void (^)())completion;
@end

@interface DialogOldAddressesOfHDAccountCell : UITableViewCell {
    NSString *_address;
}
@property UILabel *lblAddress;
@property UIButton *btnAddress;
@property UIButton *btnShow;
@property UIView *vSeperator;
@property(weak) NSObject <CellDelegate> *delegate;

- (void)showAddress:(NSString *)address;
@end


@interface DialogOldAddressesOfHDAccount () <UITableViewDataSource, UITableViewDelegate, CellDelegate> {
    BTHDAccount *_account;
}
@property(weak) NSObject <ShowBannerDelegete> *delegate;
@property UITableView *table;
@end

@implementation DialogOldAddressesOfHDAccount

- (instancetype)initWithAccount:(BTHDAccount *)account andDeleget:(NSObject <ShowBannerDelegete> *)delegate {
    CGSize size = [DialogOldAddressesOfHDAccount caculateSize:account];
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        _account = account;
        self.delegate = delegate;
        [self configureViews];
    }
    return self;
}

- (void)configureViews {
    self.bgInsets = UIEdgeInsetsMake(8, 16, 8, 16);
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    self.table.backgroundColor = [UIColor clearColor];
    [self.table registerClass:[DialogOldAddressesOfHDAccountCell class] forCellReuseIdentifier:@"Cell"];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:self.table];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _account.issuedExternalIndex + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DialogOldAddressesOfHDAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell showAddress:[_account addressForPath:EXTERNAL_ROOT_PATH atIndex:indexPath.row].address];
    cell.vSeperator.hidden = indexPath.row == _account.issuedExternalIndex;
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *address = [_account addressForPath:EXTERNAL_ROOT_PATH atIndex:indexPath.row].address;
    if (address.length > 30) {
        address = [StringUtil formatAddress:address groupSize:kAddressGroupSize lineSize:kAddressLineSize];
    }
    CGSize addressSize = [address sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:[UIFont fontWithName:@"Courier New" size:kAddressFontSize]];
    addressSize.height += kAddressButtonPadding * 2 + kRowVerticalPadding * 2;
    addressSize.height = MAX(addressSize.height, kRowMinHeight);
    return addressSize.height;
}

- (void)showBannerWithMessage:(NSString *)msg {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showBannerWithMessage:)]) {
        [self.delegate showBannerWithMessage:msg];
    }
}

+ (CGSize)caculateSize:(BTHDAccount *)account {
    CGFloat height = 0;
    CGFloat width = 0;
    NSUInteger rowCount = account.issuedExternalIndex + 1;
    NSUInteger columnCount = 2;
    CGFloat firstColumnWidth = 0;
    CGFloat secondColumnWidth = 30;
    NSString *address = [account addressForPath:EXTERNAL_ROOT_PATH atIndex:0].address;
    if (address.length > 30) {
        address = [StringUtil formatAddress:address groupSize:kAddressGroupSize lineSize:kAddressLineSize];
    }
    CGSize addressSize = [address sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:[UIFont fontWithName:@"Courier New" size:kAddressFontSize]];
    addressSize.width += kAddressButtonPadding * 2;
    addressSize.height += kAddressButtonPadding * 2 + kRowVerticalPadding * 2;
    addressSize.height = MAX(addressSize.height, kRowMinHeight);
    firstColumnWidth = MAX(addressSize.width, firstColumnWidth);
    height = addressSize.height * rowCount;
    width = firstColumnWidth + ((columnCount > 1 && secondColumnWidth > 0) ? (kColumnMargin + secondColumnWidth) : 0);
    height = MIN(height, [UIScreen mainScreen].bounds.size.height / 2);
    return CGSizeMake(width, height);
}
@end

@implementation DialogOldAddressesOfHDAccountCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configureViews];
    }
    return self;
}

- (void)configureViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    CGSize exampleAddressSize = [[StringUtil formatAddress:kAddressExample groupSize:kAddressGroupSize lineSize:kAddressLineSize] sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:[UIFont fontWithName:@"Courier New" size:kAddressFontSize]];
    self.frame = CGRectMake(0, 0, exampleAddressSize.width + kAddressButtonPadding * 2 + kColumnMargin + 50, exampleAddressSize.height + kAddressButtonPadding * 2 + kRowVerticalPadding * 2);
    self.btnAddress = [[UIButton alloc] initWithFrame:CGRectMake(0, kRowVerticalPadding, exampleAddressSize.width + kAddressButtonPadding * 2, exampleAddressSize.height + kAddressButtonPadding * 2)];
    self.btnAddress.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    self.btnAddress.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.btnAddress.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    [self.btnAddress setBackgroundImage:[UIImage imageNamed:@"card_foreground_pressed"] forState:UIControlStateHighlighted];
    [self.btnAddress setImage:[UIImage imageNamed:@"dropdown_ic_arrow_normal_holo_light"] forState:UIControlStateNormal];
    [self.btnAddress setImage:[UIImage imageNamed:@"dropdown_ic_arrow_pressed_holo_light"] forState:UIControlStateHighlighted];
    [self.btnAddress addTarget:self action:@selector(copyAddress:) forControlEvents:UIControlEventTouchUpInside];

    self.lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(kAddressButtonPadding, kRowVerticalPadding + kAddressButtonPadding, exampleAddressSize.width, exampleAddressSize.height)];
    self.lblAddress.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    self.lblAddress.textColor = [UIColor whiteColor];
    self.lblAddress.font = [UIFont fontWithName:@"Courier New" size:kAddressFontSize];
    self.lblAddress.backgroundColor = [UIColor clearColor];
    self.lblAddress.numberOfLines = 3;

    CGFloat btnSize = 30;
    self.btnShow = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.lblAddress.frame) + kColumnMargin + 8, (self.frame.size.height - btnSize) / 2, btnSize, btnSize)];
    self.btnShow.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    self.btnShow.contentMode = UIViewContentModeCenter;
    [self.btnShow setImage:[UIImage imageNamed:@"address_full_show_button"] forState:UIControlStateNormal];
    [self.btnShow addTarget:self action:@selector(showPresssed:) forControlEvents:UIControlEventTouchUpInside];

    self.vSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
    self.vSeperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5f];
    self.vSeperator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    [self addSubview:self.vSeperator];
    [self addSubview:self.btnShow];
    [self addSubview:self.btnAddress];
    [self addSubview:self.lblAddress];
}

- (void)showAddress:(NSString *)address {
    _address = address;
    CGRect frame = self.lblAddress.frame;
    if (address.length > 30) {
        self.lblAddress.text = [StringUtil formatAddress:address groupSize:kAddressGroupSize lineSize:kAddressLineSize];
        frame.size.width = self.btnAddress.frame.size.width - kAddressButtonPadding * 2;
        self.btnAddress.hidden = NO;
    } else {
        self.lblAddress.text = address;
        frame.size.width = self.frame.size.width;
        self.btnAddress.hidden = YES;
    }
    self.lblAddress.frame = frame;
}

- (void)showPresssed:(id)sender {
    __block DialogShowAddressOnNet *dialog = [[DialogShowAddressOnNet alloc] initWithAddress:_address];
    __block UIWindow *window = self.window;
    [self.delegate dismissWithCompletion:^{
        [dialog showInWindow:window];
    }];
}

- (void)copyAddress:(id)sender {
    [UIPasteboard generalPasteboard].string = _address;
    [self.delegate dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(showBannerWithMessage:)]) {
            [self.delegate showBannerWithMessage:NSLocalizedString(@"Address copied.", nil)];
        }
    }];
}

@end
