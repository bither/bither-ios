//
//  DialogImportPrivateKeyAddressValidation.m
//  bither-ios
//
//  Created by 韩珍 on 2017/8/14.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "DialogImportPrivateKeyAddressValidation.h"
#import "StringUtil.h"
#import "NSString+Size.h"

#define kWidth ([UIScreen mainScreen].bounds.size.width * 0.7f)
#define kButtonHeight (30)
#define kMargin (10)
#define kTitleFontSize (16)
#define kFontSize (14)

@interface DialogImportPrivateKeyAddressValidation() {
    BTKey *_compressedKey;
    BTKey *_uncompressedKey;
    CGSize _addressSize;
    CGFloat _titleHeight;
    CGFloat _addressTitleHeight;
}

@property (nonatomic, copy) OnImportEntered onImportEntered;

@end

@implementation DialogImportPrivateKeyAddressValidation

- (instancetype)initWithCompressedKey:(BTKey *)compressedKey uncompressedKey:(BTKey *)uncompressedKey isCompressedKeyRecommended:(BOOL)isCompressedKeyRecommended onImportEntered:(OnImportEntered)onImportEntered {
    NSString *compressedAddressFormat = [StringUtil formatAddress:compressedKey.address groupSize:4 lineSize:16];
    _addressSize = [compressedAddressFormat sizeWithRestrict:CGSizeMake(kWidth, CGFLOAT_MAX) font:[UIFont fontWithName:@"Courier New" size:kFontSize]];
    NSString *title = NSLocalizedString(@"private_key_import_title", nil);
    _titleHeight = [title sizeWithRestrict:CGSizeMake(kWidth, CGFLOAT_MAX) font:[UIFont systemFontOfSize:kTitleFontSize]].height;
    _addressTitleHeight = [NSLocalizedString(@"private_key_uncompressed_address", nil) sizeWithRestrict:CGSizeMake(kWidth, CGFLOAT_MAX) font:[UIFont systemFontOfSize:kTitleFontSize]].height;
    CGFloat height = _titleHeight + kMargin + (_addressTitleHeight + _addressSize.height + kMargin * 2) * 2;
    self = [super initWithFrame:CGRectMake(0, 0, kWidth, height)];
    if (self) {
        self.onImportEntered = [onImportEntered copy];
        _compressedKey = compressedKey;
        _uncompressedKey = uncompressedKey;
        [self configureWithIsCompressedKeyRecommended: isCompressedKeyRecommended];
    }
    return self;
}

- (void)configureWithIsCompressedKeyRecommended:(BOOL)isCompressedKeyRecommended {
    NSString *title = NSLocalizedString(@"private_key_import_title", nil);
    CGSize titleSize = [title sizeWithRestrict:CGSizeMake(kWidth, CGFLOAT_MAX) font:[UIFont systemFontOfSize:kTitleFontSize]];
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kWidth, titleSize.height)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.font = [UIFont systemFontOfSize:kTitleFontSize];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.numberOfLines = 0;
    lblTitle.text = title;
    [self addSubview:lblTitle];
    if (isCompressedKeyRecommended) {
        [self recommendCompressedAddress];
    } else {
        [self recommendUncompressedAddress];
    }
}

- (void)recommendCompressedAddress {
    UILabel *lblCompressedAddressTitle = [self setAddressTitleLabelWithFrame:CGRectMake(0, _titleHeight + kMargin, kWidth, _addressTitleHeight) text:[[NSString alloc] initWithFormat:@"%@%@", NSLocalizedString(@"private_key_compressed_address", nil), NSLocalizedString(@"private_key_recommend", nil)]];
    [self addSubview:lblCompressedAddressTitle];
    
    UILabel *lblCompressedAddress = [self setAddressLabelWithFrame:CGRectMake(0, CGRectGetMaxY(lblCompressedAddressTitle.frame) + kMargin, kWidth, _addressSize.height) address:_compressedKey.address];
    [self addSubview:lblCompressedAddress];
    
    UIButton *btnImportCompressed = [self setImportButtonWithFrame:CGRectMake(_addressSize.width + kMargin, CGRectGetMinY(lblCompressedAddress.frame), kWidth - _addressSize.width - kMargin, kButtonHeight)];
    [btnImportCompressed addTarget:self action:@selector(importCompressedPressed:) forControlEvents: UIControlEventTouchUpInside];
    [self addSubview:btnImportCompressed];
    
    UILabel *lblUncompressedAddressTitle = [self setAddressTitleLabelWithFrame:CGRectMake(0, CGRectGetMaxY(lblCompressedAddress.frame) + kMargin, kWidth, _addressTitleHeight) text:NSLocalizedString(@"private_key_uncompressed_address", nil)];
    [self addSubview:lblUncompressedAddressTitle];
    
    UILabel *lblUncompressedAddress = [self setAddressLabelWithFrame:CGRectMake(0, CGRectGetMaxY(lblUncompressedAddressTitle.frame) + kMargin, kWidth, _addressSize.height) address:_uncompressedKey.address];
    [self addSubview:lblUncompressedAddress];
    
    UIButton *btnImportUncompressed = [self setImportButtonWithFrame:CGRectMake(_addressSize.width + kMargin, CGRectGetMinY(lblUncompressedAddress.frame), kWidth - _addressSize.width - kMargin, kButtonHeight)];
    [btnImportUncompressed addTarget:self action:@selector(importUncompressedPressed:) forControlEvents: UIControlEventTouchUpInside];
    [self addSubview:btnImportUncompressed];
}

- (void)recommendUncompressedAddress {
    UILabel *lblUncompressedAddressTitle = [self setAddressTitleLabelWithFrame:CGRectMake(0, _titleHeight + kMargin, kWidth, _addressTitleHeight) text:[[NSString alloc] initWithFormat:@"%@%@", NSLocalizedString(@"private_key_uncompressed_address", nil), NSLocalizedString(@"private_key_recommend", nil)]];
    [self addSubview:lblUncompressedAddressTitle];
    
    UILabel *lblUncompressedAddress = [self setAddressLabelWithFrame:CGRectMake(0, CGRectGetMaxY(lblUncompressedAddressTitle.frame) + kMargin, kWidth, _addressSize.height) address:_uncompressedKey.address];
    [self addSubview:lblUncompressedAddress];
    
    UIButton *btnImportUncompressed = [self setImportButtonWithFrame:CGRectMake(_addressSize.width + kMargin, CGRectGetMinY(lblUncompressedAddress.frame), kWidth - _addressSize.width - kMargin, kButtonHeight)];
    [btnImportUncompressed addTarget:self action:@selector(importUncompressedPressed:) forControlEvents: UIControlEventTouchUpInside];
    [self addSubview:btnImportUncompressed];
    
    UILabel *lblCompressedAddressTitle = [self setAddressTitleLabelWithFrame:CGRectMake(0, CGRectGetMaxY(lblUncompressedAddress.frame) + kMargin, kWidth, _addressTitleHeight) text:NSLocalizedString(@"private_key_compressed_address", nil)];
    [self addSubview:lblCompressedAddressTitle];
    
    UILabel *lblCompressedAddress = [self setAddressLabelWithFrame:CGRectMake(0, CGRectGetMaxY(lblCompressedAddressTitle.frame) + kMargin, kWidth, _addressSize.height) address:_compressedKey.address];
    [self addSubview:lblCompressedAddress];
    
    UIButton *btnImportCompressed = [self setImportButtonWithFrame:CGRectMake(_addressSize.width + kMargin, CGRectGetMinY(lblCompressedAddress.frame), kWidth - _addressSize.width - kMargin, kButtonHeight)];
    [btnImportCompressed addTarget:self action:@selector(importCompressedPressed:) forControlEvents: UIControlEventTouchUpInside];
    [self addSubview:btnImportCompressed];
}

- (void)importCompressedPressed:(id)sender {
    [self dismissWithCompletion:^{
        self.onImportEntered(_compressedKey);
    }];
}

- (void)importUncompressedPressed:(id)sender {
    [self dismissWithCompletion:^{
        self.onImportEntered(_uncompressedKey);
    }];
}

- (UILabel *)setAddressTitleLabelWithFrame:(CGRect)frame text:(NSString *)text {
    UILabel *lbl = [[UILabel alloc] initWithFrame:frame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.font = [UIFont fontWithName:@"Courier New" size:kFontSize];
    lbl.textColor = [UIColor whiteColor];
    lbl.text = text;
    lbl.numberOfLines = 0;
    return lbl;
}

- (UILabel *)setAddressLabelWithFrame:(CGRect)frame address:(NSString *)address {
    UILabel *lbl = [[UILabel alloc] initWithFrame:frame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.font = [UIFont fontWithName:@"Courier New" size:kFontSize];
    lbl.textColor = [UIColor whiteColor];
    lbl.text = [StringUtil formatAddress:address groupSize:4 lineSize:16];
    lbl.numberOfLines = 0;
    return lbl;
}

- (UIButton *)setImportButtonWithFrame:(CGRect)frame {
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    [btn setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateHighlighted];
    [btn setTitle:NSLocalizedString(@"private_key_import", nil) forState:UIControlStateNormal];
    return btn;
}


@end
