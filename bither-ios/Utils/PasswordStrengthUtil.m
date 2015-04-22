//
//  PasswordStrengthUtil.m
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
//
//  Created by songchenwen on 2015/4/22.
//

#import "PasswordStrengthUtil.h"
#import "UIColor+Util.h"

@interface PasswordStrengthUtil ()

@end

@implementation PasswordStrengthUtil

+ (PasswordStrengthUtil *)checkPassword:(NSString *)password {
    return [[PasswordStrengthUtil alloc] initWithStrength:[PasswordStrengthUtil getRating:password]];
}

- (instancetype)initWithStrength:(PasswordStrength)strength {
    self = [super init];
    if (self) {
        self.strength = strength;
    }
    return self;
}

- (NSString *)name {
    switch (self.strength) {
        case PasswordStrengthNormal:
            return NSLocalizedString(@"password_strength_normal", nil);
        case PasswordStrengthMedium:
            return NSLocalizedString(@"password_strength_medium", nil);
        case PasswordStrengthStrong:
            return NSLocalizedString(@"password_strength_strong", nil);
        case PasswordStrengthVeryStrong:
            return NSLocalizedString(@"password_strength_very_strong", nil);
        default:
            return NSLocalizedString(@"password_strength_weak", nil);
    }
}

- (UIColor *)color {
    switch (self.strength) {
        case PasswordStrengthNormal:
            return [UIColor parseColor:0xee5f5b];
        case PasswordStrengthMedium:
            return [UIColor parseColor:0xffa321];
        case PasswordStrengthStrong:
            return [UIColor parseColor:0x62c462];
        case PasswordStrengthVeryStrong:
            return [UIColor parseColor:0x62c462];
        default:
            return [UIColor parseColor:0xee5f5b];
    }
}

- (float)progress {
    return (float) (self.strength + 1.0f) / 5.0f;
}

- (BOOL)passed {
    return self.strength >= PasswordStrengthNormal;
}

- (BOOL)warning {
    return self.passed && self.strength <= PasswordStrengthMedium;
}

+ (NSUInteger)getRating:(NSString *)password {
    if (!password || password.length < 6) {
        return 0;
    }
    NSUInteger strength = 0;
    if (password.length > 9) {
        strength++;
    }
    NSUInteger digitCount = [PasswordStrengthUtil getDigitCount:password];
    NSUInteger symbolCount = [PasswordStrengthUtil getSymbolCount:password];
    BOOL upperAndLower = [PasswordStrengthUtil bothUpperAndLower:password];
    if (digitCount > 0 && digitCount != password.length) {
        strength++;
    }
    if (symbolCount > 0 && symbolCount != password.length) {
        strength++;
    }
    if (upperAndLower) {
        strength++;
    }
    return strength;
}

+ (BOOL)bothUpperAndLower:(NSString *)password {
    if (!password || password.length == 0) {
        return NO;
    }
    BOOL upper = NO;
    BOOL lower = NO;
    NSUInteger length = password.length;
    NSCharacterSet *upperSet = [NSCharacterSet uppercaseLetterCharacterSet];
    NSCharacterSet *lowerSet = [NSCharacterSet lowercaseLetterCharacterSet];
    for (NSUInteger i = 0; i < length; i++) {
        unichar c = [password characterAtIndex:i];
        if (!upper) {
            upper = [upperSet characterIsMember:c];
        }
        if (!lower) {
            lower = [lowerSet characterIsMember:c];
        }
        if (upper && lower) {
            break;
        }
    }
    return upper && lower;
}

+ (NSUInteger)getDigitCount:(NSString *)password {
    if (!password || password.length == 0) {
        return 0;
    }
    NSUInteger numDigit = 0;
    NSUInteger length = password.length;
    NSCharacterSet *digitsSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (NSUInteger i = 0; i < length; i++) {
        if ([digitsSet characterIsMember:[password characterAtIndex:i]]) {
            numDigit++;
        }
    }
    return numDigit;
}

+ (NSUInteger)getSymbolCount:(NSString *)password {
    if (!password || password.length == 0) {
        return 0;
    }
    NSUInteger numSymbol = 0;
    NSUInteger length = password.length;
    NSCharacterSet *symbolSet = [NSCharacterSet characterSetWithCharactersInString:@"`~!@#$%^&*()_\\-+=|{}':;',\\[\\].\\\"\\\\<>/?"];
    for (NSUInteger i = 0; i < length; i++) {
        if ([symbolSet characterIsMember:[password characterAtIndex:i]]) {
            numSymbol++;
        }
    }
    return numSymbol;
}

@end