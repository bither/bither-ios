//  FileUtil.m
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

#import "FileUtil.h"

@implementation FileUtil

#define IMAGE_CACHE_UPLOAD @"/upload"
#define IMAGE_CACHE_612  @"/612"
#define IMAGE_CACHE_150  @"/150"

+ (NSString *)cachePathForFileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:fileName];
}

+ (NSString *)documentsPathForFileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:fileName];
}

+ (BOOL)fileExists:(NSString *)fileFullName {
    NSFileManager *file_manager = [NSFileManager defaultManager];
    return [file_manager fileExistsAtPath:fileFullName];
}

+ (BOOL)removeFile:(NSString *)fileFullName {
    NSFileManager *file_manager = [NSFileManager defaultManager];
    return [file_manager fileExistsAtPath:fileFullName] && [file_manager removeItemAtPath:fileFullName error:nil];
}

+ (void)copyFile:(NSString *)fromFile toFile:(NSString *)toFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;


    if ([fileManager fileExistsAtPath:fromFile] == YES) {
        [fileManager copyItemAtPath:fromFile toPath:toFile error:&error];
    }
}

+ (void)createDirectory:(NSString *)filePath {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (void)createFileAtPath:(NSString *)fileName data:(NSData *)data {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:fileName contents:data attributes:nil];
}

+ (void)saveImage:(NSString *)fileFullName image:(UIImage *)image {
    [[NSFileManager defaultManager] createFileAtPath:fileFullName contents:UIImageJPEGRepresentation(image, 0.445) attributes:nil];
}

+ (void)saveImage:(NSString *)fileFullName image:(UIImage *)image compressionQuality:(float)quality {
    [[NSFileManager defaultManager] createFileAtPath:fileFullName contents:UIImageJPEGRepresentation(image, quality) attributes:nil];
}


+ (void)cleanCache:(int)uploadCount path:(NSString *)path {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSError *error = nil;
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
        int sum = (int)files.count - uploadCount;
        if (sum > 150) {
            NSArray *fileList = [FileUtil filesByModDate:path];
            for (int i = 0; i < sum - 50; i++) {
                [[NSFileManager defaultManager] removeItemAtPath:[fileList objectAtIndex:i] error:nil];
            }
        }
    });

}

+ (NSArray *)filesByModDate:(NSString *)fullPath {
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath
                                                                         error:&error];
    if (error == nil) {
        NSMutableDictionary *filesAndProperties = [NSMutableDictionary dictionaryWithCapacity:[files count]];
        for (NSString *path in files) {
            NSDictionary *properties = [[NSFileManager defaultManager]
                    attributesOfItemAtPath:[fullPath stringByAppendingPathComponent:path]
                                     error:&error];
            NSDate *modDate = [properties objectForKey:NSFileModificationDate];
            if (error == nil) {
                [filesAndProperties setValue:modDate forKey:path];
            }
        }
        return [filesAndProperties keysSortedByValueUsingSelector:@selector(compare:)];
    }
    return [NSArray array];
}

+ (void)deleteTmpImageForShareWithName:(NSString *)name {
    NSString *path = [FileUtil cachePathForFileName:[NSString stringWithFormat:@"%@.jpg", name]];
    [FileUtil removeFile:path];
}

+ (NSURL *)saveTmpImageForShare:(UIImage *)image fileName:(NSString *)name {
    NSString *path = [FileUtil cachePathForFileName:[NSString stringWithFormat:@"%@.jpg", name]];
    [FileUtil saveImage:path image:image compressionQuality:1];
    return [NSURL fileURLWithPath:path];
}

+ (NSString *)getAvatarDir {
    NSString *avatarDir = [FileUtil cachePathForFileName:IMAGE_CACHE_612];
    [FileUtil createDirectory:avatarDir];
    return [avatarDir stringByAppendingString:@"/"];

}

+ (NSString *)getSmallAvatarDir {
    NSString *avatarDir = [FileUtil cachePathForFileName:IMAGE_CACHE_150];
    [FileUtil createDirectory:avatarDir];
    return [avatarDir stringByAppendingString:@"/"];
}

+ (NSString *)getUploadAvatarDir {
    NSString *avatarDir = [FileUtil cachePathForFileName:IMAGE_CACHE_UPLOAD];
    [FileUtil createDirectory:avatarDir];
    return [avatarDir stringByAppendingString:@"/"];
}

@end
