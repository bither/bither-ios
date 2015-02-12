//
//  HotAddressAddViewController.m
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

#import <Bitheri/BTUtils.h>
#import "HotAddressAddViewController.h"
#import "IOS7ContainerViewController.h"
#import "UIViewController+PiShowBanner.h"
#import "PiPageViewController.h"
#import "BTAddressManager.h"
#import "BitherSetting.h"

#define kPrivate (@"HotAddressAddPrivateKey")
#define kMonitor (@"HotAddressAddWatchOnly")
#define kHDM (@"HotAddressAddHDM")

@interface HotAddressAddViewController (){
    BOOL privateKeyLimited;
    BOOL watchOnlyLimited;
    NSMutableArray* pages;
}
@property (strong, nonatomic)PiPageViewController *page;
@property (weak, nonatomic) IBOutlet UIView *vTopBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *vTab;

@end

@interface HotAddressAddViewController (PageViewControllerDelegate)<PiPageViewControllerDelegate>
-(void)configurePage;
@end

@implementation HotAddressAddViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configurePage];
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showMessage:(NSString *)msg{
    [self showBannerWithMessage:msg belowView:self.vTopBar];
}

@end

@implementation HotAddressAddViewController(PageViewControllerDelegate)

-(void)configurePage{
    privateKeyLimited = [BTAddressManager instance].privKeyAddresses.count >= PRIVATE_KEY_OF_HOT_COUNT_LIMIT;
    watchOnlyLimited = [BTAddressManager instance].watchOnlyAddresses.count >= WATCH_ONLY_COUNT_LIMIT;
    pages = [NSMutableArray new];
    if(!privateKeyLimited){
        [pages addObject:kPrivate];
    }
    if(!watchOnlyLimited){
        [pages addObject:kMonitor];
    }
    [pages addObject:kHDM];
    self.page = [[PiPageViewController alloc]initWithStoryboard:self.storyboard andViewControllerIdentifiers:pages];
    self.page.pageDelegate = self;
    [self addChildViewController:self.page];
    self.page.view.frame = CGRectMake(0, CGRectGetMaxY(self.vTopBar.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.vTopBar.frame));
    [self.view insertSubview:self.page.view atIndex:0];
    if(!privateKeyLimited){
        self.vTab.selectedSegmentIndex = 0;
    }else if(!watchOnlyLimited){
        self.vTab.selectedSegmentIndex = 1;
    }else{
        self.vTab.selectedSegmentIndex = 2;
    }
    [self.vTab setEnabled:!privateKeyLimited forSegmentAtIndex:0];
    [self.vTab setEnabled:!watchOnlyLimited forSegmentAtIndex:1];
}

-(void)pageIndexChanged:(int) index{
    NSString *page = pages[index];
    self.vTab.selectedSegmentIndex = [self indexOfPage:page];

}

- (IBAction)tabChanged:(id)sender {
    if(self.vTab.selectedSegmentIndex != [self indexOfPage:pages[self.page.index]]){
        [self.page setIndex:[pages indexOfObject:[self pageForIndex:self.vTab.selectedSegmentIndex]] animated:YES];
    }
}

- (int)indexOfPage:(NSString*)page{
    if([BTUtils compareString:page compare:kHDM]) {
        return 2;
    }else if([BTUtils compareString:page compare:kMonitor]){
        return 1;
    }else{
        return 0;
    }
}

-(NSString*)pageForIndex:(int)index{
    switch (index){
        case 2:
            return kHDM;
        case 1:
            return kMonitor;
        default:
            return kPrivate;
    }
}

@end
