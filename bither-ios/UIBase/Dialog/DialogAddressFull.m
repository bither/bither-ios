//
//  DialogAddressFull.m
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

#import "DialogAddressFull.h"
#import "StringUtil.h"
#import "UnitUtil.h"
#import "NSString+Size.h"

#define kAddressFontSize (16)
#define kAddressButtonPadding (4)
#define kAmountFontSize (14)
#define kRowVerticalPadding (5)
#define kRowMinHeight (36)
#define kColumnMargin (30)

#define kAddressGroupSize (4)
#define kAddressLineSize (12)
#define kAddressExample (@"1Nc9oEokW91HUohUpHt4Y7DisQXLuEBi77")

@interface DialogAddressFullCell : UITableViewCell {
    NSString *_address;
}
@property UILabel *lblAddress;
@property UIButton *btnAddress;
@property UILabel *lblAmount;
@property UIView *vSeperator;
@property(weak) NSObject <DialogAddressFullDelegate> *delegate;

- (void)showAddress:(NSString *)address andAmount:(int64_t)amount;
@end


@interface DialogAddressFull () <UITableViewDataSource, UITableViewDelegate>
@property UITableView *table;
@end

@implementation DialogAddressFull


- (instancetype)initWithDelegate:(NSObject <DialogAddressFullDelegate> *)delegate {
    CGSize size = [DialogAddressFull caculateSize:delegate];
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        self.delegate = delegate;
        [self configureViews];
    }
    return self;
}

- (void)configureViews {
    self.bgInsets = UIEdgeInsetsMake(8, 16, 8, 16);
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    self.table.backgroundColor = [UIColor clearColor];
    [self.table registerClass:[DialogAddressFullCell class] forCellReuseIdentifier:@"Cell"];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:self.table];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.delegate dialogAddressFullRowCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DialogAddressFullCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.delegate = self.delegate;
    [cell showAddress:[self.delegate dialogAddressFullAddressForRow:indexPath.row] andAmount:[self.delegate dialogAddressFullAmountForRow:indexPath.row]];
    cell.vSeperator.hidden = indexPath.row == [self.delegate dialogAddressFullRowCount] - 1;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *address = [self.delegate dialogAddressFullAddressForRow:indexPath.row];
    if (address.length > 30) {
        address = [StringUtil formatAddress:address groupSize:kAddressGroupSize lineSize:kAddressLineSize];
    }
    CGSize addressSize = [address sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:[UIFont fontWithName:@"Courier New" size:kAddressFontSize]];
    addressSize.height += kAddressButtonPadding * 2 + kRowVerticalPadding * 2;
    addressSize.height = MAX(addressSize.height, kRowMinHeight);
    return addressSize.height;
}

+ (CGSize)caculateSize:(NSObject <DialogAddressFullDelegate> *)delegate {
    CGFloat height = 0;
    CGFloat width = 0;
    NSUInteger rowCount = [delegate dialogAddressFullRowCount];
    NSUInteger columnCount = [delegate dialogAddressFullDoubleColumn] ? 2 : 1;
    CGFloat firstColumnWidth = 0;
    CGFloat secondColumnWidth = 0;
    for (NSUInteger i = 0; i < rowCount; i++) {
        NSString *address = [delegate dialogAddressFullAddressForRow:i];
        if (address.length > 30) {
            address = [StringUtil formatAddress:address groupSize:kAddressGroupSize lineSize:kAddressLineSize];
        }
        CGSize addressSize = [address sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:[UIFont fontWithName:@"Courier New" size:kAddressFontSize]];
        addressSize.width += kAddressButtonPadding * 2;
        addressSize.height += kAddressButtonPadding * 2 + kRowVerticalPadding * 2;
        addressSize.height = MAX(addressSize.height, kRowMinHeight);
        height += addressSize.height;
        firstColumnWidth = MAX(addressSize.width, firstColumnWidth);
        if (columnCount > 1) {
            int64_t amount = [delegate dialogAddressFullAmountForRow:i];
            if (amount != 0) {
                NSString *amountStr = [UnitUtil stringForAmount:amount];
                CGSize amountSize = [amountStr sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, addressSize.height) font:[UIFont systemFontOfSize:kAmountFontSize]];
                secondColumnWidth = MAX(secondColumnWidth, amountSize.width);
            }
        }
    }
    width = firstColumnWidth + ((columnCount > 1 && secondColumnWidth > 0) ? (kColumnMargin + secondColumnWidth) : 0);
    height = MIN(height, [UIScreen mainScreen].bounds.size.height / 2);
    return CGSizeMake(width, height);
}

@end

@implementation DialogAddressFullCell

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

    self.lblAmount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.lblAmount.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.lblAmount.textAlignment = NSTextAlignmentRight;
    self.lblAmount.textColor = [UIColor whiteColor];
    self.lblAmount.font = [UIFont systemFontOfSize:kAmountFontSize];
    self.lblAmount.backgroundColor = [UIColor clearColor];

    self.vSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
    self.vSeperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5f];
    self.vSeperator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    [self addSubview:self.vSeperator];
    [self addSubview:self.lblAmount];
    [self addSubview:self.btnAddress];
    [self addSubview:self.lblAddress];
}

- (void)showAddress:(NSString *)address andAmount:(int64_t)amount {
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
    if (amount != 0) {
        self.lblAmount.hidden = NO;
        self.lblAmount.text = [UnitUtil stringForAmount:amount];
    } else {
        self.lblAmount.hidden = YES;
    }
}

- (void)copyAddress:(id)sender {
    [UIPasteboard generalPasteboard].string = _address;
    if (self.delegate && [self.delegate respondsToSelector:@selector(showMsg:)]) {
        [self.delegate showMsg:NSLocalizedString(@"Address copied.", nil)];
    }
}

@end

