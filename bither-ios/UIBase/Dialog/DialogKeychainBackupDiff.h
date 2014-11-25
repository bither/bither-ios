//
//  DialogKeychainBackupDiff.h
//  bither-ios
//
//  Created by noname on 14/11/24.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "DialogCentered.h"

@protocol DialogKeychainBackupDiffDelegate <NSObject>

-(void)onAccept;
-(void)onDeny;

@end

@interface DialogKeychainBackupDiff : DialogCentered
-(instancetype)initWithDiffs:(NSArray*)diffs andDelegate:(NSObject<DialogKeychainBackupDiffDelegate>*)delegate;
@property NSArray* diffs;
@property (weak) NSObject<DialogKeychainBackupDiffDelegate>* delegate;
@end
