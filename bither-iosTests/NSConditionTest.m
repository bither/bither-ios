//
//  NSConditionTest.m
//  bither-ios
//
//  Created by 宋辰文 on 15/2/2.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface NSConditionTest : XCTestCase

@end

@implementation NSConditionTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSCondition* condition = [NSCondition new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [NSThread sleepForTimeInterval:4];
        [condition lock];
        [condition signal];
        [condition unlock];
    });
    NSDate *date = [NSDate new];
    NSLog(@"begin");
    [condition lock];
    [condition wait];
    [condition unlock];
    NSLog(@"end");
    XCTAssert([[NSDate new] timeIntervalSinceDate:date] >= 4, @"Pass");
}

@end
