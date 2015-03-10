//
//  WatchMarketBgDrawer.h
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
//  Created by songchenwen on 2015/3/10.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

#define kWatchMarketBgAnimationFrameCount (20)
#define kWatchMarketBgAnimationDuration (0.3)

@interface WatchMarketBgDrawer : NSObject
-(instancetype)initWithFrom:(UIColor*)from to:(UIColor*)to;
-(NSArray*)images;
@end
