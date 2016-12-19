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
#define kTIME_STAMP @"timestamp"

@implementation AdUtil

#pragma mark - create

+ (NSString *)createCacheAdDicPath {
    NSString *adDicPath = [[AdUtil createCacheAdPath] stringByAppendingString:kAdCacheName];
    return adDicPath;
}

+ (NSString *)createCacheImgPathForFileName:(NSString *)fileName {
    NSString *imgPath = NULL;
    if ([fileName isEqualToString:@"img_en"]) {
        imgPath = [AdUtil createCacheImgEnPath];
    } else if ([fileName isEqualToString:@"img_zh_CN"]) {
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

+ (UIImage *)getAdImage {
    NSData * data = [NSData dataWithContentsOfFile:[AdUtil getAdImageFile]];
    return [UIImage imageWithData:data];
}

+ (NSDictionary *)getAd {
    NSString *adPath = [AdUtil getAdFile];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:adPath];
    return dic;
}

+ (BOOL)isDownloadImageForNewAdDic:(NSDictionary *)adDic {
    NSString *adPath = [AdUtil getAdFile];
    BOOL dicFlag = [[NSFileManager defaultManager] fileExistsAtPath:adPath];
    if (dicFlag) {
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:adPath];
        if ([dic[kTIME_STAMP] isEqualToString:adDic[kTIME_STAMP]]) {
            return false;
        }
    }
    return true;
}

+ (BOOL)isShowAd {
    NSString *adPath = [AdUtil getAdFile];
    NSString *imagePath = [AdUtil getAdImageFile];
    BOOL dicFlag = [[NSFileManager defaultManager] fileExistsAtPath:adPath];
    BOOL imageFlag = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
    if (dicFlag && imageFlag) {
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:adPath];
        BOOL showFlag = [[NSString stringWithFormat:@"%@", dic[kTIME_STAMP]] isEqualToString:@"0"];
        if (!showFlag) {
            return true;
        }
    }
    return false;
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

+ (NSString *)getAdFile {
    NSString *adDir = [[AdUtil createCacheAdPath] stringByAppendingString:kAdCacheName];
    return adDir;
}

+ (NSString *)getAdImageFile {
    NSString *adImageDir = [AdUtil createCacheAdImagePathForFileName:NSLocalizedString(@"ad_image_name", nil)];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath: adImageDir];
    if (files.count != 0) {
        NSString *imgPath = [NSString stringWithFormat:@"%@/%@", adImageDir, files.lastObject];
        return imgPath;
    }
    return nil;
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
