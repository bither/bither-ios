//
//  DialogReplaceWorld.h
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
#import "DialogCentered.h"
#import "DialogImportKeyDelegate.h"
#import "ImportPrivateKey.h"


@protocol DialogOperationDelegate <NSObject>

- (void)replaceWorld:(NSString *)newWorld index:(int)index;

- (void)deleteWorld:(NSString *)world index:(int)index;

- (void)beginOperation;

@end

@interface DialogReplaceWorld : DialogCentered

- (instancetype)initWithDelegate:(id <DialogOperationDelegate>)delegate world:(NSString *)world index:(int)index;

@property(weak) id <DialogOperationDelegate> delegate;

@end
