//  DateUtil.m
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

#import "DateUtil.h"

NSCalendar *gregorian;

@implementation DateUtil


+ (NSDate *)toDate:(NSString *)datetimeString {
    /*
     Returns a user+visible date time string that corresponds to the specified
     RFC 3339 date time string. Note that this does not handle all possible
     RFC 3339 date time strings, just one of the most common styles.
     */

    // If the date formatters aren't already set up, create them and cache them for reuse.
    NSDateFormatter *fullDateFormatter = nil;
    if (fullDateFormatter == nil) {
        fullDateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

        [fullDateFormatter setLocale:enUSPOSIXLocale];
        [fullDateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'"];
        //[fullDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    NSDate *date = [fullDateFormatter dateFromString:datetimeString];
    return date;
}

+ (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss "];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;

}

+ (NSDate *)getDateFormString:(NSString *)str {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss "];

    return [dateFormatter dateFromString:str];

}

+ (NSDate *)getDateFormStringWithTimeZone:(NSString *)str {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss "];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    return [dateFormatter dateFromString:str];

}


+ (NSString *)getStringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

+ (NSString *)getRelativeDate:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *curretDate = [NSDate dateWithTimeIntervalSinceNow:0];
    //  NSLog(@"date:%@,current:%@",date,curretDate);
    NSDateComponents *now = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit) fromDate:curretDate];
    NSDateComponents *day = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit) fromDate:date];
    double min = ([curretDate timeIntervalSince1970] - [date timeIntervalSince1970]) / 60;
    if ([self isToday:day andNow:now]) {
        if (min < 5) {
            return NSLocalizedString(@"Just now", nil);
        } else if (min < 60) {
            return [NSString stringWithFormat:NSLocalizedString(@"%0.f mins ago", nil), min];
        } else {
            return [NSString stringWithFormat:NSLocalizedString(@"%d hour ago", nil), now.hour - day.hour];
        }
    } else if ([self isYestoday:day andNow:now]) {
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setDateFormat:@"a h:mm"];
        return [NSString stringWithFormat:NSLocalizedString(@"yesterday %@", nil), [timeFormat stringFromDate:date]];
    } else {
        return [self getStringFromDate:date];
    }
}

+ (BOOL)isToday:(NSDateComponents *)day andNow:(NSDateComponents *)now {
    return day.year == now.year && day.month == now.month && day.day == now.day;
}

+ (BOOL)isYestoday:(NSDateComponents *)day andNow:(NSDateComponents *)now {
    return day.year == now.year && day.month == now.month && day.day == now.day - 1;
}

+ (BOOL)isThisMonth:(NSDateComponents *)day andNow:(NSDateComponents *)now {
    return day.year == now.year && day.month == now.month;
}

+ (BOOL)isLastMonth:(NSDateComponents *)day andNow:(NSDateComponents *)now {
    return day.year == now.year && day.month == now.month - 1;
}

+ (BOOL)isThisYear:(NSDateComponents *)day andNow:(NSDateComponents *)now {
    return day.year == now.year;
}

+ (BOOL)isLastYear:(NSDateComponents *)day andNow:(NSDateComponents *)now {
    return day.year == now.year - 1;
}

+ (NSDate *)getFirstTimeOfYear:(int)year {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = year;
    dateComponents.month = 1;
    dateComponents.day = 1;
    dateComponents.hour = 0;
    dateComponents.minute = 0;
    dateComponents.second = 0;
    return [DateUtil.gregorian dateFromComponents:dateComponents];
}

+ (NSCalendar *)gregorian {
    if (gregorian == nil) {
        gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    return gregorian;
}

@end
