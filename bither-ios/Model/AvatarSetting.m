//
//  AvatarSetting.m
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


#import "AvatarSetting.h"

static Setting* avatarSetting;

@implementation AvatarSetting

+(Setting *)getAvatarSetting{
    if(!avatarSetting){
        AvatarSetting*  sAvatarSetting=[[AvatarSetting alloc] initWithName:NSLocalizedString(@"Set Avatar", nil) icon:@"avatar_button_icon" ];
        __weak AvatarSetting* sself=sAvatarSetting;
        [sAvatarSetting setSelectBlock:^(UIViewController * controller){
            sself.controller=controller;
            UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Set Avatar", nil)
                                                                  delegate:sself                                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:NSLocalizedString(@"From Camera", nil),NSLocalizedString(@"From Gallery", nil),nil];
            
            actionSheet.actionSheetStyle=UIActionSheetStyleDefault;
            [actionSheet showInView:controller.navigationController.view];
        }];
        avatarSetting = sAvatarSetting;
    }
    return avatarSetting;
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
    
    }else if(buttonIndex==1){
    
    }
}

@end
