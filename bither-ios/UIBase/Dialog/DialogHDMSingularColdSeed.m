//
//  DialogHDMSingularColdSeed.m
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
//  Created by songchenwen on 2015/3/16.
//

#import "DialogHDMSingularColdSeed.h"
#import "PiPageViewController.h"
#import "UIBaseUtil.h"
#import "AppDelegate.h"
#import "IOS7ContainerViewController.h"

#define kVerticalPadding (10)
#define kButtonFontSize (15)
#define kButtonPadding (8)
#define kButtonHeight (36)

@interface DialogHDMSingularColdSeed () <PiPageViewControllerDelegate> {
    NSString *qr;
    NSArray *words;
    NSString *warn;
    NSString *button;

    void (^dismissed)();
}
@property(weak) UIViewController *parent;
@property PiPageViewController *page;
@property UISegmentedControl *vTab;
@end

@implementation DialogHDMSingularColdSeed
- (instancetype)initWithWords:(NSArray *)ws qr:(NSString *)q parent:(UIViewController *)parent andDismissAction:(void (^)())d {
    return [self initWithWords:ws qr:q parent:parent warn:nil button:nil andDismissAction:d];
}


- (instancetype)initWithWords:(NSArray *)ws qr:(NSString *)q parent:(UIViewController *)parent warn:(NSString *)w button:(NSString *)b andDismissAction:(void (^)())d {
    self = [super init];
    if (self) {
        self.parent = parent;
        qr = q;
        words = ws;
        dismissed = d;
        warn = w;
        button = b;
    }
    return self;
}

- (void)show {
    [self.parent addChildViewController:self];
    self.view.alpha = 0;
    [self.parent.view addSubview:self.view];
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 1;
    }];
}

- (void)loadView {
    [super loadView];
    self.view.frame = CGRectMake(0, 0, self.parent.view.frame.size.width, self.parent.view.frame.size.height);
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];

    self.vTab = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"hdm_singular_cold_seed_tab_words", nil), NSLocalizedString(@"hdm_singular_cold_seed_tab_qr", nil)]];
    self.vTab.frame = CGRectMake((self.view.frame.size.width - self.vTab.frame.size.width) / 2, (self.view.frame.size.height - self.view.frame.size.width - self.vTab.frame.size.height - 6) / 2, self.vTab.frame.size.width, self.vTab.frame.size.height);
    self.vTab.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.vTab setTintColor:[UIColor whiteColor]];
    [self.vTab setSelectedSegmentIndex:0];
    [self.view addSubview:self.vTab];
    [self.vTab addTarget:self action:@selector(tabChanged:) forControlEvents:UIControlEventValueChanged];
    UIStoryboard *storyboard = nil;
    if (ApplicationDelegate.window.rootViewController.storyboard) {
        storyboard = ApplicationDelegate.window.rootViewController.storyboard;
    } else if ([ApplicationDelegate.window.rootViewController isKindOfClass:[IOS7ContainerViewController class]]) {
        storyboard = ((IOS7ContainerViewController *) ApplicationDelegate.window.rootViewController).controller.storyboard;
    }
    self.page = [[PiPageViewController alloc] initWithStoryboard:storyboard viewControllerIdentifiers:@[@"DialogHDMSingularColdSeedChildWords", @"DialogHDMSingularColdSeedChildQr"] andPageDelegate:self];
    self.page.view.frame = CGRectMake(0, CGRectGetMaxY(self.vTab.frame) + 6, self.view.frame.size.width, self.view.frame.size.width);
    self.page.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addChildViewController:self.page];
    [self.view addSubview:self.page.view];


    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - kButtonHeight - (self.view.frame.size.height - kButtonHeight - CGRectGetMaxY(self.page.view.frame)) / 2, self.view.frame.size.width, kButtonHeight)];
    [btn setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [btn setTitle:button ? button : NSLocalizedString(@"hdm_singular_cold_seed_remember_button", nil) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [UIBaseUtil makeButtonBgResizable:btn];
    [btn sizeToFit];
    btn.frame = CGRectMake((self.view.frame.size.width - btn.frame.size.width - kButtonPadding * 2) / 2, btn.frame.origin.y, btn.frame.size.width + kButtonPadding * 2, kButtonHeight);
    [self.view addSubview:btn];

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CGRectGetMinY(self.vTab.frame))];
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont systemFontOfSize:kButtonFontSize];
    lbl.contentMode = UIViewContentModeCenter;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.numberOfLines = 0;
    lbl.text = warn ? warn : NSLocalizedString(@"hdm_singular_cold_seed_remember_warn", nil);
    [self.view addSubview:lbl];
}

- (void)dismiss:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0;
    }                completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        if (dismissed) {
            dismissed();
        }
    }];
}

- (void)tabChanged:(UISegmentedControl *)control {
    [self.page setIndex:control.selectedSegmentIndex animated:YES];
}

- (void)pageIndexChanged:(int)index {
    [self.vTab setSelectedSegmentIndex:index];
}

- (void)onViewController:(UIViewController *)controller loadedAtIndex:(int)index {
    if ([controller conformsToProtocol:@protocol(DialogHDMSingularColdSeedChildViewController)]) {
        [((UIViewController <DialogHDMSingularColdSeedChildViewController> *) controller) setWords:words andQr:qr];
    }
}
@end