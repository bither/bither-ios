//
//  IOS7ContainerViewController.m
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

#import "IOS7ContainerViewController.h"

#define IOS7DeltaTopOffset ([[UIDevice currentDevice].systemVersion floatValue] >= 7 ? 20 : 0)

@implementation UIViewController (IOS7Container)

- (UIView *)rootContainer {
    UIViewController *root = self.view.window.rootViewController;
    if ([root isKindOfClass:[IOS7ContainerViewController class]]) {
        return ((IOS7ContainerViewController *) root).vContainer;
    }
    return self.view.window;
}
@end

@interface IOS7ContainerViewController ()
@end

@implementation IOS7ContainerViewController

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor clearColor];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, IOS7DeltaTopOffset, self.view.frame.size.width, self.view.frame.size.height - IOS7DeltaTopOffset)];
    container.backgroundColor = [UIColor clearColor];
    UIView *statusBarBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, IOS7DeltaTopOffset)];
    statusBarBg.backgroundColor = [UIColor colorWithRed:56.0 / 255.0 green:61.0 / 255.0 blue:64.0 / 255.0 alpha:1];
    [self.view addSubview:statusBarBg];
    [self.view addSubview:container];
    container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.vStatusBarBg = statusBarBg;
    self.vContainer = container;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIViewController *)controller {
    if (self.childViewControllers.count > 0) {
        return [self.childViewControllers objectAtIndex:0];
    }
    return nil;
}

- (void)setController:(UIViewController *)controller {
    [self view];
    for (UIViewController *c in self.childViewControllers) {
        [c.view removeFromSuperview];
        [c removeFromParentViewController];
    }
    [self addChildViewController:controller];
    [self.vContainer addSubview:controller.view];
    controller.view.clipsToBounds = YES;
    controller.view.frame = CGRectMake(0, 0, self.vContainer.frame.size.width, self.vContainer.frame.size.height);
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
