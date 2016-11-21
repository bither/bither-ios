//
//  AdView.m
//  bither-ios
//
//  Created by 韩珍 on 2016/10/25.
//  Copyright © 2016年 Bither. All rights reserved.
//

#import "AdView.h"
#import "BitherApi.h"
#import "UIView+Extension.h"
#import "AdUtil.h"

@interface AdView ()

@property(nonatomic, strong) UIImageView *adImage;
@property (nonatomic, strong) UIButton *adBtn;
@property (nonatomic, strong) NSDictionary *adDic;
@property (nonatomic, strong) UIButton *countDown;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int number;

@end

@implementation AdView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.number = 3;
        self.adDic = [AdUtil getAd];
        [self addSubview:self.adImage];
        [self addSubview:self.adBtn];
        [self addSubview:self.countDown];
        [self setupCountDownTimer];
        [[BitherApi instance] getAdApi];
    }
    return self;
}

- (void)setupCountDownTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setupCountDown) userInfo:nil repeats:YES];
}
    
- (void)setupCountDown {
    self.number--;
    if (self.number == 0) {
        [self remove];
    }
    [self.countDown setAttributedTitle:[self setupCountDownAttribute:self.number] forState:UIControlStateNormal];
}


- (NSMutableAttributedString *)setupCountDownAttribute:(int)number {
    NSString *skipStr = NSLocalizedString(@"ad_skip", nil);
    NSString *countDownStr = [NSString stringWithFormat:@"%d %@", number, skipStr];
    NSMutableAttributedString *countDownAttributedStr = [[NSMutableAttributedString alloc] initWithString:countDownStr];
    NSRange range = NSMakeRange([[countDownAttributedStr string] rangeOfString:[skipStr substringToIndex:1]].location, skipStr.length);
    [countDownAttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, countDownStr.length)];
    [countDownAttributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:range];
    [countDownAttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:range];
    return countDownAttributedStr;
}

- (void)didClickedAdBtn {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_adDic[@"url"]]];
}

- (void)didClickedCountDownBtn {
    [self remove];
}

- (void)remove {
    [self.timer invalidate];
    if (self.done) {
        self.done();
    }
    [self removeFromSuperview];
}

#pragma mark ------ getter

- (UIImageView *)adImage {
    if (!_adImage) {
        _adImage = [[UIImageView alloc] initWithFrame:self.frame];
        _adImage.contentMode = UIViewContentModeScaleAspectFill;
        _adImage.image = [AdUtil getAdImage];
    }
    return _adImage;
}

- (UIButton *)adBtn {
    if (!_adBtn) {
        CGFloat btnWidth = 100;
        CGFloat btnHeight = 38;
        _adBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _adBtn.frame = CGRectMake((self.frame.size.width - btnWidth) / 2.0, self.frame.size.height - btnHeight - 20.0, btnWidth, btnHeight);
        [_adBtn addTarget:self action:@selector(didClickedAdBtn) forControlEvents:UIControlEventTouchUpInside];
        [_adBtn setTitle:NSLocalizedString(@"ad_go", nil) forState:UIControlStateNormal];
        [_adBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _adBtn.titleLabel.font = [UIFont systemFontOfSize:22];
        [_adBtn cornerRadius:8.0 borderColor:[UIColor whiteColor] borderWidth:1.0];
    }
    return _adBtn;
}

- (UIButton *)countDown {
    if (!_countDown) {
        CGFloat btnWidth = 50;
        CGFloat btnHeight = 20;
        _countDown = [UIButton buttonWithType:UIButtonTypeCustom];
        _countDown.frame = CGRectMake(self.frame.size.width-btnWidth-10.0, 30.0, btnWidth, btnHeight);
        [_countDown addTarget:self action:@selector(didClickedCountDownBtn) forControlEvents:UIControlEventTouchUpInside];
        [_countDown setAttributedTitle:[self setupCountDownAttribute:self.number] forState:UIControlStateNormal];
        [_countDown cornerRadius:5.0];
        _countDown.backgroundColor = RGBA(0, 0, 0, 0.5);
    }
    return _countDown;
}

@end
