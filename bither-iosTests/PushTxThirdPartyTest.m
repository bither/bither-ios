//
//  PushTxThirdPartyTest.m
//  bither-ios
//
//  Created by 宋辰文 on 16/5/10.
//  Copyright © 2016年 Bither. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PushTxThirdParty.h"
#import "NSString+Base58.h"

@interface PushTxThirdPartyTest : XCTestCase

@end

@implementation PushTxThirdPartyTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test {
    [[PushTxThirdParty instance] pushTx:[[BTTx alloc] initWithMessage:@"0100000001966fef15eadc214cd31f33030aa6694d4b7e3a35abc64d1ac8bdc68b927bbff9010000006b483045022100efd5fd2c8bbbb74a6ec46d6e688f732c4ebd6d5fb1896f542ae1310a22ec231502205e17a301b6ec6cb45c8459a8fc7513d270f349ecbf0c5810ec5baa9ed084e98101210322d9ce69a6084e0b0a668308d84a7e25d6e46eaf74078d1a1d35f3746e5a0521feffffff02b0ad0100000000001976a914314fd34e3d1c43285cd717dd1b8cbcf82678e27288ac0f031100000000001976a914bc53aa7fbde048b5d39b92d2c254755ac348744c88acd5450600".hexToData]];
}


@end
