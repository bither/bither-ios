//
//  DialogTxConfirmation.m
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

#import <Bitheri/BTHDMAddress.h>
#import "DialogTxConfirmation.h"
#import "BTIn.h"

#define kFontSize (15)
#define kMaxWidth (280)
#define kVerticalGap (4)
#define kPartSize (24)

@interface DialogTxConfirmation ()
@property BTTx *tx;
@property BTAddress *address;
@property UIActivityIndicatorView *ai;
@property UIImageView *ivHot;
@property UIImageView *ivCold;
@property UIImageView *ivServer;

@property BOOL shouldShowSigningInfo;
@end

@implementation DialogTxConfirmation

- (instancetype)initWithTx:(BTTx *)tx andAddress:(BTAddress *)address {
    int cnt = tx.confirmationCnt;
    NSString *str;
    if (cnt <= 100) {
        str = [NSString stringWithFormat:NSLocalizedString(@"Confirmation: %d", nil), cnt];
    } else {
        str = NSLocalizedString(@"Confirmation: 100+", nil);
    }

    CGSize lblSize = [str boundingRectWithSize:CGSizeMake(kMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kFontSize], NSParagraphStyleAttributeName : [NSParagraphStyle defaultParagraphStyle]} context:nil].size;
    lblSize.height = ceilf(lblSize.height);
    lblSize.width = ceilf(lblSize.width);
    CGSize size = CGSizeMake(lblSize.width, lblSize.height);

    BOOL shouldShowSigningInfo = [DialogTxConfirmation shouldShowSigningInfo:tx andAddress:address];

    if (shouldShowSigningInfo) {
        size.height += kVerticalGap + kPartSize;
        size.width = MAX(size.width, kPartSize * 2);
    }

    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];

    if (self) {
        self.address = address;
        self.tx = tx;
        self.shouldShowSigningInfo = shouldShowSigningInfo;
        self.bgInsets = UIEdgeInsetsMake(8, 12, 8, 12);
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, lblSize.width, lblSize.height)];
        lbl.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        lbl.font = [UIFont systemFontOfSize:kFontSize];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = str;
        [self addSubview:lbl];
        if (self.shouldShowSigningInfo) {
            [self firstConfigure];
        }
    }

    return self;
}

- (void)firstConfigure {
    CGFloat top = self.frame.size.height - kPartSize;
    self.ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.ai.frame = CGRectMake(0, (self.ai.frame.size.height - kPartSize) / 2 + top, self.ai.frame.size.width, self.ai.frame.size.height);
    [self.ai startAnimating];
    [self addSubview:self.ai];

    self.ivHot = [[UIImageView alloc] initWithFrame:CGRectMake(0, top, kPartSize, kPartSize)];
    self.ivHot.image = [UIImage imageNamed:@"hdm_keychain_hot_small"];
    self.ivHot.hidden = YES;
    [self addSubview:self.ivHot];

    self.ivCold = [[UIImageView alloc] initWithFrame:CGRectMake(kPartSize, top, kPartSize, kPartSize)];
    self.ivCold.image = [UIImage imageNamed:@"hdm_keychain_cold_small"];
    self.ivCold.hidden = YES;
    [self addSubview:self.ivCold];

    self.ivServer = [[UIImageView alloc] initWithFrame:CGRectMake(kPartSize * 2, top, kPartSize, kPartSize)];
    self.ivServer.image = [UIImage imageNamed:@"hdm_keychain_server_small"];
    self.ivServer.hidden = YES;
    [self addSubview:self.ivServer];
}

- (void)dialogWillShow {
    if (self.shouldShowSigningInfo) {
        self.ai.hidden = NO;
        self.ivHot.hidden = YES;
        self.ivCold.hidden = YES;
        self.ivServer.hidden = YES;
    }
    [super dialogWillShow];
}

- (void)dialogDidShow {
    [super dialogDidShow];
    if (!self.shouldShowSigningInfo) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        BTHDMAddress *hdm = (BTHDMAddress *) self.address;
        NSArray *signingPubs = [self.tx.ins[0] getP2SHPubKeys];
        BOOL isHot = NO;
        BOOL isCold = NO;
        BOOL isServer = NO;

        for (NSData *pub in signingPubs) {
            if (!isHot && [pub isEqualToData:hdm.pubHot]) {
                isHot = YES;
                continue;
            }
            if (!isCold && [pub isEqualToData:hdm.pubCold]) {
                isCold = YES;
                continue;
            }
            if (!isServer && [pub isEqualToData:hdm.pubRemote]) {
                isServer = YES;
                continue;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.ai.hidden = YES;
            CGFloat left = -1;
            CGRect frame = self.ivHot.frame;
            if (isHot) {
                self.ivHot.hidden = NO;
                frame.origin.x = left;
                self.ivHot.frame = frame;
                left += kPartSize;
            }
            if (isCold) {
                self.ivCold.hidden = NO;
                frame.origin.x = left;
                self.ivCold.frame = frame;
                left += kPartSize;
            }
            if (isServer) {
                self.ivServer.hidden = NO;
                frame.origin.x = left;
                self.ivServer.frame = frame;
            }
        });
    });
}

+ (BOOL)shouldShowSigningInfo:(BTTx *)tx andAddress:(BTAddress *)address {
    return address.isHDM && [tx deltaAmountFrom:address] < 0;
}

@end
