//
//  WatchStringUtil.m
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
//  Created by songchenwen on 2015/2/25.
//

#import "WatchStringUtil.h"

@implementation WatchStringUtil

+(NSString *)formatAddress:(NSString *)address groupSize:(NSInteger)groupSize  lineSize:(NSInteger) lineSize{
    NSInteger len=address.length;
    NSString * result=@"";
    
    for (NSInteger i=0; i<len; i+=groupSize) {
        NSInteger end=groupSize;
        if (i+groupSize>len) {
            end=len-i;
        }
        NSString * part=[address substringWithRange:NSMakeRange(i,end)];
        result=[result stringByAppendingString:part];
        if (end<len) {
            BOOL endOfLine=lineSize>0&&(i+end)%lineSize==0;
            if (endOfLine) {
                result= [result stringByAppendingString:@"\n"];
            }else{
                result= [result stringByAppendingString:@" "];
            }
        }
    }
    return result;
}

@end
