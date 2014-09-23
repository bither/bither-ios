//
//  QrCodeViewController.m
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

#import "QrCodeViewController.h"
#import "StringUtil.h"
#import "DialogAlert.h"
#import "QRCodeTransportPage.h"
#import "QrUtil.h"

#define kQrCodeTopMarginThreshold (10)

#define kPageFontSize (15)
#define kPageHeight (18)

#define kButtonFontSize (15)
#define kButtonHeight (36)
#define kButtonPadding (10)

@interface QrCodeViewController (){
    __weak NSObject* finishTarget;
    SEL finishSelector;
    NSString *_actionName;
}
@property (weak, nonatomic) IBOutlet UIScrollView *sv;
@property (weak, nonatomic) IBOutlet UILabel *lblMsg;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIView *vTopBar;

@end

@implementation QrCodeViewController

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
    if(![StringUtil isEmpty:self.qrCodeTitle]){
        self.lblTitle.text = self.qrCodeTitle;
    }
    self.lblMsg.text = self.qrCodeMsg;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self configureQrCodes];
}

-(void)configureQrCodes{
    if([StringUtil isEmpty:self.content]){
        return;
    }
    NSArray *strs = [QRCodeTransportPage getQrCodeStringList:self.content];
    CGFloat qrTop = (self.sv.frame.size.height - self.sv.frame.size.width - kButtonHeight - kPageHeight) / 4;
    if(qrTop < kQrCodeTopMarginThreshold){
        qrTop = 0;
    }
    CGFloat margin = (self.sv.frame.size.height - self.sv.frame.size.width - kButtonHeight - kPageHeight - qrTop) / 3;
    margin = MAX(margin, 4);
    CGFloat qrSize = MIN(self.sv.frame.size.width, self.sv.frame.size.height - kButtonHeight - kPageHeight - margin * 3);
    for(int i = 0; i < strs.count; i++){
        UIView *v = [[UIView alloc]initWithFrame:CGRectMake(self.sv.frame.size.width * i, qrTop, self.sv.frame.size.width, self.sv.frame.size.height)];
        v.backgroundColor = [UIColor clearColor];
        
        UIImageView* ivQr = [[UIImageView alloc]initWithFrame:CGRectMake((v.frame.size.width - qrSize)/2, 0, qrSize, qrSize)];
        ivQr.image = [QrUtil qrCodeOfContent:[strs objectAtIndex:i] andSize:ivQr.frame.size.width withTheme:[QrCodeTheme black]];
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(ivQr.frame) + margin, v.frame.size.width, kPageHeight)];
        lbl.font = [UIFont systemFontOfSize:kPageFontSize];
        lbl.textColor = [UIColor darkTextColor];
        lbl.text = [NSString stringWithFormat:NSLocalizedString(@"Page %d, Total %ld", nil), i + 1, strs.count];
        lbl.textAlignment = NSTextAlignmentCenter;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
        if(i < strs.count - 1){
            [btn setTitle:NSLocalizedString(@"Next Page", nil) forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(nextPagePressed:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            if([StringUtil isEmpty:_actionName]){
                [btn setTitle:NSLocalizedString(@"Finish", nil) forState:UIControlStateNormal];
            }else{
                [btn setTitle:_actionName forState:UIControlStateNormal];
            }
            [btn addTarget:self action:@selector(finishPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        [btn sizeToFit];
        btn.frame = CGRectMake((v.frame.size.width - (btn.frame.size.width + kButtonPadding * 2))/2, CGRectGetMaxY(lbl.frame) + margin, btn.frame.size.width + kButtonPadding * 2, kButtonHeight);
        
        [v addSubview:lbl];
        [v addSubview:ivQr];
        [v addSubview:btn];
        [self.sv addSubview:v];
    }
    self.sv.contentSize = CGSizeMake(strs.count * self.sv.frame.size.width, self.sv.frame.size.height);
}

-(void)nextPagePressed:(id)sender{
    int currentPage  = floorf(self.sv.contentOffset.x / self.sv.frame.size.width);
    currentPage = MIN(MAX(0, currentPage), self.sv.contentSize.width / self.sv.frame.size.width - 1);
    CGFloat nextOffsetX = MIN((currentPage + 1) * self.sv.frame.size.width, self.sv.contentSize.width - self.sv.frame.size.width);
    [self.sv setContentOffset:CGPointMake(nextOffsetX, 0) animated:YES];
}

-(void)finishPressed:(id)sender{
    if(finishTarget && finishSelector && [finishTarget respondsToSelector:finishSelector]){
        [finishTarget performSelector:finishSelector];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)setFinishAction:(NSString*)actionName target:(NSObject*)target selector:(SEL)selector{
    finishTarget = target;
    finishSelector = selector;
    _actionName = actionName;
}

- (IBAction)backPressed:(id)sender {
    if([StringUtil isEmpty:self.cancelWarning]){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [[[DialogAlert alloc]initWithMessage:self.cancelWarning confirm:^{
            [self.navigationController popViewControllerAnimated:YES];
        } cancel:nil]showInWindow:self.view.window];
    }
}

@end
