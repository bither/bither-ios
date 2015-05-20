//
//  DialogKeychainBackupDiff.m
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

#import "DialogKeychainBackupDiff.h"
#import "StringUtil.h"
#import "KeychainBackupUtil.h"
#import "NSString+Size.h"
#import "UIBaseUtil.h"

@interface DialogKeychainBackupDiff () <UITableViewDataSource, UITableViewDelegate> {
    CGFloat warnHeight;
}
@property UITableView *table;
@end

#define kAddressFontSize (16)
#define kAddressButtonPadding (0)
#define kAmountFontSize (10)
#define kRowVerticalPadding (5)
#define kRowMinHeight (36)
#define kColumnMargin (16)

#define kAddressGroupSize (4)
#define kAddressLineSize (12)
#define kAddressExample (@"1BsTwoMaX3aYx9Nc8GdgHZzzAGmG669bC3")

#define kTopAreaHeight (50)
#define kBottomButtonMargin (10)
#define kBottomButtonHeight (36)

@interface BackupDiffCell : UITableViewCell {
    NSString *_address;
}
@property UILabel *lblAddress;
@property UILabel *lblAmount;
@property UIView *vSeperator;

- (void)showDiff:(NSArray *)diff;

+ (NSString *)addressFromDiff:(NSArray *)diff;

+ (NSString *)typeStringFromDiff:(NSArray *)diff;
@end

@implementation DialogKeychainBackupDiff

- (instancetype)initWithDiffs:(NSArray *)diffs andDelegate:(NSObject <DialogKeychainBackupDiffDelegate> *)delegate {
    NSString *warn = NSLocalizedString(@"keychain_backup_diff_warn", nil);
    CGSize sizeWarn = [warn sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:[UIFont systemFontOfSize:15]];
    sizeWarn.width = ceil(sizeWarn.width);
    sizeWarn.height = ceil(sizeWarn.height);
    CGSize size = [DialogKeychainBackupDiff caculateSize:diffs];
    size.width = MAX(sizeWarn.width, size.width);
    if (sizeWarn.height > kTopAreaHeight) {
        size.height = size.height - kTopAreaHeight + sizeWarn.height;
    }
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height + kTopAreaHeight + kBottomButtonMargin + kBottomButtonHeight)];
    if (self) {
        self.diffs = diffs;
        self.delegate = delegate;
        warnHeight = MAX(sizeWarn.height, kTopAreaHeight);
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.bgInsets = UIEdgeInsetsMake(8, 16, 8, 16);
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, warnHeight, self.frame.size.width, self.frame.size.height - (warnHeight + kBottomButtonMargin + kBottomButtonHeight)) style:UITableViewStylePlain];
    self.table.backgroundColor = [UIColor clearColor];
    [self.table registerClass:[BackupDiffCell class] forCellReuseIdentifier:@"Cell"];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:self.table];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, warnHeight)];
    lbl.font = [UIFont systemFontOfSize:15];
    lbl.textColor = [UIColor whiteColor];
    lbl.contentMode = UIViewContentModeCenter;
    lbl.numberOfLines = 0;
    lbl.text = NSLocalizedString(@"keychain_backup_diff_warn", nil);
    [self addSubview:lbl];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, self.frame.size.height - kBottomButtonHeight, (self.frame.size.width - kBottomButtonMargin) / 2, kBottomButtonHeight);
    [btn setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
    [UIBaseUtil makeButtonBgResizable:btn];
    btn.titleLabel.textColor = [UIColor whiteColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitle:NSLocalizedString(@"keychain_backup_diff_warn_no", nil) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(noPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];

    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((self.frame.size.width - kBottomButtonMargin) / 2 + kBottomButtonMargin, self.frame.size.height - kBottomButtonHeight, (self.frame.size.width - kBottomButtonMargin) / 2, kBottomButtonHeight);
    [btn setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
    [UIBaseUtil makeButtonBgResizable:btn];
    btn.titleLabel.textColor = [UIColor whiteColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitle:NSLocalizedString(@"keychain_backup_diff_warn_yes", nil) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(yesPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
}

- (void)yesPressed:(id)sender {
    [self dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onAccept)]) {
            [self.delegate onAccept];
        }
    }];
}

- (void)noPressed:(id)sender {
    [self dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onAccept)]) {
            [self.delegate onDeny];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.diffs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BackupDiffCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell showDiff:self.diffs[indexPath.row]];
    cell.vSeperator.hidden = indexPath.row == self.diffs.count - 1;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *address = [BackupDiffCell addressFromDiff:self.diffs[indexPath.row]];
    address = [StringUtil formatAddress:address groupSize:kAddressGroupSize lineSize:kAddressLineSize];
    CGSize addressSize = [address sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:[UIFont fontWithName:@"Courier New" size:kAddressFontSize]];
    addressSize.height += kAddressButtonPadding * 2 + kRowVerticalPadding * 2;
    addressSize.height = MAX(addressSize.height, kRowMinHeight);
    return addressSize.height;
}

+ (CGSize)caculateSize:(NSArray *)diffs {
    CGFloat height = 0;
    CGFloat width = 0;
    NSUInteger rowCount = diffs.count;
    CGFloat firstColumnWidth = 0;
    CGFloat secondColumnWidth = 0;
    for (NSUInteger i = 0; i < rowCount; i++) {
        NSString *address = [BackupDiffCell addressFromDiff:diffs[i]];
        address = [StringUtil formatAddress:address groupSize:kAddressGroupSize lineSize:kAddressLineSize];
        CGSize addressSize = [address sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:[UIFont fontWithName:@"Courier New" size:kAddressFontSize]];
        addressSize.width += kAddressButtonPadding * 2;
        addressSize.height += kAddressButtonPadding * 2 + kRowVerticalPadding * 2;
        addressSize.height = MAX(addressSize.height, kRowMinHeight);
        height += addressSize.height;
        firstColumnWidth = MAX(addressSize.width, firstColumnWidth);

        NSString *type = [BackupDiffCell typeStringFromDiff:diffs[i]];
        CGSize typeSize = [type sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, addressSize.height) font:[UIFont systemFontOfSize:kAmountFontSize]];
        secondColumnWidth = MAX(secondColumnWidth, typeSize.width);
    }
    width = firstColumnWidth + kColumnMargin + secondColumnWidth;
    height = MIN(height, [UIScreen mainScreen].bounds.size.height / 2);
    return CGSizeMake(width, height);
}

@end


@implementation BackupDiffCell

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
    [self addSubview:self.lblAddress];
}

- (void)showDiff:(NSArray *)diff {
    _address = [BackupDiffCell addressFromDiff:diff];
    NSString *typeStr = [BackupDiffCell typeStringFromDiff:diff];
    CGRect frame = self.lblAddress.frame;
    self.lblAddress.text = [StringUtil formatAddress:_address groupSize:kAddressGroupSize lineSize:kAddressLineSize];
    self.lblAddress.frame = frame;
    self.lblAmount.text = typeStr;
}

+ (NSString *)typeStringFromDiff:(NSArray *)diff {
    NSNumber *typeNum = diff[1];
    BackupChangeType type = typeNum.intValue;
    return [BackupDiffCell strForType:type];
}

+ (NSString *)addressFromDiff:(NSArray *)diff {
    //TODO get address from this pubkey
    return diff[0];
}

+ (NSString *)strForType:(BackupChangeType)type {
    switch (type) {
        case AddFromKeychain:
            return NSLocalizedString(@"keychain_backup_add_from_keychain", nil);
        case AddFromLocal:
            return NSLocalizedString(@"keychain_backup_add_from_local", nil);
        case TrashFromKeychain:
            return NSLocalizedString(@"keychain_backup_trash_from_keychain", nil);
        case TrashFromLocal:
            return NSLocalizedString(@"keychain_backup_trash_from_local", nil);
        default:
            return nil;
    }
}

@end
