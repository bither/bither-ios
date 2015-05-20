//
//  PinCodeEnterView.m
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

#import "PinCodeEnterView.h"
#import "UIBaseUtil.h"
#import <AudioToolbox/AudioToolbox.h>

#define kDotsViewHeight (20)
#define kDotsViewWidth (160)
#define kFontSize (16)
#define kPadding (10)
#define kTopMargin (30)
#define kBottomMargin (40)

@interface PinCodeEnterView () <UIKeyInput> {
    NSUInteger _pinCodeLength;
    NSString *_msg;
    UIView *topView;
    UIView *bottomView;
    NSString *_text;
}

@end

@implementation PinCodeEnterView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    _text = [NSString new];
    self.pinCodeLength = 4;
    self.enabled = YES;
    topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height / 2)];
    topView.backgroundColor = [UIColor clearColor];
    topView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height / 2, self.frame.size.width, self.frame.size.height / 2)];
    bottomView.backgroundColor = [UIColor clearColor];
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:topView];
    [self addSubview:bottomView];

    UIImageView *ivMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_code_water_mark"]];
    ivMark.frame = CGRectMake((self.frame.size.width - ivMark.frame.size.width) / 2, topView.frame.size.height - kTopMargin - ivMark.frame.size.height, ivMark.frame.size.width, ivMark.frame.size.height);
    ivMark.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [topView addSubview:ivMark];

    self.label = [[UILabel alloc] initWithFrame:CGRectMake(kPadding, topView.frame.size.height - kFontSize * 1.2f / 2.0f, topView.frame.size.width - kPadding * 2, kFontSize * 1.2f)];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:kFontSize];
    self.label.textColor = [UIColor whiteColor];
    [self addSubview:self.label];

    self.dv = [[PinCodeDotsView alloc] initWithFrame:CGRectMake((bottomView.frame.size.width - kDotsViewWidth) / 2, kBottomMargin, kDotsViewWidth, kDotsViewHeight)];
    self.dv.backgroundColor = [UIColor clearColor];
    self.dv.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [bottomView addSubview:self.dv];

    self.dvNew = [[PinCodeDotsView alloc] initWithFrame:CGRectMake(bottomView.frame.size.width, kBottomMargin, kDotsViewWidth, kDotsViewHeight)];
    self.dvNew.backgroundColor = [UIColor clearColor];
    self.dvNew.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [bottomView addSubview:self.dvNew];
}

- (void)animateToNext {
    self.enabled = NO;
    __block CGRect dvFrame = self.dv.frame;
    __block CGRect dvNewFrame = self.dvNew.frame;
    [UIView animateWithDuration:0.4f animations:^{
        self.dv.frame = CGRectMake(-self.dv.frame.size.width, self.dv.frame.origin.y, self.dv.frame.size.width, self.dv.frame.size.height);
        self.dvNew.frame = dvFrame;
    }                completion:^(BOOL finished) {
        self.dv.frame = dvFrame;
        self.dvNew.frame = dvNewFrame;
        [self clearText];
        self.enabled = YES;
    }];
}

- (void)shakeToClear {
    self.enabled = NO;
    [self clearText];
    [self vibrate];
    [self.dv shakeTime:5 interval:0.1f length:20 completion:^{
        self.enabled = YES;
    }];
}

- (void)vibrate {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)clearText {
    self.text = @"";
}

- (UIKeyboardType)keyboardType {
    return UIKeyboardTypeNumberPad;
}

- (BOOL)isSecureTextEntry {
    return YES;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)hasText {
    return _text && _text.length > 0;
}

- (void)insertText:(NSString *)text {
    if (_text.length < self.pinCodeLength && self.enabled) {
        _text = [_text stringByAppendingString:text];
        [self onTextChanged];
    }
}

- (void)deleteBackward {
    if (self.hasText && self.enabled) {
        _text = [_text substringToIndex:_text.length - 1];
        [self onTextChanged];
    }
}

- (void)onTextChanged {
    self.dv.filledCount = _text.length;
    if (_text.length >= self.pinCodeLength) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onEntered:)]) {
            [self.delegate performSelector:@selector(onEntered:) withObject:_text afterDelay:0.1];
        }
    }
}

- (void)setPinCodeLength:(NSUInteger)pinCodeLength {
    _pinCodeLength = pinCodeLength;
    self.dv.totalDotCount = pinCodeLength;
    self.dvNew.totalDotCount = pinCodeLength;
}

- (NSUInteger)pinCodeLength {
    return _pinCodeLength;
}

- (void)setMsg:(NSString *)msg {
    _msg = msg;
    self.label.text = msg;
    CGSize size = [self.label sizeThatFits:CGSizeMake(self.frame.size.width - kPadding * 2, kBottomMargin + kTopMargin)];
    size.height = ceil(size.height);
    self.label.frame = CGRectMake(kPadding, topView.frame.size.height - size.height / 2.0f, topView.frame.size.width - kPadding * 2, size.height);
}

- (NSString *)msg {
    return _msg;
}

- (void)setText:(NSString *)text {
    _text = text;
    [self onTextChanged];
}

- (NSString *)text {
    return _text;
}

@end
