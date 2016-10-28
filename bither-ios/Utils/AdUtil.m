//
//  AdUtil.m
//  bither-ios
//
//  Created by 韩珍 on 2016/10/28.
//  Copyright © 2016年 Bither. All rights reserved.
//

#import "AdUtil.h"

#define kImgEn @"/img_en"
#define kImgZhCN @"/img_zh_CN"
#define kImgZhTW @"/img_zh_TW"
#define kAdCacheName @"/AdDic.txt"
#define kAdCacheFileName @"Ad"

@implementation AdUtil

#pragma mark - create

+ (NSString *)createCacheAdDicPath {
    NSString *adDicPath = [[AdUtil createCacheAdPath] stringByAppendingString:kAdCacheName];
    return adDicPath;
}

+ (NSString *)createCacheImgPathForFileName:(NSString *)fileName {
    NSString *imgPath = NULL;
    if ([fileName containsString:@"en"]) {
        imgPath = [AdUtil createCacheImgEnPath];
    } else if ([fileName containsString:@"CN"]) {
        imgPath = [AdUtil createCacheImgZhCNPath];
    } else {
        imgPath = [AdUtil createCacheImgZhTwPath];
    }
    [AdUtil clearUselessImageForPath:imgPath];
    return imgPath;
}

+ (NSString *)createCacheImgEnPath {
    NSString * imgPath = [AdUtil createCacheAdImagePathForFileName:kImgEn];
    [AdUtil isCreateForPath:imgPath];
    return imgPath;
}

+ (NSString *)createCacheImgZhCNPath {
    NSString * imgPath = [AdUtil createCacheAdImagePathForFileName:kImgZhCN];
    [AdUtil isCreateForPath:imgPath];
    return imgPath;
}

+ (NSString *)createCacheImgZhTwPath {
    NSString * imgPath = [AdUtil createCacheAdImagePathForFileName:kImgZhTW];
    [AdUtil isCreateForPath:imgPath];
    return imgPath;
}

#pragma mark - get

+ (NSString *)getAdImageFile {
    NSString *adImageDir = [AdUtil createCacheAdImagePathForFileName:NSLocalizedString(@"ad_image_name", nil)];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath: adImageDir];
    if (files.count != 0) {
        NSString *imgPath = [NSString stringWithFormat:@"%@/%@", adImageDir, files.firstObject];
        return imgPath;
    }
    return nil;
}

+ (NSString *)getAdFile {
    NSString *adDir = [[AdUtil createCacheAdPath] stringByAppendingString:kAdCacheName];
    return adDir;
}

#pragma mark - private

+ (NSString *)createCacheAdPath {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString *adPath = [documentsPath stringByAppendingPathComponent:kAdCacheFileName];
    [AdUtil isCreateForPath:adPath];
    return adPath;
}

+ (NSString *)createCacheAdImagePathForFileName:(NSString *)fileName {
    NSString *adPath = [AdUtil createCacheAdPath];
    NSString *imgPath = [adPath stringByAppendingString:fileName];
    [AdUtil isCreateForPath:imgPath];
    return imgPath;
}

+ (void)isCreateForPath:(NSString *)path {
    BOOL flag = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (!flag) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (void)clearUselessImageForPath:(NSString *)path {
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath: path];
    int count = (int)files.count;
    if (files.count > 1) {
        for (int i = 0; i < count - 1 ; i++) {
            NSString *imgPath = [NSString stringWithFormat:@"%@/%@", path, files[i]];
            [[NSFileManager defaultManager] removeItemAtPath:imgPath error:nil];
        }
    }
}




@end
