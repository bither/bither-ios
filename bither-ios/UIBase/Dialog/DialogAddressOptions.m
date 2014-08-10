//
//  DialogAddressOptions.m
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

#import "DialogAddressOptions.h"
#import "NSString+Size.h"

#define kButtonHeight (44)
#define kButtonEdgeInsets (UIEdgeInsetsMake(0, 10, 0, 10))

#define kHeight (kButtonHeight * 3 + 2)

#define kFontSize (16)

@interface DialogAddressOptions(){
    NSString *_viewOnBlockChainInfoStr;
}
@end

@implementation DialogAddressOptions

-(instancetype)initWithAddress:(BTAddress*)address andDelegate:(NSObject<DialogAddressOptionsDelegate>*)delegate{
    NSString* viewStr = NSLocalizedString(@"View on Blockchain.info", nil);
    self = [super initWithFrame:CGRectMake(0, 0, [viewStr sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, kButtonHeight) font:[UIFont systemFontOfSize:kFontSize]].width + kButtonEdgeInsets.left + kButtonEdgeInsets.right, kHeight)];
    if(self){
        _viewOnBlockChainInfoStr  = viewStr;
        self.delegate = delegate;
        [self firstConfigureHasPrivateKey:address.hasPrivKey];
    }
    return self;
}

-(void)firstConfigureHasPrivateKey:(BOOL)hasPrivateKey{
    self.bgInsets = UIEdgeInsetsMake(4, 16, 4, 16);
    CGFloat bottom = 0;
    bottom = [self createButtonWithText:_viewOnBlockChainInfoStr top:bottom action:@selector(viewOnBlockChainInfoPressed:)];
    UIView *seperator = [[UIView alloc]initWithFrame:CGRectMake(0, bottom, self.frame.size.width, 1)];
    seperator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    seperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self addSubview:seperator];
    bottom += 1;
    if(hasPrivateKey){
      //  bottom = [self createButtonWithText:NSLocalizedString(@"Private Key QR Code", nil) top:bottom action:@selector(privateKeyQrCodePressed:)];
    }else{
        bottom = [self createButtonWithText:NSLocalizedString(@"Stop Monitoring", nil) top:bottom action:@selector(stopMonitorPressed:)];
        seperator = [[UIView alloc]initWithFrame:CGRectMake(0, bottom, self.frame.size.width, 1)];
        seperator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        seperator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self addSubview:seperator];
        bottom += 1;
    }
   
    bottom = [self createButtonWithText:NSLocalizedString(@"Cancel", nil) top:bottom action:@selector(cancelPressed:)];
    CGRect frame = self.frame;
    frame.size.height = bottom;
    self.frame = frame;
}

-(CGFloat)createButtonWithText:(NSString*)text top:(CGFloat)top action:(SEL)selector{
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, top, self.frame.size.width, kButtonHeight)];
    [btn setBackgroundImage:nil forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"card_foreground_pressed"] forState:UIControlStateHighlighted];
    btn.contentEdgeInsets = kButtonEdgeInsets;
    btn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateHighlighted];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    return CGRectGetMaxY(btn.frame);
}

-(void)viewOnBlockChainInfoPressed:(id)sender{
    [self dismissWithCompletion:^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(showAddressOnBlockChainInfo)]){
            [self.delegate showAddressOnBlockChainInfo];
        }
    }];
}

-(void)stopMonitorPressed:(id)sender{
    [self dismissWithCompletion:^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(stopMonitorAddress)]){
            [self.delegate stopMonitorAddress];
        }
    }];
}

-(void)privateKeyQrCodePressed:(id)sender{
    [self dismissWithCompletion:^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(showPrivateKeyQrCode)]){
            [self.delegate showPrivateKeyQrCode];
        }
    }];
}

-(void)cancelPressed:(id)sender{
    [self dismiss];
}

@end
