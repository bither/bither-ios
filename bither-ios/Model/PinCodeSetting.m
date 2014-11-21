//
//  PinCodeSetting.m
//  bither-ios
//
//  Created by noname on 14-11-21.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "PinCodeSetting.h"
#import "UserDefaultsUtil.h"

@interface PinCodeSetting(){
    
}
@property (weak) UIViewController* controller;
@end

static PinCodeSetting* S;
@implementation PinCodeSetting

+(PinCodeSetting*)getPinCodeSetting{
    if(!S){
        S = [[PinCodeSetting alloc]init];
    }
    return S;
}

-(instancetype)init{
    self = [super initWithName:NSLocalizedString(@"pin_code_setting_name", nil) icon:nil];
    if(self){
        __weak PinCodeSetting* s = self;
        [self setSelectBlock:^(UIViewController * controller){
            s.controller = controller;
            [s show];
        }];
    }
    return self;
}

-(void)show{
    UIActionSheet* actionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"pin_code_setting_name", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if([[UserDefaultsUtil instance]hasPinCode]){
        [actionSheet addButtonWithTitle:NSLocalizedString(@"pin_code_setting_close", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"pin_code_setting_change", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        actionSheet.cancelButtonIndex = 2;
    }else{
        [actionSheet addButtonWithTitle:NSLocalizedString(@"pin_code_setting_open", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        actionSheet.cancelButtonIndex = 1;
    }
    [actionSheet showInView:self.controller.view.window];
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex < 0){
        return;
    }
    UIViewController *vc;
    if([[UserDefaultsUtil instance]hasPinCode]){
        switch (buttonIndex) {
            case 0:
                vc = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"PinCodeDisable"];
                break;
            case 1:
                vc = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"PinCodeChange"];
                break;
            default:
                break;
        }
    }else{
        switch (buttonIndex) {
            case 0:
                vc = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"PinCodeEnable"];
                break;
            default:
                break;
        }
    }
    if(vc){
        [self.controller.navigationController pushViewController:vc animated:YES];
    }
}

@end
