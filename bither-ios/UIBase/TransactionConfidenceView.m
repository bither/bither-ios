//
//  TransactionConfidenceView.m
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

#import <Bitheri/BTAddress.h>
#import "TransactionConfidenceView.h"
#import "DialogTxConfirmation.h"

@interface TransactionConfidenceView ()
@property UIButton *btn;
@property int confirmationCnt;
@property BTTx *tx;
@property BTAddress *address;
@end

@implementation TransactionConfidenceView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.backgroundColor = [UIColor clearColor];
    self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.btn.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.btn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.btn setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.btn addTarget:self action:@selector(pressed:) forControlEvents:UIControlEventTouchUpInside];
    self.btn.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.btn];
}

- (void)showTransaction:(BTTx *)tx withAddress:(BTAddress *)address {
    self.tx = tx;
    self.address = address;
    self.confirmationCnt = tx.confirmationCnt;
    if (tx.confirmationCnt <= 6) {
        [self.btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"transaction_confirmation_icon_%d", tx.confirmationCnt]] forState:UIControlStateNormal];
    } else if (tx.confirmationCnt < 100) {
        [self.btn setImage:[UIImage imageNamed:@"transaction_confirmation_icon_6"] forState:UIControlStateNormal];
    } else {
        [self.btn setImage:[UIImage imageNamed:@"transaction_confirmation_icon_100"] forState:UIControlStateNormal];
    }
}

- (void)pressed:(id)sender {
    DialogTxConfirmation *dialog = [[DialogTxConfirmation alloc] initWithTx:self.tx andAddress:self.address];
    [dialog showFromView:self];
}

@end
