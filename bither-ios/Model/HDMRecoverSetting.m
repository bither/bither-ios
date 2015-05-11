#import "HDMRecoverSetting.h"
#import "HDMKeychainRecoverUtil.h"

static Setting *hdmRecoverSetting;
static HDMKeychainRecoverUtil *hdmKeychainRecoverUtil;

@implementation HDMRecoverSetting {

}
+ (Setting *)getHDMRecoverSetting {
    if (!hdmRecoverSetting) {
        hdmRecoverSetting = [[HDMRecoverSetting alloc] initWithName:NSLocalizedString(@"address_group_hdm_recovery", nil) icon:nil];
        [hdmRecoverSetting setSelectBlock:^(UIViewController *controller) {
            hdmKeychainRecoverUtil = [[HDMKeychainRecoverUtil alloc] initWithViewContoller:controller];
            if ([hdmKeychainRecoverUtil canRecover]) {
                [hdmKeychainRecoverUtil revovery];
            }


        }];


    }
    return hdmRecoverSetting;

}
@end