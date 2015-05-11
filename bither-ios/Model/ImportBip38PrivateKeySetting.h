//
//  ImportBip38PrivateKeySetting.h
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
#import "HotCheckPrivateKeyViewController.h"
#import "ScanQrCodeViewController.h"
#import "DialogPassword.h"
#import "StringUtil.h"
#import "BTKey+Bitcoinj.h"
#import "DialogImportPrivateKey.h"
#import "Setting.h"


@interface ImportBip38PrivateKeySetting : Setting <UIActionSheetDelegate, ScanQrCodeDelegate, DialogPasswordDelegate, DialogImportKeyDelegate> {
    NSString *_result;
    BTKey *_key;
}
@property(nonatomic, strong) UIViewController *controller;

+ (Setting *)getImportBip38PrivateKeySetting;

@end
