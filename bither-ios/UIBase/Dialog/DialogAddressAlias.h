//
//  DialogAddressAlias.h
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
//  Created by songchenwen on 2015/3/16.
//

#import <Foundation/Foundation.h>
#import "DialogWithActions.h"

@class BTAddress;

@protocol DialogAddressAliasDelegate
- (void)onAddressAliasChanged:(BTAddress *)address alias:(NSString *)alias;
@end

@interface DialogAddressAlias : DialogWithActions
- (instancetype)initWithAddress:(BTAddress *)address andDelegate:(NSObject <DialogAddressAliasDelegate> *)delegate;
@end