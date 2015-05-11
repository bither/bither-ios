//  DataCheckUtil.m
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


#import "DataCheckUtil.h"


@implementation DataCheckUtil
+ (NSString *)CheckUserName:(NSString *)userName {
    if ([userName length] > 0) {
        if ([userName length] > 10) {
            return NSLocalizedString(@"Nickname length can not be more than 10", @"username_can_not_be_more_than_10_words");
        }
        if ([DataCheckUtil CheckSpecialChar:userName]) {
            NSString *prompt = @"[`'\"@%\\/\\(\\)\\[\\]\\<\\>\\{\\} ]";
            return [NSString stringWithFormat:NSLocalizedString(@"The user name cannot contain %@ and spaces", nil), prompt];
        }
    }
    return nil;

}

+ (BOOL)CheckEmailString:(NSString *)email {
    NSString *emailPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSError *error;
    NSRegularExpression *emailRegex = [NSRegularExpression regularExpressionWithPattern:emailPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSInteger result = [emailRegex numberOfMatchesInString:email options:NSMatchingReportProgress range:NSMakeRange(0, [email length])];
    return result > 0;
}

+ (BOOL)CheckEmailAndSetImage:(NSString *)email imageView:(UIImageView *)imageView {
    NSString *emailPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSError *error;
    NSRegularExpression *emailRegex = [NSRegularExpression regularExpressionWithPattern:emailPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSInteger result = [emailRegex numberOfMatchesInString:email options:NSMatchingReportProgress range:NSMakeRange(0, [email length])];
    if (result != 0) {
        imageView.image = [UIImage imageNamed:@"success"];
        return YES;
    }
    else {
        imageView.image = [UIImage imageNamed:@"fail"];
        return NO;
    }
}


+ (BOOL)CheckSpecialChar:(NSString *)userName {
    NSError *error;
    NSString *userNamePattern = @"[`'\"@%\\/\\(\\)\\[\\]\\<\\>\\{\\} ]";
    NSRegularExpression *userNameRegex = [NSRegularExpression regularExpressionWithPattern:userNamePattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [userNameRegex matchesInString:userName
                                              options:0
                                                range:NSMakeRange(0, [userName length])];
    return matches.count > 0;
}

+ (BOOL)CheckUserNameAndSetImage:(NSString *)userName imageView:(UIImageView *)imageView {
    NSError *error;
    NSString *userNamePattern = @"^[`'\"@%\\/\\(\\)\\[\\]\\<\\>\\{\\} ]$";
    NSRegularExpression *userNameRegex = [NSRegularExpression regularExpressionWithPattern:userNamePattern options:NSRegularExpressionCaseInsensitive error:&error];

    if ([userNameRegex numberOfMatchesInString:userName options:NSMatchingReportProgress range:NSMakeRange(0, [userName length])] != 0) {
        imageView.image = [UIImage imageNamed:@"success"];
        return YES;
    }
    else {
        imageView.image = [UIImage imageNamed:@"fail"];
        return NO;
    }
}

+ (BOOL)CheckTagName:(NSString *)tagName; {
    NSError *error;
    NSString *tagNamePattern = @"^[^ `\"'@%\\\\\\/<>{}\\[\\]\\(\\)#]+$";
    NSRegularExpression *tagNameRegex = [NSRegularExpression regularExpressionWithPattern:tagNamePattern options:NSRegularExpressionCaseInsensitive error:&error];

    if ([tagNameRegex numberOfMatchesInString:tagName options:NSMatchingReportProgress range:NSMakeRange(0, [tagName length])] != 0) {
        return YES;
    }
    else {
        return NO;
    }
}


@end
