//
//  WatchTrendingGraphicDrawer.h
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
//  Created by songchenwen on 2015/2/27.
//

#import <Foundation/Foundation.h>
#import "WatchTrendingGraphicData.h"
#import <WatchKit/WatchKit.h>
#define kEmptyImageCacheName (@"TrendingGraphicEmpty")

#define kTrendingAnimationFrameCount (20)
#define kTrendingAnimationDuration (0.3)

@interface WatchTrendingGraphicDrawer : NSObject
-(void)setEmptyImage:(WKInterfaceImage*)iv;
-(UIImage*)imageForData:(WatchTrendingGraphicData*)data;
-(UIImage*)animatingImageFromData:(WatchTrendingGraphicData*)from toData:(WatchTrendingGraphicData*)to;
@end
