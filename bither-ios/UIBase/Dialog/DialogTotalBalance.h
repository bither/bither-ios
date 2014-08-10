//
//  DialogTotalBalance.h
//  bither-ios
//
//  Created by noname on 14-8-4.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "DialogWithArrow.h"

@protocol DialogTotalBalanceDismissListener <NSObject>
-(void)dialogDismissed;
@end

@interface DialogTotalBalance : DialogWithArrow
@property (weak) NSObject<DialogTotalBalanceDismissListener>* listener;
@end
