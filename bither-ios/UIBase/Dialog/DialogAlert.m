//  DialogAlert.m
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


#import "DialogAlert.h"
#import "NSString+Size.h"
#import "NSAttributedString+Size.h"

#define kDialogAlertLabelMaxWidth 280
#define kDialogAlertLabelMaxHeight 200
#define kDialogAlertButtonFontSize 14
#define kDialogAlertMargin 5
#define kDialogAlertMinHeight 50
#define kDialogAlertHorizotalPadding 2
#define kDialogAlertVerticalPadding 2
#define kDialogAlertBtnWidthMin 80
#define kDialogAlertBtnHeightMin 36
#define kDialogAlertBtnDistance 10
#define kDialogAlertLabelAndBtnDistance 14

@interface DialogAlert () {

}
@property(strong, nonatomic) UILabel *lbl;
@property(strong, nonatomic) UIButton *btnConfirm;
@property(strong, nonatomic) UIButton *btnCancel;
@property(strong, nonatomic) void(^confirm)();
@property(strong, nonatomic) void(^cancel)();
@end

@implementation DialogAlert


- (id)initWithAttributedMessage:(NSAttributedString *)message confirm:(void (^)())confirm cancel:(void (^)())cancel {
    self = [self initWithMessage:nil orAttributedString:message confirm:confirm cancel:cancel];
    return self;
}

- (id)initWithMessage:(NSString *)message confirm:(void (^)())confirm cancel:(void (^)())cancel {
    self = [self initWithMessage:message orAttributedString:nil confirm:confirm cancel:cancel];
    return self;
}

- (id)initWithMessage:(NSString *)message orAttributedString:(NSAttributedString *)attributedStr confirm:(void (^)())confirm cancel:(void (^)())cancel {
    self = [super init];
    if (self) {
        CGSize constrainedSize = CGSizeMake(kDialogAlertLabelMaxWidth, kDialogAlertLabelMaxHeight);
        CGSize lableSize = CGSizeZero;
        if (attributedStr) {
            lableSize = [attributedStr sizeWithRestrict:constrainedSize];
        } else {
            lableSize = [message sizeWithRestrict:constrainedSize font:[UIFont systemFontOfSize:kDialogAlertLabelFontSize]];
        }
        float minWidth = kDialogAlertHorizotalPadding * 2 + kDialogAlertBtnWidthMin * 2 + kDialogAlertBtnDistance;
        float width = fmaxf(minWidth, lableSize.width + kDialogAlertHorizotalPadding * 2);
        self.frame = CGRectMake(0, 0, width, lableSize.height + kDialogAlertVerticalPadding * 2 + kDialogAlertLabelAndBtnDistance + kDialogAlertBtnHeightMin);
        self.lbl = [[UILabel alloc] initWithFrame:CGRectMake(kDialogAlertHorizotalPadding, kDialogAlertVerticalPadding, self.frame.size.width - 2 * kDialogAlertHorizotalPadding, lableSize.height)];

        self.lbl.backgroundColor = [UIColor clearColor];
        self.lbl.font = [UIFont systemFontOfSize:kDialogAlertLabelFontSize];
        self.lbl.numberOfLines = 0;
        self.lbl.textColor = [UIColor whiteColor];
        self.lbl.textAlignment = NSTextAlignmentLeft;
        if (attributedStr) {
            self.lbl.attributedText = attributedStr;
        } else {
            self.lbl.text = message;
        }

        UIImage *imageNormal = [UIImage imageNamed:@"dialog_btn_bg_normal"];
        imageNormal = [imageNormal resizableImageWithCapInsets:UIEdgeInsetsMake(imageNormal.size.height / 2, imageNormal.size.width / 2, imageNormal.size.height / 2, imageNormal.size.width / 2)];

        float btnWidth = (self.frame.size.width - kDialogAlertHorizotalPadding * 2 - kDialogAlertBtnDistance) / 2;

        self.btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(kDialogAlertHorizotalPadding, kDialogAlertVerticalPadding + self.lbl.frame.size.height + kDialogAlertLabelAndBtnDistance, btnWidth, kDialogAlertBtnHeightMin)];
        [self.btnCancel setBackgroundImage:imageNormal forState:UIControlStateNormal];
        [self.btnCancel setTitle:NSLocalizedString(@"Cancel", @"dialogAlertCancel") forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        self.btnCancel.adjustsImageWhenDisabled = YES;
        self.btnCancel.adjustsImageWhenHighlighted = YES;
        self.btnCancel.titleLabel.font = [UIFont boldSystemFontOfSize:kDialogAlertButtonFontSize];
        [self.btnCancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];

        self.btnConfirm = [[UIButton alloc] initWithFrame:CGRectMake(self.btnCancel.frame.origin.x + kDialogAlertBtnDistance + self.btnCancel.frame.size.width, self.btnCancel.frame.origin.y, btnWidth, kDialogAlertBtnHeightMin)];

        [self.btnConfirm setBackgroundImage:imageNormal forState:UIControlStateNormal];
        [self.btnConfirm setTitle:NSLocalizedString(@"OK", @"dialogAlertConfirm") forState:UIControlStateNormal];
        [self.btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        self.btnConfirm.adjustsImageWhenDisabled = YES;
        self.btnConfirm.adjustsImageWhenHighlighted = YES;
        self.btnConfirm.titleLabel.font = [UIFont boldSystemFontOfSize:kDialogAlertButtonFontSize];
        [self.btnConfirm addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];


        [self addSubview:self.btnConfirm];
        [self addSubview:self.btnCancel];
        [self addSubview:self.lbl];
        self.confirm = confirm;
        self.cancel = cancel;
    }
    return self;
}

- (void)confirm:(id)sender {
    [self dismissWithCompletion:self.confirm];
}

- (void)cancel:(id)sender {
    [self dismissWithCompletion:self.cancel];
}
@end
