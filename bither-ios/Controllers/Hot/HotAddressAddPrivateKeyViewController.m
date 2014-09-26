//
//  HotAddressAddPrivateKeyViewController.m
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

#import "HotAddressAddPrivateKeyViewController.h"
#import "BitherSetting.h"
#import "DialogProgress.h"
#import "DialogPassword.h"
#import "DialogAlert.h"
#import "UEntropyViewController.h"
#import <Bitheri/BTAddressManager.h>
#import "KeyUtil.h"

@interface HotAddressAddPrivateKeyViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *pvCount;
@property (weak, nonatomic) IBOutlet UIButton *btnXRandomCheck;
@property int countToGenerate;
@end

@interface HotAddressAddPrivateKeyViewController (DialogPassword)<DialogPasswordDelegate>
@end

@interface HotAddressAddPrivateKeyViewController(UIPickerViewDataSource)<UIPickerViewDataSource,UIPickerViewDelegate>
@end

@implementation HotAddressAddPrivateKeyViewController
-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
        self.limit=PRIVATE_KEY_OF_HOT_COUNT_LIMIT;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.limit=PRIVATE_KEY_OF_HOT_COUNT_LIMIT;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.countToGenerate = 1;
    self.pvCount.delegate = self;
    self.pvCount.dataSource = self;
}

- (IBAction)generatePressed:(id)sender {
    DialogPassword *d = [[DialogPassword alloc]initWithDelegate:self];
    [d showInWindow:self.view.window];
}

- (IBAction)xrandomCheckPressed:(id)sender{
    if(!self.btnXRandomCheck.selected){
        self.btnXRandomCheck.selected = YES;
    }else{
        DialogAlert *alert = [[DialogAlert alloc]initWithMessage:NSLocalizedString(@"XRandom increases randomness.\nSure to disable?", nil) confirm:^{
            self.btnXRandomCheck.selected = NO;
        } cancel:nil];
        [alert showInWindow:self.view.window];
    }
}

@end

@implementation HotAddressAddPrivateKeyViewController(DialogPassword)

-(void)onPasswordEntered:(NSString *)password{
    if(self.btnXRandomCheck.selected){
        UEntropyViewController* uentropy = [[UEntropyViewController alloc]initWithCount:self.countToGenerate password:password];
        [self presentViewController:uentropy animated:YES completion:nil];
    }else{
        DialogProgress *d = [[DialogProgress alloc]initWithMessage:NSLocalizedString(@"Please wait…", nil)];
        d.touchOutSideToDismiss = NO;
        [d showInWindow:self.view.window];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            [KeyUtil addPrivateKeyByRandomWithPassphras:password count:self.countToGenerate];
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [d dismissWithCompletion:^{
                    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
                }];
            });
        });
    }
}

@end

@implementation HotAddressAddPrivateKeyViewController(UIPickerViewDataSource)

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSUInteger preCount =[BTAddressManager instance].privKeyAddresses.count;
    return self.limit - preCount;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%ld", row + 1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.countToGenerate = (int)(row + 1);
}

@end