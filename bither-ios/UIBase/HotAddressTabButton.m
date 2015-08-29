//
//  HotAddressTabButton.m
//  bither-ios
//
//  Created by noname on 14-7-31.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "HotAddressTabButton.h"
#import "UIColor+Util.h"
#import <Bitheri/BTSettings.h>
#import "BTAddressManager.h"
#import "UnitUtil.h"
#import "DialogTotalBalance.h"
#import "UserDefaultsUtil.h"


#define kHorizontalPadding (5)
#define kLabelLeftGap (-7)
#define kLabelRightGap (1)
#define kFontSize (17)
#define kIconLeftMinus (8)

@interface HotAddressTabButton () <DialogTotalBalanceDismissListener> {
    int64_t _amount;
}
@property(strong) UILabel *lbl;
@property(strong) UIImageView *ivArrow;
@property BOOL isDialogShown;
@end

@implementation HotAddressTabButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(balanceChanged) name:BitherBalanceChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(balanceChanged) name:BTAddressManagerIsReady object:nil];
    self.lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.lbl.font = [UIFont boldSystemFontOfSize:kFontSize];
    self.lbl.textColor = [UIColor whiteColor];
    self.lbl.shadowColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.lbl.shadowOffset = CGSizeMake(0.5, -0.5);
    self.ivArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_arrow_down_unchecked"]];
    self.lbl.numberOfLines = 1;
    self.lbl.text = @"---";
    [self.lbl sizeToFit];
    [self addSubview:self.lbl];
    [self addSubview:self.ivArrow];
    [self configureViews];
    [self balanceChanged];
}

- (void)configureViews {
    BOOL shouldShowBalance = [TotalBalanceHideUtil shouldShowBalance:[UserDefaultsUtil instance].getTotalBalanceHide];
    [self.lbl sizeToFit];
    [self.iv sizeToFit];
    CGFloat lableWidth = self.lbl.frame.size.width;
    if (lableWidth + self.iv.frame.size.width + self.ivArrow.frame.size.width + kLabelLeftGap + kLabelRightGap + kHorizontalPadding * 2 - kIconLeftMinus > self.frame.size.width) {
        lableWidth = self.frame.size.width - (self.iv.frame.size.width + self.ivArrow.frame.size.width + kLabelLeftGap + kLabelRightGap + kHorizontalPadding * 2 - kIconLeftMinus);
    }
    if(!shouldShowBalance){
        lableWidth = 0 - (self.ivArrow.frame.size.width + kLabelLeftGap + kLabelRightGap + kIconLeftMinus / 2);
    }
    CGRect frame = self.iv.frame;
    frame.origin.x = (self.frame.size.width - (self.iv.frame.size.width + self.ivArrow.frame.size.width + kLabelLeftGap + kLabelRightGap + lableWidth - kIconLeftMinus)) / 2 - kIconLeftMinus;
    frame.origin.y = (self.frame.size.height - self.iv.frame.size.height) / 2;
    self.iv.frame = frame;

    self.lbl.hidden = !shouldShowBalance;
    self.ivArrow.hidden = !shouldShowBalance;

    frame = self.lbl.frame;
    frame.origin.x = CGRectGetMaxX(self.iv.frame) + kLabelLeftGap;
    frame.origin.y = 0;
    frame.size.height = self.frame.size.height;
    frame.size.width = lableWidth;
    self.lbl.frame = frame;

    frame = self.ivArrow.frame;
    frame.origin.x = CGRectGetMaxX(self.lbl.frame) + kLabelRightGap;
    frame.origin.y = (self.frame.size.height - self.ivArrow.frame.size.height) / 2;
    self.ivArrow.frame = frame;
    [self configureColor];
    [self configureArrow];
}

- (void)configureColor {
    if (self.selected) {
        self.lbl.textColor = [UIColor whiteColor];
    } else {
        self.lbl.textColor = [UIColor parseColor:0xa2b3c2];
    }
}

- (void)configureArrow {
    if (self.selected) {
        if (self.isDialogShown) {
            self.ivArrow.image = [UIImage imageNamed:@"tab_arrow_up_checked"];
        } else {
            self.ivArrow.image = [UIImage imageNamed:@"tab_arrow_down_checked"];
        }
    } else {
        if (self.isDialogShown) {
            self.ivArrow.image = [UIImage imageNamed:@"tab_arrow_up_unchecked"];
        } else {
            self.ivArrow.image = [UIImage imageNamed:@"tab_arrow_down_unchecked"];
        }
    }
}

- (void)setAmount:(int64_t)amount {
    _amount = amount;
    self.lbl.text = [UnitUtil stringForAmount:amount];
    if ([[UserDefaultsUtil instance] getBitcoinUnit] == UnitBTC) {
        self.imageUnselected = [UIImage imageNamed:@"tab_main"];
        self.imageSelected = [UIImage imageNamed:@"tab_main_checked"];
    } else {
        self.imageUnselected = [UIImage imageNamed:@"tab_main_bits"];
        self.imageSelected = [UIImage imageNamed:@"tab_main_bits_checked"];
    }
    [self configureViews];
}

- (void)buttonPressed:(id)sender {
    if (self.selected) {
        [self showDialog];
    }
    [super buttonPressed:sender];
}

- (void)showDialog {
    if(![TotalBalanceHideUtil shouldShowChart:[UserDefaultsUtil instance].getTotalBalanceHide]){
        return;
    }
    self.isDialogShown = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[BTAddressManager instance] allAddresses];
        dispatch_async(dispatch_get_main_queue(), ^{
            DialogTotalBalance *dialog = [[DialogTotalBalance alloc] init];
            dialog.listener = self;
            [dialog showFromView:self];
            [self configureArrow];
        });


    });
}

- (void)dialogDismissed {
    self.isDialogShown = NO;
    [self configureArrow];
}

- (void)setImageSelected:(UIImage *)imageSelected {
    [super setImageSelected:imageSelected];
    [self configureViews];
}

- (void)setImageUnselected:(UIImage *)imageUnselected {
    [super setImageUnselected:imageUnselected];
    [self configureViews];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self configureViews];
}

- (void)balanceChanged {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *addresses = [BTAddressManager instance].allAddresses;
        int64_t balance = 0;
        for (BTAddress *a in addresses) {
            balance += a.balance;
        }
        if ([BTAddressManager instance].hasHDAccountHot) {
            balance += [BTAddressManager instance].hdAccountHot.balance;
        }
        if ([BTAddressManager instance].hasHDAccountMonitored) {
            balance += [BTAddressManager instance].hdAccountMonitored.balance;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setAmount:balance];
        });
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BTAddressManagerIsReady object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BitherBalanceChangedNotification object:nil];
}

@end
