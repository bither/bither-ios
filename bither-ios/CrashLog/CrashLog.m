//
//  CrashLog.m
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

#import "CrashLog.h"

@implementation CrashLog

+ (void)initCrashLog; {
    GCCrashInstallation *installation = (GCCrashInstallation *) [GCCrashInstallation sharedInstance];
    [installation install];
    [installation sendAllReportsWithCompletion:^(NSArray *filteredReports, BOOL completed, NSError *error) {
        // Stuff to do when report sending is complete
        //id i = [[NSArray new] objectAtIndex:0];
    }];
}

@end
