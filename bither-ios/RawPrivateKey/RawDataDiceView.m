//
//  RawDataDiceView.m
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
//  Created by songchenwen on 2015/3/21.
//

#import "RawDataDiceView.h"
#import "NSString+Base58.h"
#import <openssl/bn.h>

#define kDiceBorderWidthRate (0.07f)

@interface RawDataDiceView () {
    NSUInteger restrictedWidth;
    NSUInteger restrictedHeight;
    NSUInteger column;
    NSUInteger row;
    NSMutableString *data;
}

@end

@implementation RawDataDiceView

- (void)addData:(NSUInteger)d {
    if (self.filledDataLength < self.dataLength) {
        if (d > 5) {
            [NSException raise:@"RawDataDiceView not accepted dice value" format:@"RawDataDiceView not accepted dice value %d", d];
        }
        NSUInteger index = data.length;
        [data appendFormat:@"%d", d];
        UIView *v = ((UIView *) ((UIView *) self.subviews[1]).subviews[index]).subviews[0];
        UIImageView *iv = (UIImageView *) v.subviews[1];
        [v.layer removeAllAnimations];
        iv.image = [UIImage imageNamed:[NSString stringWithFormat:@"dice_large_%d", d + 1]];
        CGPoint center = CGPointMake(CGRectGetMidX(v.frame), CGRectGetMidY(v.frame));
        v.layer.anchorPoint = CGPointMake(0.5, 0.5);
        v.layer.position = center;
        v.transform = CGAffineTransformMakeScale(0, 0);
        v.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            v.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)deleteLast {
    NSUInteger size = self.filledDataLength;
    if (size <= 0) {
        return;
    }
    [data deleteCharactersInRange:NSMakeRange(size - 1, 1)];
    UIView *v = ((UIView *) ((UIView *) self.subviews[1]).subviews[size - 1]).subviews[0];
    [UIView animateWithDuration:0.5 animations:^{
        v.transform = CGAffineTransformMakeScale(0.01, 0.01);
    }                completion:^(BOOL finished) {
        if (finished) {
            v.hidden = YES;
        }
    }];
}

- (void)removeAllData {
    NSUInteger size = self.filledDataLength;
    if (size <= 0) {
        return;
    }
    data = [NSMutableString stringWithCapacity:self.dataLength];
    for (NSUInteger i = 0; i < size; i++) {
        UIView *v = ((UIView *) ((UIView *) self.subviews[1]).subviews[i]).subviews[0];
        CGPoint center = CGPointMake(CGRectGetMidX(v.frame), CGRectGetMidY(v.frame));
        v.layer.anchorPoint = CGPointMake(0.5, 0.5);
        v.layer.position = center;
        [UIView animateWithDuration:0.5 animations:^{
            v.transform = CGAffineTransformMakeScale(0.01, 0.01);
        }                completion:^(BOOL finished) {
            if (finished) {
                v.hidden = YES;
            }
        }];
    }
}

- (NSMutableData *)data {
    if (self.filledDataLength < self.dataLength) {
        return nil;
    }
    NSData *PN = [@"fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141" hexToData];
    NSMutableData *d = [NSMutableData dataWithCapacity:33];

    BN_CTX *ctx = BN_CTX_new();
    BIGNUM num, base, digit, prev;
    BIGNUM *n = BN_bin2bn(PN.bytes, 32, NULL);
    BN_CTX_start(ctx);
    BN_init(&num);
    BN_init(&base);
    BN_init(&digit);
    BN_init(&prev);
    BN_set_word(&base, 6);
    BN_zero(&num);

    for (NSUInteger i = 0; i < data.length; i++) {
        BN_set_word(&digit, [data characterAtIndex:i] - '0');
        BN_mul(&prev, &num, &base, ctx);
        BN_add(&num, &prev, &digit);
    }
    BN_mod(&num, &num, n, ctx);

    d.length += BN_num_bytes(&num);
    BN_bn2bin(&num, (unsigned char *) d.mutableBytes + d.length - BN_num_bytes(&num));

    BN_clear_free(&num);
    BN_clear_free(&prev);
    BN_free(&base);
    BN_free(&digit);
    BN_free(n);
    BN_CTX_end(ctx);
    BN_CTX_free(ctx);
    return d;
}

- (void)organizeView {
    if (restrictedWidth <= 0 || restrictedHeight <= 0 || row <= 0 || column <= 0) {
        return;
    }
    for (NSInteger i = self.subviews.count - 1; i >= 0; i--) {
        [self.subviews[i] removeFromSuperview];
    }
    [self configureSize];

    UIImageView *ivBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    ivBg.image = [UIImage imageNamed:@"border_bottom_right"];
    ivBg.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:ivBg];

    UIView *vContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 1, self.frame.size.height - 1)];
    vContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:vContainer];

    CGFloat width = (self.frame.size.width - 1) / column;
    CGFloat height = (self.frame.size.height - 1) / row;
    CGFloat border = (MIN(width, height) - 1.0f) * kDiceBorderWidthRate;
    for (NSInteger y = 0; y < row; y++) {
        for (NSInteger x = 0; x < column; x++) {
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(x * width, y * height, width, height)];
            v.backgroundColor = [UIColor clearColor];
            ivBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
            ivBg.image = [UIImage imageNamed:@"border_top_left"];
            ivBg.contentMode = UIViewContentModeScaleToFill;
            UIView *inner = [[UIView alloc] initWithFrame:CGRectMake(1, 1, width - 1, height - 1)];
            inner.backgroundColor = [UIColor clearColor];
            UIImageView *ivF = [[UIImageView alloc] initWithFrame:CGRectMake(border, border, width - 1.0 - border * 2.0, height - 1.0 - border * 2.0)];
            UIImageView *ivB = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width - 1, height - 1)];
            [ivB setImage:[UIImage imageNamed:@"btn_keyboard_key_white_normal"]];
            inner.hidden = YES;
            [inner addSubview:ivB];
            [inner addSubview:ivF];
            [v addSubview:inner];
            [v addSubview:ivBg];
            [vContainer addSubview:v];
        }
    }
}

- (void)configureSize {
    NSUInteger width = restrictedWidth - 1;
    NSUInteger height = restrictedHeight - 1;
    width = width - width % column + 1;
    height = height - height % row + 1;
    self.frame = CGRectMake(self.frame.origin.x - (width - self.frame.size.width) / 2, self.frame.origin.y, width, height);
}

- (void)setRestrictedSize:(CGSize)restrictedSize {
    restrictedWidth = floorf(restrictedSize.width);
    restrictedHeight = floorf(restrictedSize.height);
    [self organizeView];
}

- (CGSize)restrictedSize {
    return CGSizeMake(restrictedWidth, restrictedHeight);
}

- (void)setDataSize:(CGSize)dataSize {
    column = floorf(dataSize.width);
    row = floorf(dataSize.height);
    data = [[NSMutableString alloc] initWithCapacity:column * row];
    [self organizeView];
}

- (CGSize)dataSize {
    return CGSizeMake(column, row);
}

- (NSUInteger)dataLength {
    return column * row;
}

- (NSUInteger)filledDataLength {
    return data.length;
}
@end