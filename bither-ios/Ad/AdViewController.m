//
//  AdViewController.m
//  bither-ios
//
//  Created by 韩珍 on 2016/10/25.
//  Copyright © 2016年 Bither. All rights reserved.
//

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

#import "AdViewController.h"

@interface AdViewController ()

@property(nonatomic, strong) UIImageView *adImage;
@property (nonatomic, strong) UIButton *adBtn;

@end

@implementation AdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.adImage];
    [self.view addSubview:self.adBtn];
}

- (void)didClickedAdBtn {
    
}

- (UIImageView *)adImage {
    if (!_adImage) {
        _adImage = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _adImage.image = [UIImage imageNamed:@"add_address_button_icon"];
    }
    return _adImage;
}

- (UIButton *)adBtn {
    if (!_adBtn) {
        CGFloat btnWidth = 100;
        CGFloat btnHeight = 30;
        _adBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _adBtn.frame = CGRectMake((kScreenWidth - btnWidth) / 2.0, kScreenHeight - btnHeight - 20.0, btnWidth, btnHeight);
        [_adBtn addTarget:self action:@selector(didClickedAdBtn) forControlEvents:UIControlEventTouchUpInside];
        [_adBtn setTitle:@"前往" forState:UIControlStateNormal];
    }
    return _adBtn;
}


@end
