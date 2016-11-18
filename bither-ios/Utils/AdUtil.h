//
//  AdUtil.h
//  bither-ios
//
//  Created by 韩珍 on 2016/10/28.
//  Copyright © 2016年 Bither. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdUtil : NSObject

+ (NSString *)createCacheAdDicPath;

+ (NSString *)createCacheImgPathForFileName:(NSString *)fileName;

+ (NSDictionary *)getAd;

+ (UIImage *)getAdImage;

+ (BOOL)isDownloadImageForNewAdDic:(NSDictionary *)adDic;

+ (BOOL)isShowAd;

@end
