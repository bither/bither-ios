//
//  ScanQrCodeTransportViewController.h
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

#import "ScanQrCodeViewController.h"

@interface ScanQrCodeTransportViewController : ScanQrCodeViewController
- (instancetype)initWithDelegate:(NSObject <ScanQrCodeDelegate> *)delegate title:(NSString *)title pageName:(NSString *)pageName;

@property(weak) NSObject <ScanQrCodeDelegate> *delegate;
@property(strong, nonatomic) NSString *pageName;
@end
