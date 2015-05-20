//  DateUtil.h
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


#import <Foundation/Foundation.h>

@interface DateUtil : NSObject

+ (NSDate *)toDate:(NSString *)datetimeString;

+ (NSString *)stringFromDate:(NSDate *)date;

+ (NSDate *)getDateFormString:(NSString *)str;

+ (NSDate *)getDateFormStringWithTimeZone:(NSString *)str;

+ (NSString *)getRelativeDate:(NSDate *)date;

+ (NSString *)getStringFromDate:(NSDate *)date;

+ (NSDate *)getFirstTimeOfYear:(int)year;

+ (NSCalendar *)gregorian;
@end
