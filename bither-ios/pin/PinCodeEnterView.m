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
#define kDotsViewHeight (16)
#define kDotsViewWidth (160)
#define kFontSize (18)
#define kPadding (10)
#define kMargin (20)

@interface PinCodeEnterView() <UIKeyInput>{
    NSUInteger _pinCodeLength;
    NSString* _msg;
    UIView* topView;
    UIView* bottomView;
    NSString* _text;
}

@end

@implementation PinCodeEnterView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self firstConfigure];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self firstConfigure];
    }
    return self;
}

-(void)firstConfigure{
    self.keyboardType = UIKeyboardTypeNumberPad;
    topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height / 2)];
    topView.backgroundColor = [UIColor clearColor];
    topView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height / 2, self.frame.size.width, self.frame.size.height / 2)];
    bottomView.backgroundColor = [UIColor clearColor];
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:topView];
    [self addSubview:bottomView];
    
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(kPadding, topView.frame.size.height - kMargin - kFontSize * 1.2f, topView.frame.size.width - kPadding * 2, kFontSize * 1.2f)];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:kFontSize];
    self.label.textColor = [UIColor whiteColor];
    [topView addSubview:self.label];
    
    self.dv = [[PinCodeDotsView alloc]initWithFrame:CGRectMake((bottomView.frame.size.width - kDotsViewWidth)/2, kMargin, kDotsViewWidth, kDotsViewHeight)];
    self.dv.backgroundColor = [UIColor clearColor];
    self.dv.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [bottomView addSubview:self.dv];
    
    self.dvNew = [[PinCodeDotsView alloc]initWithFrame:CGRectMake(bottomView.frame.size.width, kMargin, kDotsViewWidth, kDotsViewHeight)];
    self.dvNew.backgroundColor = [UIColor clearColor];
    self.dvNew.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [bottomView addSubview:self.dvNew];
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)hasText{
    return _text && _text.length > 0;
}

- (void)insertText:(NSString *)text{
    _text = [_text stringByAppendingString:text];
}

- (void)deleteBackward{
    _text = [_text substringToIndex:_text.length - 1];
}

-(void)setPinCodeLength:(NSUInteger)pinCodeLength{
    _pinCodeLength = pinCodeLength;
}

-(NSUInteger)pinCodeLength{
    return _pinCodeLength;
}

-(void)setMsg:(NSString *)msg{
    _msg = msg;
    self.label.text = msg;
    CGSize size = [self.label sizeThatFits:CGSizeMake(self.frame.size.width - kPadding * 2, topView.frame.size.height - kMargin)];
    size.height = ceil(size.height);
    self.label.frame = CGRectMake(kPadding, topView.frame.size.height - kMargin - size.height, topView.frame.size.width - kPadding * 2, size.height);
}

-(NSString*)msg{
    return _msg;
}

@end
