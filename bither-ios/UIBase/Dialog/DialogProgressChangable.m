//
//  DialogProgressChangable.m
//  bither-ios
//
//  Created by noname on 14-10-22.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "DialogProgressChangable.h"

#define kDialogProgressLabelMaxWidth 200
#define kDialogProgressLabelMaxHeight 200
#define kDialogProgressLabelFontSize 14
#define kDialogProgressMargin 10
#define kDialogProgressMinHeight 50
#define kDialogProgressHorizotalPadding 10
#define kDialogProgressVerticalPadding 5

@interface DialogProgressChangable ()
@property(strong, nonatomic) UIActivityIndicatorView *riv;
@property(strong, nonatomic) UIImageView *ivIcon;
@property(strong, nonatomic) UILabel *lbl;
@end

@implementation DialogProgressChangable

- (id)initWithMessage:(NSString *)message {
    self = [super init];
    if (self) {
        CGSize constrainedSize = CGSizeMake(kDialogProgressLabelMaxWidth, kDialogProgressLabelMaxHeight);
        CGSize lableSize = [message sizeWithFont:[UIFont systemFontOfSize:kDialogProgressLabelFontSize] constrainedToSize:constrainedSize];
        self.riv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.frame = CGRectMake(0, 0, self.riv.frame.size.width + kDialogProgressMargin + lableSize.width + kDialogProgressHorizotalPadding * 2, fmaxf(lableSize.height + kDialogProgressVerticalPadding * 2, kDialogProgressMinHeight));
        self.riv.frame = CGRectMake(kDialogProgressHorizotalPadding, (self.frame.size.height - self.riv.frame.size.height) / 2, self.riv.frame.size.width, self.riv.frame.size.height);
        [self addSubview:self.riv];
        self.ivIcon = [[UIImageView alloc] initWithFrame:self.riv.frame];
        self.ivIcon.hidden = YES;
        [self addSubview:self.ivIcon];
        self.lbl = [[UILabel alloc] initWithFrame:CGRectMake(self.riv.frame.origin.x + self.riv.frame.size.width + kDialogProgressMargin, (self.frame.size.height - lableSize.height) / 2, lableSize.width, lableSize.height)];
        self.lbl.backgroundColor = [UIColor clearColor];
        self.lbl.numberOfLines = 1;
        self.lbl.font = [UIFont systemFontOfSize:kDialogProgressLabelFontSize];
        self.lbl.textColor = [UIColor whiteColor];
        self.lbl.text = message;
        self.lbl.clipsToBounds = YES;
        [self addSubview:self.lbl];
        [self.riv startAnimating];
    }
    return self;
}

- (void)showInWindow:(UIWindow *)window completion:(void (^)())completion {
    if ([self shown]) {
        if (completion) {
            completion();
        }
    } else {
        [super showInWindow:window completion:completion];
    }
}

- (void)dismissWithCompletion:(void (^)())completion {
    if ([self shown]) {
        [super dismissWithCompletion:completion];
    } else {
        if (completion) {
            completion();
        }
    }
}

- (void)dialogWillShow {
    [super dialogWillShow];
}

- (void)dialogDidDismiss {
    [super dialogDidDismiss];
}

- (void)changeToMessage:(NSString *)message icon:(UIImage *)icon completion:(void (^)())completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (icon) {
            self.ivIcon.image = icon;
            self.ivIcon.hidden = NO;
            self.riv.hidden = YES;
        } else {
            self.ivIcon.image = nil;
            self.ivIcon.hidden = YES;
            self.riv.hidden = NO;
        }
        if (message) {
            CGSize constrainedSize = CGSizeMake(kDialogProgressLabelMaxWidth, kDialogProgressLabelMaxHeight);
            CGSize lableSize = [message sizeWithFont:[UIFont systemFontOfSize:kDialogProgressLabelFontSize] constrainedToSize:constrainedSize];
            self.lbl.text = message;
            if ([self shown]) {
                if (CGSizeEqualToSize(lableSize, self.lbl.frame.size)) {
                    if (completion) {
                        completion();
                    }
                } else {
                    [UIView animateWithDuration:0.2 animations:^{
                        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.riv.frame.size.width + kDialogProgressMargin + lableSize.width + kDialogProgressHorizotalPadding * 2, fmaxf(lableSize.height + kDialogProgressVerticalPadding * 2, kDialogProgressMinHeight));
                        [self resize];
                        self.lbl.frame = CGRectMake(self.riv.frame.origin.x + self.riv.frame.size.width + kDialogProgressMargin, (self.frame.size.height - lableSize.height) / 2, lableSize.width, lableSize.height);
                    }                completion:^(BOOL finished) {
                        if (completion) {
                            completion();
                        }
                    }];
                }
            } else {
                if (!CGSizeEqualToSize(lableSize, self.lbl.frame.size)) {
                    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.riv.frame.size.width + kDialogProgressMargin + lableSize.width + kDialogProgressHorizotalPadding * 2, fmaxf(lableSize.height + kDialogProgressVerticalPadding * 2, kDialogProgressMinHeight));
                    [self resize];
                    self.lbl.frame = CGRectMake(self.riv.frame.origin.x + self.riv.frame.size.width + kDialogProgressMargin, (self.frame.size.height - lableSize.height) / 2, lableSize.width, lableSize.height);
                }
                if (completion) {
                    completion();
                }
            }
        } else {
            if (completion) {
                completion();
            }
        }
    });
}

- (void)changeToMessage:(NSString *)message completion:(void (^)())completion {
    [self changeToMessage:message icon:nil completion:completion];
}

- (void)changeToMessage:(NSString *)message {
    [self changeToMessage:message icon:nil completion:nil];
}

- (void)changeToMessage:(NSString *)message icon:(UIImage *)icon {
    [self changeToMessage:message icon:icon completion:nil];
}


@end
