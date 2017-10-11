//
//  BccUnspentOutput.m
//  bither-ios
//
//  Created by LTQ on 2017/9/27.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "BccUnspentOutput.h"
#import "BTOut.h"
#import "NSString+Base58.h"
#import "NSData+Hash.h"

@implementation BccUnspentOutput

+ (instancetype) outsWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}
- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        @try {
            [self setValuesForKeysWithDictionary:dict];
        } @catch (NSException *exception) {
            return nil;
        } @finally {
            return nil;
        }
    }
    return self;
}

+(NSArray *)getBccUnspentOuts:(NSArray *)array {
    NSMutableArray *nmArray = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        BccUnspentOutput *outs = [BccUnspentOutput outsWithDict:dict];
        [nmArray addObject:outs];
    }];
    return nmArray;
}

+(NSArray *)getBTOuts:(NSArray *)bccUnspentArr {
    NSMutableArray  *outArray = [NSMutableArray array];
    for (BccUnspentOutput *out in bccUnspentArr) {
        BTOut *btOut = [[BTOut alloc]init];
        [btOut setOutValue: out.satoshis];
        [btOut setOutSn: out.vout];
        [btOut setOutScript: [out.scriptPubKey hexToData]];
        [btOut setTxHash:[[out.txid hexToData]reverse]];
        [outArray addObject:btOut];
    }
    return outArray;
}

@end
