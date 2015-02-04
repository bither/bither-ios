//
//  HDMApiTest.m
//  bither-ios
//
//  Created by ZhouQi on 15/2/4.
//  Copyright (c) 2015年 Bither. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BTHDMBid.h"
#import "BTHDMBid+Api.h"
#import "NSString+Base58.h"
#import "BTBIP32Key.h"
#import "HDMApi.h"
#import "AFHTTPRequestOperationManager.h"
#import "HDMApi.h"
#import "NSData+Hash.h"

@interface HDMApiTest : XCTestCase

@end

@implementation HDMApiTest

- (void)setUp {
    [super setUp];
    [BitherSetting setIsUnitTest:YES];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testNormal {
    if (YES)
        return;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // change password
        NSData *hdmHot = [@"0000000000000000000000000000000000000000000000000000000000000001" hexToData];
        NSData *hdmCold = [@"0000000000000000000000000000000000000000000000000000000000000002" hexToData];
        BTBIP32Key *keyHot = [[BTBIP32Key alloc] initWithSeed:hdmHot];
        BTBIP32Key *keyCold = [[BTBIP32Key alloc] initWithSeed:hdmCold];
        BTBIP32Key *firstKeyCold = [self getPrivKey:0 andMasterKey:keyCold];
        BTBIP32Key *firstKeyHot = [self getPrivKey:0 andMasterKey:keyHot];
        BTHDMBid *hdmBid = [[BTHDMBid alloc] initWithHDMBid:[firstKeyCold.key address]];
        NSError *error = nil;
        NSString *pre = [hdmBid getPreSignHashAndError:&error];
        NSString *signature = [[firstKeyCold.key signHash:[pre hexToData]] base64EncodedStringWithOptions:0];
        [hdmBid changeBidPasswordWithSignature:signature andPassword:[NSString hexWithData:hdmBid.password] andHotAddress:[firstKeyHot.key address] andError:&error];
    });
}

- (BTBIP32Key *)getPrivKey:(int)index andMasterKey:(BTBIP32Key *)master; {
    BTBIP32Key *purpose = [master deriveHardened:44];
    BTBIP32Key *coinType = [purpose deriveHardened:0];
    BTBIP32Key *account = [coinType deriveHardened:0];
    BTBIP32Key *externalPriv = [account deriveSoftened:0];
    return [externalPriv deriveSoftened:index];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
