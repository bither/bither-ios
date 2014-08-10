//
//  HotAddressAddWatchOnlyViewController.m
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

#import "HotAddressAddWatchOnlyViewController.h"
#import "BitherSetting.h"
#import "HotAddressAddViewController.h"
#import <Bitheri/BTAddressManager.h>
#import "ScanQrCodeTransportViewController.h"
#import "DialogProgress.h"
#import "KeyUtil.h"
#import "TransactionsUtil.h"

@interface HotAddressAddWatchOnlyViewController ()<ScanQrCodeDelegate>

@end

@implementation HotAddressAddWatchOnlyViewController

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
}

- (IBAction)scanPressed:(id)sender {
    ScanQrCodeTransportViewController *scan = [[ScanQrCodeTransportViewController alloc]initWithDelegate:self title:NSLocalizedString(@"Scan to watch Bither Cold",nil) pageName:NSLocalizedString(@"Bither Cold Watch Only QR Code", nil)];
    [self presentViewController:scan animated:YES completion:nil];
}

-(void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader{
    [reader dismissViewControllerAnimated:YES completion:^{
        if([self checkQrCodeContent:result]){
            DialogProgress * dp = [[DialogProgress alloc]initWithMessage:NSLocalizedString(@"Please wait…", nil)];
            [dp showInWindow:self.view.window completion:^{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [self processQrCodeContent:result dp:dp];
                    
                });
            }];
        }else{
            [self showMsg:NSLocalizedString(@"Monitor Bither Cold failed.", nil)];
        }
    }];
}

-(void)showMsg:(NSString *)msg{
    if(self.parentViewController.parentViewController && [self.parentViewController.parentViewController isKindOfClass:[HotAddressAddViewController class]]){
        HotAddressAddViewController* parent = (HotAddressAddViewController*)self.parentViewController.parentViewController;
        [parent showMessage:msg];
    }
}
-(void)processQrCodeContent:(NSString*)content dp:(DialogProgress * ) dp{
    NSArray *strs = [content componentsSeparatedByString:QR_CODE_SPLIT];
    NSMutableArray * addressList=[NSMutableArray new];
    for(NSString * pubStr in strs){
        BTKey * key=[BTKey keyWithPublicKey:[pubStr hexToData]];
        [addressList addObject:key.address];
    }
    [TransactionsUtil checkAddress:addressList callback:^(id response) {
        AddressType  addressType=(AddressType)[response integerValue];
        if (addressType==AddressNormal) {
            [KeyUtil addWatckOnly:[strs reverseObjectEnumerator].allObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                [dp dismissWithCompletion:^{
                    [self dismissViewControllerAnimated:YES completion:^{
                    }];
                }];
            });
        }else if(addressType==AddressTxTooMuch){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMsg:NSLocalizedString(@"Cannot import private key with large amount of transactions.", nil)];
                [dp dismiss];
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMsg:NSLocalizedString(@"Cannot import private key with special transactions.", nil)];
                [dp dismiss];
            });
        }
    } andErrorCallback:^(NSError *error) {
        [self showMsg:NSLocalizedString(@"Network failure.", nil)];
        dispatch_async(dispatch_get_main_queue(), ^{
            [dp dismiss];
        });
    }];
  
}

-(BOOL)checkQrCodeContent:(NSString*)content{
    NSArray *strs = [content componentsSeparatedByString:QR_CODE_SPLIT];
    for (NSString* str in strs) {
        if (str.length != 66) {
            return NO;
        }
    }
    return YES;
}
@end
