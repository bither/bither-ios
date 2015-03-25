//
//  StringUtilTest.m
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
#import "StringUtil.h"
#import "UnitUtil.h"

@interface StringUtilTest : XCTestCase

@end

@implementation StringUtilTest

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

- (void)testExampleu
{
    NSString * testString=@"L1NDdJPXzDQpBEAQVxt89CWBrLen6k7GX9WnaKJ1rBnXbyME8AMt";
    NSString * reslutStr=[StringUtil formatAddress:testString groupSize:4 lineSize:16];
//    NSInteger num=[StringUtil getNumOfQrCodeString:45];
//    XCTAssertTrue(num==1, @" test 45");
//     num=[StringUtil getNumOfQrCodeString:328];
//    XCTAssertTrue(num==2, @" test 328");
//     num=[StringUtil getNumOfQrCodeString:656];
//    XCTAssertTrue(num==3, @" test 656");
//     num=[StringUtil getNumOfQrCodeString:800];
//    XCTAssertTrue(num==3, @" test 800");
//     num=[StringUtil getNumOfQrCodeString:1000];
//    XCTAssertTrue(num==4, @" test 1000");
//     num=[StringUtil getNumOfQrCodeString:1300];
//    XCTAssertTrue(num==5, @" test 1300");
//    NSString * txt =@"4TbTbbbb3423RaaW";
//    NSString * encoeTxt=[StringUtil encodeQrCodeString:txt];
//    XCTAssertTrue([@"4*TB*TBBBB3423*RAA*W" isEqualToString:encoeTxt], @" encode");
//    NSString *decodeTxt=[StringUtil decodeQrCodeString:encoeTxt];
//    XCTAssertTrue([txt isEqualToString:decodeTxt], @"decode  and  encode");
//    NSString * test=@"dfasdfo90";
//    XCTAssertFalse([StringUtil verifyQrcodeTransport:test], @"test false");
    
    NSString * testStr=@"0.00000001";
    int64_t amount= [UnitUtil amountForString:testStr unit:UnitBTC];
    NSString * str=[UnitUtil stringForAmount:amount unit:UnitBTC];
    XCTAssertTrue([str isEqualToString:testStr], @"test amount");
    
    testStr=@"0.001";
    amount= [UnitUtil amountForString:testStr unit:UnitBTC];
    str=[UnitUtil stringForAmount:amount unit:UnitBTC];
    XCTAssertTrue([str isEqualToString:testStr], @"test amount");
    
    testStr=@"0";
    amount= [UnitUtil amountForString:testStr unit:UnitBTC];
    str=[UnitUtil stringForAmount:amount unit:UnitBTC];
    XCTAssertTrue([str isEqualToString:@"0.00"], @"test amount");
    
    
    NSString * address =@"1HZwkjkeaoZfTSaJxDw6aKkxp45agDiEzN";
    XCTAssertTrue([[StringUtil shortenAddress:address] isEqualToString:@"1HZw..."], @"shorten address");
    NSString * formatAddress=[StringUtil formatAddress:address groupSize:4 lineSize:12];
    XCTAssertTrue(formatAddress.length==43, @"format hash");
    XCTAssertTrue([StringUtil isValidBitcoinBIP21Address:@"bitcoin:1N9RQVmxewa2sEVDvmnsj9NgLHJ3dUjitz?amount=0.00040845"],@"bip21");
    XCTAssert([StringUtil validPassword:@"0aA`~!@#$%^&*()_-+={}[]|:;\\\"'<>,.?/"]);//"]);
    XCTAssertFalse([StringUtil validPassword:@"ASDF简繁"]);
    XCTAssert([StringUtil validPartialPassword:@"0aA`~!@#$%^&*()_-+={}[]|:;\\\"'<>,.?/"]);//"]);
    XCTAssertFalse([StringUtil validPartialPassword:@"ASDF简繁"]);


    
}

@end
