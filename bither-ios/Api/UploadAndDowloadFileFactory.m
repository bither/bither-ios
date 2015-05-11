#import "UploadAndDowloadFileFactory.h"
#import "FileUtil.h"
#import "UIImageExt.h"

static MKNetworkEngine *avatarNetworkEngine;
static MKNetworkEngine *picNetworkEngine;


@implementation UploadAndDowloadFileFactory
- (void)uploadAvatar:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    NSString *avatarName = [[UserDefaultsUtil instance] getUserAvatar];
    if (avatarName) {
        [self uploadImage:avatarName engine:[[BitherEngine instance] getUserNetworkEngine] url:@"api/v1/avatar" callback:callback andErrorCallBack:errorCallback];
    }

}

- (void)dowloadAvatar:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    NSString *avatarName = [[UserDefaultsUtil instance] getUserAvatar];
    if (avatarName) {
        NSString *fileFullName = [[FileUtil getAvatarDir] stringByAppendingString:avatarName];
        NSString *smallFileFullName = [[FileUtil getSmallAvatarDir] stringByAppendingString:avatarName];
        if (![FileUtil fileExists:smallFileFullName]) {
            NSString *url = @"http://bu.getcai.com/api/v1/avatar";
            [self  dowloadFile:fileFullName url:url callback:^(NSDictionary *dict) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    UIImage *image = [UIImage imageWithContentsOfFile:fileFullName];
                    UIImage *smallImage = [image scaleToSize:CGSizeMake(SMALL_IMAGE_WIDTH, SMALL_IMAGE_WIDTH)];
                    [FileUtil saveImage:smallFileFullName image:smallImage];

                });

            } andErrorCallBack:^(NSString *key, MKNetworkOperation *completedOperation, NSError *error) {
            }];

        }

    }


}

#pragma uploadImage

- (void)uploadImage:(NSString *)fileName engine:(MKNetworkEngine *)engine url:(NSString *)url callback:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback {
    NSString *fileFullName;
    fileFullName = [[FileUtil getUploadAvatarDir] stringByAppendingString:fileName];
    if (![FileUtil fileExists:fileFullName]) {
        if (callback) {
            callback(@{});
        }
        return;
    }
    NSMutableDictionary *md = [[NSMutableDictionary alloc] init];
    MKNetworkOperation *post = [engine operationWithPath:url params:md httpMethod:HTTP_POST];
    [post addFile:fileFullName forKey:@"file"];
    [post addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        [FileUtil removeFile:fileFullName];
        if (callback) {
            callback(@{});
        }
    }             errorHandler:^(MKNetworkOperation *errorOp, NSError *error) {
        NSLog(@" upload image error:%@", error);
        if (errorCallback) {
            errorCallback(errorOp, error);
        }

    }];
    [engine enqueueOperation:post];

}


- (void)dowloadFile:(NSString *)fileFullName url:(NSString *)url callback:(DictResponseBlock)callback andErrorCallBack:(DowloadResponseErrorBlock)errorCallback {
    if (picNetworkEngine == nil) {
        picNetworkEngine = [[BitherEngine instance] getUserNetworkEngine];
    }

    MKNetworkOperation *downloadOperation = [picNetworkEngine operationWithURLString:url];

    [downloadOperation addDownloadStream:[NSOutputStream outputStreamToFileAtPath:fileFullName
                                                                           append:YES]];
    [downloadOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        if (callback) {
            callback(@{});
        }
    }                          errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (errorCallback) {
            errorCallback(fileFullName, completedOperation, error);
        }
    }];

    [picNetworkEngine enqueueOperation:downloadOperation];
}


@end
