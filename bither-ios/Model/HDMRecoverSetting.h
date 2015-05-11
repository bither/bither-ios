#import <Foundation/Foundation.h>
#import "Setting.h"


@interface HDMRecoverSetting : Setting

@property(weak) UIViewController *controller;

+ (Setting *)getHDMRecoverSetting;

@end