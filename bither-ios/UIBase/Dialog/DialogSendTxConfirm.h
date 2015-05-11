//
//  DialogSendTxConfirm.h
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

#import "DialogCentered.h"
#import <Bitheri/BTTx.h>
#import <Bitheri/BTAddress.h>

@protocol DialogSendTxConfirmDelegate <NSObject>
@optional
- (void)onSendTxConfirmed:(BTTx *)tx;

- (void)onSendTxCanceled;
@end

@interface DialogSendTxConfirm : DialogCentered
- (instancetype)initWithTx:(BTTx *)tx from:(BTAddress *)fromAddress to:(NSString *)toAddress changeTo:(NSString *)changeAddress delegate:(NSObject <DialogSendTxConfirmDelegate> *)delegate;

@property(weak) NSObject <DialogSendTxConfirmDelegate> *delegate;
@end
