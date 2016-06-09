//
//  DialogHDColdFirst20Addresses.m
//  bither-ios
//
//  Created by 宋辰文 on 16/6/9.
//  Copyright © 2016年 Bither. All rights reserved.
//

#import "DialogHDColdFirst20Addresses.h"
#import "NSString+Size.h"
#import "StringUtil.h"
#import "BTBIP32Key.h"
#import "BTHDAccountAddress.h"

#define kAddressCount (20)

#define kAddressFontSize (16)
#define kAddressButtonPadding (4)
#define kAmountFontSize (14)
#define kRowVerticalPadding (5)
#define kRowMinHeight (36)
#define kColumnMargin (30)

#define kAddressGroupSize (4)
#define kAddressLineSize (12)
#define kAddressExample (@"1Nc9oEokW91HUohUpHt4Y7DisQXLuEBi77")

@interface DialogHDColdFirst20AddressesCell : UITableViewCell {
    NSString *_address;
}
@property UILabel *lblAddress;
@property UIView *vSeperator;

- (void)showAddress:(NSString *)address;
@end


@interface DialogHDColdFirst20Addresses () <UITableViewDataSource, UITableViewDelegate> {
    BTHDAccountCold *_account;
    NSMutableArray *addresses;
}
@property UITableView *table;
@property UIActivityIndicatorView *ai;
@end

@implementation DialogHDColdFirst20Addresses

- (instancetype)initWithAccount:(BTHDAccountCold *)account andPassword:(NSString *)password {
    CGSize size = [DialogHDColdFirst20Addresses caculateSize];
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        _account = account;
        [self configureViews:password];
    }
    return self;
}

- (void)configureViews:(NSString* )password {
    addresses = [NSMutableArray new];
    self.bgInsets = UIEdgeInsetsMake(8, 16, 8, 16);
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    self.table.backgroundColor = [UIColor clearColor];
    [self.table registerClass:[DialogHDColdFirst20AddressesCell class] forCellReuseIdentifier:@"Cell"];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:self.table];
    self.ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.ai.frame = CGRectMake((self.frame.size.width - self.ai.frame.size.width) / 2, (self.frame.size.height - self.ai.frame.size.height) / 2, self.ai.frame.size.width, self.ai.frame.size.height);
    [self addSubview:self.ai];
    [self.ai startAnimating];
    self.table.hidden = YES;
    self.ai.hidden = NO;
    __block NSString* p = password;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        BTBIP32Key* xpub = [_account xPub:p];
        BTBIP32Key* externalRoot = [xpub deriveSoftened:EXTERNAL_ROOT_PATH];
        for (int i = 0; i < kAddressCount; i++){
            [addresses addObject:[externalRoot deriveSoftened:i].address];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.table reloadData];
            self.ai.hidden = YES;
            self.table.hidden = NO;
        });
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return addresses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DialogHDColdFirst20AddressesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell showAddress:addresses[indexPath.row]];
    cell.vSeperator.hidden = indexPath.row == kAddressCount;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *address = addresses[indexPath.row];
    if (address.length > 30) {
        address = [StringUtil formatAddress:address groupSize:kAddressGroupSize lineSize:kAddressLineSize];
    }
    CGSize addressSize = [address sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:[UIFont fontWithName:@"Courier New" size:kAddressFontSize]];
    addressSize.height += kAddressButtonPadding * 2 + kRowVerticalPadding * 2;
    addressSize.height = MAX(addressSize.height, kRowMinHeight);
    return addressSize.height;
}

+ (CGSize)caculateSize{
    CGFloat height = 0;
    CGFloat width = 0;
    NSUInteger rowCount = kAddressCount;
    CGFloat firstColumnWidth = 0;
    
    NSString *address = kAddressExample;
    if (address.length > 30) {
        address = [StringUtil formatAddress:address groupSize:kAddressGroupSize lineSize:kAddressLineSize];
    }
    CGSize addressSize = [address sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:[UIFont fontWithName:@"Courier New" size:kAddressFontSize]];
    addressSize.width += kAddressButtonPadding * 2;
    addressSize.height += kAddressButtonPadding * 2 + kRowVerticalPadding * 2;
    addressSize.height = MAX(addressSize.height, kRowMinHeight);
    firstColumnWidth = MAX(addressSize.width, firstColumnWidth);
    height = addressSize.height * rowCount;
    width = firstColumnWidth;
    height = MIN(height, [UIScreen mainScreen].bounds.size.height / 2);
    return CGSizeMake(width, height);
}
@end

@implementation DialogHDColdFirst20AddressesCell

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
    self.frame = CGRectMake(0, 0, exampleAddressSize.width + kAddressButtonPadding * 2, exampleAddressSize.height + kAddressButtonPadding * 2 + kRowVerticalPadding * 2);
    
    self.lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(kAddressButtonPadding, kRowVerticalPadding + kAddressButtonPadding, exampleAddressSize.width, exampleAddressSize.height)];
    self.lblAddress.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    self.lblAddress.textColor = [UIColor whiteColor];
    self.lblAddress.font = [UIFont fontWithName:@"Courier New" size:kAddressFontSize];
    self.lblAddress.backgroundColor = [UIColor clearColor];
    self.lblAddress.numberOfLines = 3;
    
    self.vSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
    self.vSeperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5f];
    self.vSeperator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self addSubview:self.vSeperator];
    [self addSubview:self.lblAddress];
}

- (void)showAddress:(NSString *)address {
    _address = address;
    CGRect frame = self.lblAddress.frame;
    if (address.length > 30) {
        self.lblAddress.text = [StringUtil formatAddress:address groupSize:kAddressGroupSize lineSize:kAddressLineSize];
        frame.size.width = self.frame.size.width - kAddressButtonPadding * 2;
    } else {
        self.lblAddress.text = address;
        frame.size.width = self.frame.size.width;
    }
    self.lblAddress.frame = frame;
}

@end
