//
//  DialogXrandomInfo.h
//  bither-ios
//
//  Created by noname on 14-9-29.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "DialogCentered.h"

@interface DialogXrandomInfo : DialogCentered
- (instancetype)initWithGuide:(BOOL)guide;

- (instancetype)initWithPermission:(void (^)())completion;
@end
