//
//  HDMApi.m
//  bitheri
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
#import <Bitheri/NSData+Bitcoin.h>
#import <Bitheri/NSMutableData+Bitcoin.h>
#import "HDMApi.h"
#import "AFHTTPRequestOperationManager.h"

static HDMApi *hdmApi;

@implementation HDMApi {
    AFHTTPRequestOperationManager *manager;
}

+ (HDMApi *)instance; {
    @synchronized (self) {
        if (hdmApi == nil) {
            hdmApi = [[self alloc] init];
        }
    }
    return hdmApi;
}

- (instancetype)init {
    if (!(self = [super init])) return nil;

    manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    manager.securityPolicy.allowInvalidCertificates = YES;
    if (![BitherSetting isUnitTest]) {
        manager.securityPolicy.pinnedCertificates = @[[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hdm.bither.net" ofType:@"cer"]]];
    } else {
        manager.securityPolicy.pinnedCertificates = @[[NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"hdm.bither.net" ofType:@"cer"]]];
    }

    return self;
}

- (void)getHDMPasswordRandomWithHDMBid:(NSString *)hdmBid callback:(IdResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback; {
    NSString *url = [NSString stringWithFormat:@"https://hdm.bither.net/api/v1/%@/hdm/password", hdmBid];
    AFHTTPRequestOperation *op = [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *random = @([operation.responseString longLongValue]);
        if (callback != nil) {
            callback(random);
        }
    }                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorCallback) {
            NSError *e = [self formatHttpErrorWithOperation:operation];
            errorCallback(operation, e);
        }
    }];
}

- (void)changeHDMPasswordWithHDMBid:(NSString *)hdmBid andPassword:(NSData *)password
                       andSignature:(NSString *)signature andHotAddress:(NSString *)hotAddress
                           callback:(VoidResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback; {
    NSDictionary *params = @{@"password" : [password base64EncodedString], @"signature" : signature,
            @"hot_address" : hotAddress};
    NSString *url = [NSString stringWithFormat:@"https://hdm.bither.net/api/v1/%@/hdm/password", hdmBid];
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:&error];
        if (error) DLog(@"JSON Parsing Error: %@", error);

        if (dict != nil && [dict[@"result"] isEqualToString:@"ok"]) {
            if (callback != nil) {
                callback();
            }
        } else {
            if (errorCallback) {
                errorCallback(operation, error);
            }
        }
    }     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorCallback) {
            NSError *e = [self formatHttpErrorWithOperation:operation];
            errorCallback(operation, e);
        }
    }];
};

- (void)createHDMAddressWithHDMBid:(NSString *)hdmBid andPassword:(NSData *)password start:(int)start end:(int)end
                           pubHots:(NSArray *)pubHots pubColds:(NSArray *)pubColds
                          callback:(ArrayResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback; {
    NSDictionary *params = @{@"password" : [password base64EncodedString], @"start" : @(start), @"end" : @(end),
            @"pub_hot" : [self connect:pubHots], @"pub_cold" : [self connect:pubColds]};
    NSString *url = [NSString stringWithFormat:@"https://hdm.bither.net/api/v1/%@/hdm/address/create", hdmBid];
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *pubRemotes = [self split:operation.responseString];
        if (callback != nil) {
            callback(pubRemotes);
        }
    }     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorCallback) {
            NSError *e = [self formatHttpErrorWithOperation:operation];
            errorCallback(operation, e);
        }
    }];
}

- (void)signatureByRemoteWithHDMBid:(NSString *)hdmBid andPassword:(NSData *)password andUnsignHash:(NSArray *)unsignHashes andIndex:(int)index
                           callback:(ArrayResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback; {
    NSDictionary *params = @{@"password" : [password base64EncodedString], @"unsign" : [self connect:unsignHashes]};
    NSString *url = [NSString stringWithFormat:@"https://hdm.bither.net/api/v1/%@/hdm/address/%d/signature", hdmBid, index];
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *signatures = [self split:operation.responseString];
        if (callback != nil) {
            callback(signatures);
        }
    }     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorCallback) {
            NSError *e = [self formatHttpErrorWithOperation:operation];
            errorCallback(operation, e);
        }
    }];
}

- (void)recoverHDMAddressWithHDMBid:(NSString *)hdmBid andPassword:(NSData *)password andSignature:(NSString *)signature
                           callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback; {
    NSDictionary *params = @{@"password" : [password base64EncodedString], @"signature" : signature};
    NSString *url = [NSString stringWithFormat:@"https://hdm.bither.net/api/v1/%@/hdm/recovery", hdmBid];
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:&error]];
        if (error) DLog(@"JSON Parsing Error: %@", error);

        if (dict != nil) {
            dict[@"pub_hot"] = [self split:dict[@"pub_hot"]];
            dict[@"pub_cold"] = [self split:dict[@"pub_cold"]];
            dict[@"pub_server"] = [self split:dict[@"pub_server"]];
            if (callback != nil) {
                callback(dict);
            }
        } else {
            if (errorCallback) {
                errorCallback(operation, error);
            }
        }
    }     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorCallback) {
            NSError *e = [self formatHttpErrorWithOperation:operation];
            errorCallback(operation, e);
        }
    }];
}

- (NSString *)connect:(NSArray *)dataList; {
    NSMutableData *result = [NSMutableData secureData];
    for (NSData *each in dataList) {
        [result appendUInt8:(uint8_t) each.length];
        [result appendData:each];
    }
    return [result base64EncodedString];
}

- (NSArray *)split:(NSString *)str; {
    NSData *data = [NSData dataFromBase64String:str];
    NSMutableArray *result = [NSMutableArray new];
    NSUInteger index = 0;
    while (data.length > index) {
        NSUInteger l = 0;
        NSData *each = [data dataAtOffset:index length:&l];
        index += l;
        if (each)
            [result addObject:each];
    }
    return result;
}

- (NSError *)formatHttpErrorWithOperation:(AFHTTPRequestOperation *)operation; {
    if (((NSHTTPURLResponse *) operation.response).statusCode == 400) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:nil];
        if (dict != nil) {
            return [[NSError alloc] initWithDomain:ERR_API_400_DOMAIN code:[dict.allKeys[0] intValue] userInfo:dict];
        } else {
            return [[NSError alloc] initWithDomain:ERR_API_400_DOMAIN code:-1 userInfo:nil];
        }

    } else if (((NSHTTPURLResponse *) operation.response).statusCode == 500) {
        return [[NSError alloc] initWithDomain:ERR_API_500_DOMAIN code:-1 userInfo:nil];
    }
    return [[NSError alloc] initWithDomain:ERR_API_500_DOMAIN code:-1 userInfo:nil];
}
@end