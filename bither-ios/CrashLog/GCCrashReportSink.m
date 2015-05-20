//
//  GCCrashReportSink.m
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

#import "GCCrashReportSink.h"
#import <KSCrash/KSCrashReportFilterAppleFmt.h>
#import <KSCrash/KSCrashCallCompletion.h>
#import "BitherApi.h"


@implementation GCCrashReportSink

+ (GCCrashReportSink *)sink {
    return [[self alloc] init];
}

- (id <KSCrashReportFilter>)defaultCrashReportFilterSet {
    //    return [KSCrashReportFilterPipeline filterWithFilters:
    //            [[GCCrashReportFilterTrim alloc] init],
    //            [KSCrashReportFilterJSONEncode filterWithOptions:KSJSONEncodeOptionSorted],
    //            [KSCrashReportFilterGZipCompress filterWithCompressionLevel:-1],
    //            self,
    //            nil];
    return [KSCrashReportFilterPipeline filterWithFilters:
            [[GCCrashReportFilterTrim alloc] init],
            [KSCrashReportFilterAppleFmt filterWithReportStyle:KSAppleReportStyleSymbolicatedSideBySide],
            //            [KSCrashReportFilterStringToData filter],
            //            [KSCrashReportFilterGZipCompress filterWithCompressionLevel:-1],
            self,
                    nil];
}

- (void)filterReports:(NSArray *)reports
         onCompletion:(KSCrashReportFilterCompletion)onCompletion {
    BitherApi *bitherApi = [BitherApi instance];
    if ([reports count] > 0) {
        for (NSString *data in reports) {
            [bitherApi uploadCrash:data callback:^(NSDictionary *dict) {
                kscrash_i_callCompletion(onCompletion, reports, YES, nil);
            }     andErrorCallBack:^(NSOperation *errorOp, NSError *error) {
                kscrash_i_callCompletion(onCompletion, reports, NO, nil);
            }];
        }
    }
}

@end
