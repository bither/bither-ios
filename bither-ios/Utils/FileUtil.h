//  FileUtil.h
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

#import <Foundation/Foundation.h>
#import "UserDefaultsUtil.h"


@interface FileUtil : NSObject
//TODO no backup of itunes
+ (NSString *)documentsPathForFileName:(NSString *)fileName;

+ (NSString *)cachePathForFileName:(NSString *)fileName;

+ (void)createDirectory:(NSString *)filePath;

+ (BOOL)fileExists:(NSString *)fileFullName;

+ (BOOL)removeFile:(NSString *)fileFullName;

+ (void)copyFile:(NSString *)fromFile toFile:(NSString *)toFile;

+ (void)createFileAtPath:(NSString *)fileName data:(NSData *)data;


+ (void)saveImage:(NSString *)fileFullName image:(UIImage *)image;

+ (void)saveImage:(NSString *)fileFullName image:(UIImage *)image compressionQuality:(float)quality;

+ (void)cleanCache:(int)uploadCount path:(NSString *)path;

+ (NSArray *)filesByModDate:(NSString *)fullPath;

+ (void)deleteTmpImageForShareWithName:(NSString *)name;

+ (NSURL *)saveTmpImageForShare:(UIImage *)image fileName:(NSString *)name;

+ (NSString *)getAvatarDir;

+ (NSString *)getSmallAvatarDir;

+ (NSString *)getUploadAvatarDir;
@end
