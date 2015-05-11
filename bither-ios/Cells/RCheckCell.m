//
//  RCheckCell.m
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

#import "RCheckCell.h"
#import "DialogAddressFull.h"
#import "StringUtil.h"
#import "NSString+Size.h"

@interface RCheckCell () <DialogAddressFullDelegate> {
    NSString *_address;
}
@property(weak, nonatomic) IBOutlet UILabel *lbl;
@property(weak, nonatomic) IBOutlet UIButton *btnFullAddress;
@property(weak, nonatomic) IBOutlet UIImageView *ivSafe;
@property(weak, nonatomic) IBOutlet UIImageView *ivDanger;
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *vChecking;
@end

@implementation RCheckCell

- (void)showAddress:(NSString *)address checking:(BOOL)checking checked:(BOOL)checked safe:(BOOL)safe {
    _address = address;
    NSString *format = NSLocalizedString(@"rcheck_address_title", nil);
    if (!safe) {
        format = NSLocalizedString(@"rcheck_address_danger_title", nil);
    }
    self.lbl.text = [NSString stringWithFormat:format, [StringUtil shortenAddress:address]];
    CGFloat width = [self.lbl.text sizeWithRestrict:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:self.lbl.font].width;
    CGRect frame = self.lbl.frame;
    frame.size.width = width;
    self.lbl.frame = frame;
    frame = self.btnFullAddress.frame;
    frame.origin.x = CGRectGetMaxX(self.lbl.frame) + 5;
    self.btnFullAddress.frame = frame;
    if (checking) {
        self.vChecking.hidden = NO;
        self.ivSafe.hidden = YES;
        self.ivDanger.hidden = YES;
        [self.vChecking startAnimating];
    } else {
        self.vChecking.hidden = YES;
        [self.vChecking stopAnimating];
        if (checked) {
            self.ivSafe.hidden = !safe;
            self.ivDanger.hidden = safe;
        } else {
            self.ivSafe.hidden = YES;
            self.ivDanger.hidden = YES;
        }
    }
}

- (IBAction)fullAddressPressed:(id)sender {
    [[[DialogAddressFull alloc] initWithDelegate:self] showFromView:sender];
}

- (NSUInteger)dialogAddressFullRowCount {
    return 1;
}

- (NSString *)dialogAddressFullAddressForRow:(NSUInteger)row {
    return _address;
}

- (int64_t)dialogAddressFullAmountForRow:(NSUInteger)row {
    return 0;
}

- (BOOL)dialogAddressFullDoubleColumn {
    return NO;
}

- (void)showMsg:(NSString *)msg {

}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsZero;
}

@end
