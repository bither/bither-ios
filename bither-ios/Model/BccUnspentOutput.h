//
//  BccUnspentOutput.h
//  bither-ios
//
//  Created by LTQ on 2017/9/27.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BccUnspentOutput : NSObject

@property(nonatomic, readwrite) NSString *address;
@property(nonatomic,readwrite)  NSString *txid;
@property(nonatomic, readwrite) u_int64_t  satoshis;
@property(nonatomic, readwrite) NSString *scriptPubKey;
@property(nonatomic, readwrite) u_int vout;
@property(nonatomic, readwrite) double amount;
@property(nonatomic, readwrite) long height;
@property(nonatomic, readwrite) long confirmations;


+(NSArray *)getBTOuts:(NSArray *)bccUnspentArr;
+(NSArray *)getBccUnspentOuts:(NSArray *)array;

@end
