//
//  NSError+HDMHttpErrorMessage.h
//  bither-ios
//
//  Created by 宋辰文 on 15/2/2.
//  Copyright (c) 2015年 宋辰文. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (HDMHttpErrorMessage)
- (NSString *)msg;

- (BOOL)isHttp400;
@end
