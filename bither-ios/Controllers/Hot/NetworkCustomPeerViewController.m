//
//  NetworkCustomPeerViewController.m
//  bither-ios
//
//  Created by 韩珍珍 on 2022/6/2.
//  Copyright © 2022 Bither. All rights reserved.
//

#import "NetworkCustomPeerViewController.h"
#import "UserDefaultsUtil.h"
#import "DialogNetworkCustomPeerOption.h"
#import "BTPeerManager.h"
#import "UIViewController+PiShowBanner.h"
#import "DialogAlert.h"

@interface NetworkCustomPeerViewController () <DialogNetworkCustomPeerOptionDelegate>

@property (weak, nonatomic) IBOutlet UIView *vNav;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *ivOptionLine;
@property (weak, nonatomic) IBOutlet UIButton *btnOption;
@property (weak, nonatomic) IBOutlet UIView *vCurrentCustomPeer;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentCustomPeerTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentCustomPeer;
@property (weak, nonatomic) IBOutlet UILabel *lblDnsOrIpTitle;
@property (weak, nonatomic) IBOutlet UITextField *tfDnsOrIp;
@property (weak, nonatomic) IBOutlet UILabel *lblPortTitle;
@property (weak, nonatomic) IBOutlet UITextField *tfPort;
@property (weak, nonatomic) IBOutlet UILabel *lblTips;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;

@end

@implementation NetworkCustomPeerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _lblTitle.text = NSLocalizedString(@"network_custom_peer_title", nil);
    _lblDnsOrIpTitle.text = NSLocalizedString(@"network_custom_peer_dns_or_ip", nil);
    _tfDnsOrIp.placeholder = NSLocalizedString(@"network_custom_peer_dns_or_ip_empty", nil);
    _tfDnsOrIp.background = [UIImage imageNamed:@"textfield_activated_holo_light"];
    _lblPortTitle.text = NSLocalizedString(@"network_custom_peer_port", nil);
    _tfPort.placeholder = [NSString stringWithFormat:NSLocalizedString(@"network_custom_peer_port_hint", nil), BITCOIN_STANDARD_PORT];
    _tfPort.background = [UIImage imageNamed:@"textfield_activated_holo_light"];
    _lblTips.text = NSLocalizedString(@"network_custom_peer_tips", nil);
    [self configureTextField:_tfDnsOrIp];
    [self configureTextField:_tfPort];
    [_btnConfirm setTitle:NSLocalizedString(@"OK", nil) forState:normal];
    NSString *customDnsOrIp = [[UserDefaultsUtil instance] getNetworkCustomPeerDnsOrIp];
    if (customDnsOrIp == NULL) {
        return;
    }
    _lblCurrentCustomPeerTitle.text = NSLocalizedString(@"network_custom_peer_used", nil);
    _lblCurrentCustomPeer.text = [NSString stringWithFormat:@"%@:%d", customDnsOrIp, [[UserDefaultsUtil instance] getNetworkCustomPeerPort]];
    [self showCurrentCustomPeer:true];
}

- (IBAction)btnBackClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnOptionClicked:(UIButton *)sender {
    [self hideKeyboard];
    [[[DialogNetworkCustomPeerOption alloc] initWithDelegate:self] showInWindow:self.view.window];
}

- (IBAction)tapGRClicked:(UITapGestureRecognizer *)sender {
    [self.view endEditing:true];
}

- (IBAction)btnConfirmClicked:(UIButton *)sender {
    [self.view endEditing:true];
    NSString *dnsOrIp = _tfDnsOrIp.text;
    if (dnsOrIp == NULL || dnsOrIp.length == 0) {
        [self showMsg:NSLocalizedString(@"network_custom_peer_dns_or_ip_empty", nil)];
        return;
    }
    int16_t port;
    NSString *portStr = _tfPort.text;
    if (portStr == NULL) {
        port = BITCOIN_STANDARD_PORT;
    } else {
        sscanf([portStr UTF8String], "%hu", &port);
    }
    if ([BTPeerManager getPeersFromCustomPeer:dnsOrIp port:port].count == 0) {
        [self showMsg:NSLocalizedString(@"network_custom_peer_failure", nil)];
        return;
    }
    [UserDefaultsUtil.instance setNetworkCustomPeer:dnsOrIp port:port];
    [BTPeerManager.instance setCustomPeerDnsOrIp:dnsOrIp port:port];
    
    __weak __block UIViewController *vc = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[BTPeerManager instance] clearPeerAndRestart];
        dispatch_async(dispatch_get_main_queue(), ^{
            DialogAlert *dialogAlert = [[DialogAlert alloc] initWithConfirmMessage:NSLocalizedString(@"network_custom_peer_success", nil) confirm:^{
                [vc.navigationController popViewControllerAnimated:true];
            }];
            [dialogAlert showInWindow:vc.view.window];
        });
    });
}

- (void)showMsg:(NSString *)msg {
    DialogAlert *dialogAlert = [[DialogAlert alloc] initWithConfirmMessage:msg confirm:^{ }];
    [dialogAlert showInWindow:self.view.window];
}

- (void)showCurrentCustomPeer:(BOOL)isShow {
    [_ivOptionLine setHidden:!isShow];
    [_btnOption setHidden:!isShow];
    [_lblCurrentCustomPeerTitle setHidden:!isShow];
    [_lblCurrentCustomPeer setHidden:!isShow];
    [_vCurrentCustomPeer setHidden:!isShow];
}

- (void)configureTextField:(UITextField *)tf {
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, tf.frame.size.height)];
    leftView.backgroundColor = [UIColor clearColor];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, tf.frame.size.height)];
    rightView.backgroundColor = [UIColor clearColor];
    tf.leftView = leftView;
    tf.rightView = rightView;
    tf.leftViewMode = UITextFieldViewModeAlways;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    if (touch.view != _tfDnsOrIp && touch.view != self.tfPort) {
        [self hideKeyboard];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    if (touch.view != self.tfDnsOrIp && touch.view != self.tfPort) {
        [self hideKeyboard];
    }
}

- (void)hideKeyboard {
    if (self.tfDnsOrIp.isFirstResponder) {
        [self.tfDnsOrIp resignFirstResponder];
    }
    if (self.tfPort.isFirstResponder) {
        [self.tfPort resignFirstResponder];
    }
}

- (void)clearPeer {
    [UserDefaultsUtil.instance removeNetworkCustomPeer];
    [BTPeerManager.instance setCustomPeerDnsOrIp:NULL port:BITCOIN_STANDARD_PORT];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[BTPeerManager instance] clearPeerAndRestart];
    });
    [self showCurrentCustomPeer:false];
}

@end
