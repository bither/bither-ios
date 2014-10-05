//
//  SignTransactionViewController.m
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

#import "SignTransactionViewController.h"
#import "BitherSetting.h"
#import "StringUtil.h"
#import "DialogProgress.h"
#import <Bitheri/BTAddressManager.h>
#import "UIViewController+PiShowBanner.h"
#import "DialogPassword.h"
#import "QrCodeViewController.h"
#import "BTQRCodeUtil.h"

@interface SignTransactionViewController ()<DialogPasswordDelegate>{
    BTAddress *address;
}
@property (weak, nonatomic) IBOutlet UIView *vTopBar;
@property (weak, nonatomic) IBOutlet UILabel *lblFrom;
@property (weak, nonatomic) IBOutlet UILabel *lblTo;
@property (weak, nonatomic) IBOutlet UILabel *lblAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblFee;
@property (weak, nonatomic) IBOutlet UILabel *lblNoPrivateKey;
@property (weak, nonatomic) IBOutlet UIButton *btnSign;

@end

@implementation SignTransactionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.lblFrom.text = self.tx.myAddress;
    self.lblTo.text = self.tx.toAddress;
    self.lblAmount.attributedText = [StringUtil attributedStringForAmount:self.tx.to withFontSize:14];
    self.lblFee.attributedText = [StringUtil attributedStringForAmount:self.tx.fee withFontSize:14];
    NSArray *privKeys = [BTAddressManager instance].privKeyAddresses;
    address = nil;
    for(BTAddress *a in privKeys){
        if([StringUtil compareString:a.address compare:self.tx.myAddress]){
            address = a;
            break;
        }
    }
    if(address){
        self.btnSign.hidden = NO;
        self.lblNoPrivateKey.hidden = YES;
    }else{
        self.btnSign.hidden = YES;
        self.lblNoPrivateKey.hidden = NO;
    }
}

-(void)onPasswordEntered:(NSString*)password{
    if(!address){
        return;
    }
    __block NSString *bpassword=password;
    password=nil;
    DialogProgress* dp = [[DialogProgress alloc]initWithMessage:NSLocalizedString(@"Signing Transaction", nil)];
    [dp showInWindow:self.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *hashesData = [[NSMutableArray alloc]init];
            for(NSString* h in self.tx.hashList){
                [hashesData addObject:[h hexToData]];
            }
            NSArray *hashes = [address signHashes:hashesData withPassphrase:bpassword];
            NSMutableArray* strHashes = [[NSMutableArray alloc]init];
            for(NSData* hash in hashes){
                [strHashes addObject:[[NSString hexWithData:hash] toUppercaseStringWithEn]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                QrCodeViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"QrCode"];
                controller.content = [BTQRCodeUtil joinedQRCode:strHashes];
                controller.qrCodeMsg = NSLocalizedString(@"Scan with Bither Hot to sign tx", nil);
                controller.qrCodeTitle = NSLocalizedString(@"Signed Transaction", nil);
                [dp dismissWithCompletion:^{
                    [self.navigationController pushViewController:controller animated:YES];
                }];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    UINavigationController *nav = self.navigationController;
                    NSMutableArray* array = [[NSMutableArray alloc]initWithArray:nav.viewControllers];
                    [array removeObject:self];
                    nav.viewControllers = array;
                });
            });
            bpassword=nil;
        });
    }];
}

- (IBAction)signButtonPressed:(id)sender {
    if(!address){
        return;
    }
    [[[DialogPassword alloc]initWithDelegate:self]showInWindow:self.view.window];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
