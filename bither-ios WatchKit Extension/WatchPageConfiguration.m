//
//  WatchPageConfiguration.m
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
//  Created by songchenwen on 2015/05/08
//

#import "WatchPageConfiguration.h"
#import <WatchKit/WatchKit.h>


@implementation WatchPageConfiguration

static NSArray* currentNames;

+(BOOL)configurePagesFor:(NSArray*)names{
    if(!currentNames){
        currentNames = @[@"Market", @"Balance"];
    }
    if(![names isEqualToArray:currentNames]){
        [WKInterfaceController reloadRootControllersWithNames:names contexts:nil];
        currentNames = names;
        return YES;
    }
    return NO;
}

@end
