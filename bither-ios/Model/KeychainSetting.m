//
//  KeychainSetting.m
//  bither-ios
//
//  Created by ZhouQi on 14/11/22.
//  Copyright (c) 2014年 ZhouQi. All rights reserved.
//

#import "KeychainSetting.h"

static Setting* keychainSetting;

@implementation KeychainSetting

//+(Setting *)getAvatarSetting{
//    if(!avatarSetting){
//        UIImage *image=[UIImage imageNamed:@"avatar_button_icon"];
//        
//        AvatarSetting*  sAvatarSetting=[[AvatarSetting alloc] initWithName:NSLocalizedString(@"Set Avatar", nil) icon:image];
//        __weak AvatarSetting* sself=sAvatarSetting;
//        [sAvatarSetting setSelectBlock:^(UIViewController * controller){
//            sself.controller=controller;
//            UIActionSheet *actionSheet=nil;
//            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
//                
//                actionSheet=[[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Set Avatar", nil)
//                                                       delegate:sself                                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
//                                         destructiveButtonTitle:nil
//                                              otherButtonTitles:NSLocalizedString(@"From Camera", nil),NSLocalizedString(@"From Gallery", nil),nil];
//            }else{
//                actionSheet=[[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Set Avatar", nil)
//                                                       delegate:sself                                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
//                                         destructiveButtonTitle:nil
//                                              otherButtonTitles:NSLocalizedString(@"From Gallery", nil),nil];
//            }
//            
//            actionSheet.actionSheetStyle=UIActionSheetStyleDefault;
//            [actionSheet showInView:controller.navigationController.view];
//        }];
//        avatarSetting = sAvatarSetting;
//    }
//    return avatarSetting;
//}

@end
