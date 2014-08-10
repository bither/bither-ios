//
//  WalletUtilTest.m
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

#import <XCTest/XCTest.h>
#import "KeyUtil.h"
#import "BTAddressManager.h"
#import "PeerUtil.h"

@interface WalletUtilTest : XCTestCase

@end

@implementation WalletUtilTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
//    [[BTAddressManager sharedInstance] setWatchOnlyDir:[KeyUtil getWatchOnlyDir]];
//    [[BTAddressManager sharedInstance] setPrivateKeyDir:[KeyUtil getPrivateKeyDir]];
//    [[BTAddressManager sharedInstance] initAddress];
//    [[BTAddressManager sharedInstance ] addPubKey:@"04a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd5b8dec5235a0fa8722476c7709c02559e3aa73aa03918ba2d492eea75abea235"];
//    if (![[BTAddressManager sharedInstance] allSyncComplete]) {
//        [WalletUtil syncWallet:^{
//            NSLog(@"sync wallet ");
//        }];
//    }
}

@end
