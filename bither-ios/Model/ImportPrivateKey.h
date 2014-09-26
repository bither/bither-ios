//
//  ImportPrivateKey.h
//  bither-ios
//
//  Created by noname on 14-9-25.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum  {
     PrivateText, BitherQrcode, Bip38
}ImportPrivateKeyType;

@interface ImportPrivateKey : NSObject

@end
