//
//  TrashCanCell.m
//  bither-ios
//
//  Created by noname on 14-11-19.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "TrashCanCell.h"
#import "UIBaseUtil.h"
#import "StringUtil.h"
#import "DialogAlert.h"
#import "BTAddressManager.h"
#import "PeerUtil.h"
#import "DialogProgress.h"

@interface TrashCanCell(){
    BTAddress *_address;
}
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@end

@implementation TrashCanCell

- (IBAction)viewOnNetPressed:(id)sender {
    [[[DialogAlert alloc]initWithMessage:NSLocalizedString(@"View on Blockchain.info", nil) confirm:^{
        NSString *url = [NSString stringWithFormat:@"http://blockchain.info/address/%@",self.address.address];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    } cancel:nil] showInWindow:self.window];
}

- (IBAction)restorePressed:(id)sender {
    [[[DialogAlert alloc]initWithMessage:NSLocalizedString(@"trash_address_restore", nil) confirm:^{
        __block DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
        [dp showInWindow:self.window completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [[PeerUtil instance] stopPeer];
                [[BTAddressManager instance] restorePrivKey:self.address];
                [[PeerUtil instance] startPeer];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIViewController* vc = self.getUIViewController;
                    if([vc respondsToSelector:@selector(refresh)]){
                        [vc performSelector:@selector(refresh) withObject:nil];
                    }
                    [dp dismiss];
                });
            });
        }];
    } cancel:nil] showInWindow:self.window];
}

- (IBAction)copyPressed:(id)sender {
    [UIPasteboard generalPasteboard].string = self.address.address;
    UIViewController* vc = self.getUIViewController;
    if([vc respondsToSelector:@selector(showMsg:)]){
        [vc performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"Address copied.", nil) afterDelay:0];
    }
}

- (void)setAddress:(BTAddress *)address{
    _address = address;
    self.lblAddress.text = [StringUtil formatAddress:address.address groupSize:4 lineSize:12];
}

-(BTAddress*)address{
    return _address;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        for (UIView *currentView in self.subviews)
        {
            if([currentView isKindOfClass:[UIScrollView class]])
            {
                ((UIScrollView *)currentView).delaysContentTouches = NO;
                break;
            }
        }
    }
    return self;
}
@end
