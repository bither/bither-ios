//
//  PinCodeSetting.h
//  bither-ios
//
//  Created by noname on 14-11-21.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "Setting.h"

@interface PinCodeSetting : Setting<UIActionSheetDelegate,UIImagePickerControllerDelegate>
+(PinCodeSetting *)getPinCodeSetting;
@end
