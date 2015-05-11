//
//  GCCrashReportFilterTrim.m
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

#import "GCCrashReportFilterTrim.h"
#import <KSCrash/KSCrashCallCompletion.h>


@implementation GCCrashReportFilterTrim

- (void)filterReports:(NSArray *)reports
         onCompletion:(KSCrashReportFilterCompletion)onCompletion {
    NSMutableArray *filteredReports = [NSMutableArray arrayWithCapacity:[reports count]];
    for (NSDictionary *report in reports) {
        [filteredReports addObject:[self toTrim:report]];
    }
    kscrash_i_callCompletion(onCompletion, filteredReports, YES, nil);
}

- (NSDictionary *)toTrim:(NSDictionary *)report {
    NSMutableDictionary *newReport = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *) [report copy]];
    [newReport removeObjectForKey:@"binary_images"];
    return newReport;
}

@end
