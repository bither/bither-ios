#import <Foundation/Foundation.h>
#import "BitherEngine.h"


#define file_not_found @"file_not_found"
#define file_not_found_code 1

typedef void (^DowloadProgressBlock)(NSString *key, double progress);

typedef void (^DowloadResponseErrorBlock)(NSString *key, MKNetworkOperation *completedOperation, NSError *error);

@interface UploadAndDowloadFileFactory : NSObject
- (void)uploadAvatar:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;

- (void)dowloadAvatar:(DictResponseBlock)callback andErrorCallBack:(ErrorHandler)errorCallback;
@end
