//
//  DialogProgress.m
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

#import "DialogProgress.h"

#define kDialogProgressLabelMaxWidth 200
#define kDialogProgressLabelMaxHeight 200
#define kDialogProgressLabelFontSize 14
#define kDialogProgressMargin 10
#define kDialogProgressMinHeight 50
#define kDialogProgressHorizotalPadding 10
#define kDialogProgressVerticalPadding 5

@interface DialogProgress ()
@property(strong, nonatomic) UIActivityIndicatorView *riv;
@property(strong, nonatomic) UILabel *lbl;
@end

@implementation DialogProgress
- (id)initWithMessage:(NSString *)message {
    self = [super init];
    if (self) {
        CGSize constrainedSize = CGSizeMake(kDialogProgressLabelMaxWidth, kDialogProgressLabelMaxHeight);
        CGSize lableSize = [message sizeWithFont:[UIFont systemFontOfSize:kDialogProgressLabelFontSize] constrainedToSize:constrainedSize];
        self.riv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.frame = CGRectMake(0, 0, self.riv.frame.size.width + kDialogProgressMargin + lableSize.width + kDialogProgressHorizotalPadding * 2, fmaxf(lableSize.height + kDialogProgressVerticalPadding * 2, kDialogProgressMinHeight));
        self.riv.frame = CGRectMake(kDialogProgressHorizotalPadding, (self.frame.size.height - self.riv.frame.size.height) / 2, self.riv.frame.size.width, self.riv.frame.size.height);
        [self addSubview:self.riv];
        self.lbl = [[UILabel alloc] initWithFrame:CGRectMake(self.riv.frame.origin.x + self.riv.frame.size.width + kDialogProgressMargin, (self.frame.size.height - lableSize.height) / 2, lableSize.width, lableSize.height)];
        self.lbl.backgroundColor = [UIColor clearColor];
        self.lbl.font = [UIFont systemFontOfSize:kDialogProgressLabelFontSize];
        self.lbl.textColor = [UIColor whiteColor];
        self.lbl.text = message;
        [self addSubview:self.lbl];
        [self.riv startAnimating];
    }
    return self;
}

- (void)dialogWillShow {
    [super dialogWillShow];
}

- (void)dialogDidDismiss {
    [super dialogDidDismiss];
}


@end
