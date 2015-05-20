//
//  KeyboardController.m
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

#import "KeyboardController.h"

@implementation KeyboardController

- (id)initWithDelegate:(NSObject <KeyboardControllerDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)keyboardWasShown:(NSNotification *)aNotification {
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardFrameChanged:)]) {
        NSDictionary *info = [aNotification userInfo];
        CGRect frame = CGRectMake(0.0f, [[UIScreen mainScreen] bounds].size.height, 0.0f, 0.0f);
        if ([[info allKeys] containsObject:UIKeyboardFrameEndUserInfoKey]) {
            frame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        }
        if (![UIApplication sharedApplication].isStatusBarHidden) {
            frame.origin.y = frame.origin.y - [UIApplication sharedApplication].statusBarFrame.origin.y - [UIApplication sharedApplication].statusBarFrame.size.height;
        }
        double duration = 0;
        UIViewAnimationCurve curve = UIViewAnimationCurveEaseInOut;
        if ([info.allKeys containsObject:UIKeyboardAnimationDurationUserInfoKey]) {
            duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        }
        if ([info.allKeys containsObject:UIKeyboardAnimationCurveUserInfoKey]) {
            curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        }
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:curve];
        [UIView setAnimationDuration:duration];
        [self.delegate keyboardFrameChanged:frame];
        [UIView commitAnimations];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
