//
//  ColdModeCheckConnectionView.m
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

#import "ColdModeCheckConnectionView.h"
#import "StringUtil.h"
#import "NetworkUtil.h"

#define kLabelHeight (30)
#define kLabelFontSize (19)
#define kLabelAnimAlpha (0.2f)
#define kLabelAnimDuration (0.5f)
#define kLabelCheckScale (0.8f)
#define kLabelAnimDelay (0.8f)
#define kIndicatorOffset (6)
#define kLabelTopOffset (60)

@interface ColdModeCheckConnectionView ()
@end

@implementation ColdModeCheckConnectionView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.clipsToBounds = YES;
    UIActivityIndicatorView *p = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:p];
    p.frame = CGRectMake((self.frame.size.width - p.frame.size.width) / 2, self.frame.size.height / 2 - p.frame.size.height - kIndicatorOffset - kLabelTopOffset, p.frame.size.width, p.frame.size.width);
    p.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [p startAnimating];
    for (int i = 0; i < 2; i++) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height / 2, self.frame.size.width, kLabelHeight)];
        lbl.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:kLabelFontSize];
        lbl.hidden = YES;
        [self addSubview:lbl];
    }
}

- (void)beginCheck:(void (^)(BOOL passed))completion {
    BOOL noWifi = ![NetworkUtil isEnableWIFI];
    BOOL no3G = ![NetworkUtil isEnable3G];
    [self animateLabel:(UILabel *) [self.subviews objectAtIndex:1] checking:NSLocalizedString(@"Checking WIFI", nil) error:NSLocalizedString(@"Please turn off WIFI", nil) passed:noWifi complete:^{
        UIView *pb = ((UIView *) [self.subviews objectAtIndex:0]);
        if (noWifi) {
            [self animateLabel:(UILabel *) [self.subviews objectAtIndex:2] checking:NSLocalizedString(@"Checking Cellular Data", nil) error:NSLocalizedString(@"Please turn off Cellular Data", nil) passed:no3G complete:^{
                pb.hidden = YES;
                if (completion) {
                    completion(noWifi && no3G);
                }
            }];
        } else {
            pb.hidden = YES;
            if (completion) {
                completion(noWifi && no3G);
            }
        }
    }];
}

- (void)animateLabel:(UILabel *)label checking:(NSString *)checking error:(NSString *)error passed:(BOOL)passed complete:(void (^)())completion {
    if (label.hidden && [StringUtil isEmpty:label.text]) {
        CGAffineTransform defaultTransaform = CGAffineTransformMakeScale(kLabelCheckScale, kLabelCheckScale);
        label.text = checking;
        CGRect frame = label.frame;
        frame.origin.y = [self getLabelTop:[self.subviews indexOfObject:label]];
        label.frame = frame;
        label.transform = CGAffineTransformTranslate(defaultTransaform, 0, kLabelHeight * 2);
        label.alpha = kLabelAnimAlpha;
        label.hidden = NO;
        [UIView animateWithDuration:kLabelAnimDuration animations:^{
            label.alpha = 1;
            label.transform = CGAffineTransformTranslate(defaultTransaform, 0, kLabelHeight);
        }                completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (kLabelAnimDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!passed) {
                    label.text = error;
                }
                [UIView animateWithDuration:kLabelAnimDuration animations:^{
                    if (passed) {
                        label.alpha = 0;
                        label.transform = defaultTransaform;
                    } else {
                        label.transform = CGAffineTransformIdentity;
                    }
                }                completion:^(BOOL finished) {
                    label.hidden = passed;
                    if (completion) {
                        completion();
                    }
                }];
            });
        }];
    } else if (passed && !label.hidden) {
        [UIView animateWithDuration:kLabelAnimDuration animations:^{
            label.transform = CGAffineTransformMakeScale(kLabelCheckScale, kLabelCheckScale);
            label.alpha = 0;
        }                completion:^(BOOL finished) {
            label.hidden = YES;
            if (completion) {
                completion();
            }
        }];
    } else if (completion) {
        completion();
    }
}

- (CGFloat)getLabelTop:(NSUInteger)index {
    if (index <= 1) {
        return self.frame.size.height / 2 - kLabelTopOffset;
    }
    UIView *v = [self.subviews objectAtIndex:index - 1];
    if (v.hidden) {
        if (index > 1) {
            return [self getLabelTop:index - 1];
        } else {
            return self.frame.size.height / 2 - kLabelTopOffset;
        }
    } else {
        return CGRectGetMaxY(v.frame);
    }
}

@end
