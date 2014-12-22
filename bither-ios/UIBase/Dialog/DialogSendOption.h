//
//  DialogSendOption.h
//  bither-ios
//
//  Created by 宋辰文 on 14/12/22.
//  Copyright (c) 2014年 宋辰文. All rights reserved.
//

#import "DialogCentered.h"

@protocol DialogSendOptionDelegate <NSObject>
-(void)selectChangeAddress;
@end

@interface DialogSendOption : DialogCentered
-(instancetype)initWithDelegate:(NSObject<DialogSendOptionDelegate>*)delegate;

@property (weak) NSObject<DialogSendOptionDelegate>* delegate;
@end
