//
//  Setting.m
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

#import "Setting.h"
#import "PinCodeSetting.h"
#import "UserDefaultsUtil.h"
#import "NSDictionary+Fromat.h"
#import "SelectViewController.h"
#import "ImportPrivateKeySetting.h"
#import "DialogEditPassword.h"
#import "QrCodeViewController.h"
#import <bitheri/BTAddressManager.h>
#import <Bitheri/BTHDMBid.h>
#import "DialogProgress.h"
#import "AdvanceViewController.h"
#import "DialogAlert.h"
#import "PeerUtil.h"
#import "BTQRCodeUtil.h"
#import "ReloadTxSetting.h"
#import "ImportBip38PrivateKeySetting.h"
#import "UnitUtil.h"
#import "KeychainSetting.h"
#import "MessageSigningSetting.h"
#import "HDMRecoverSetting.h"
#import "HDMResetServerPasswordUtil.h"
#import "AppDelegate.h"
#import "UIBaseUtil.h"
#import "IOS7ContainerViewController.h"
#import "PaymentAddressSetting.h"

@implementation Setting

static Setting *ExchangeSetting;
static Setting *MarketSetting;
static Setting *BitcoinUnitSetting;
static Setting *TransactionFeeSetting;
static Setting *NetworkSetting;
static Setting *AvatarSetting;
static Setting *CheckSetting;
static Setting *EditPasswordSetting;
static Setting *ColdMonitorSetting;
static Setting *AdvanceSetting;
static Setting *reloadTxsSetting;
static Setting *RCheckSetting;
static Setting *QrCodeQualitySetting;
static Setting *TrashCanSetting;
static Setting *SwitchToColdSetting;
static Setting *HDMServerPasswordResetSetting;
static Setting *PasswordStrengthCheckSetting;
static Setting *TotalBalanceHideSetting;
static Setting *NetworkMonitorSetting;

- (instancetype)initWithName:(NSString *)name icon:(UIImage *)icon {
    self = [super init];
    if (self) {
        _settingName = name;
        _icon = icon;
    }
    return self;
}

- (void)selection {

}

- (UIImage *)getIcon {
    return _icon;
}

+ (Setting *)getBitcoinUnitSetting {
    if (!BitcoinUnitSetting) {
        BitcoinUnitSetting = [[Setting alloc] initWithName:NSLocalizedString(@"setting_name_bitcoin_unit", nil) icon:nil];

        [BitcoinUnitSetting setGetArrayBlock:^() {
            NSMutableArray *array = [NSMutableArray new];
            [array addObject:[Setting getBitcoinUnitDict:UnitBTC]];
            [array addObject:[Setting getBitcoinUnitDict:Unitbits]];
            return array;
        }];
        [BitcoinUnitSetting setGetValueBlock:^() {
            BitcoinUnit unit = [[UserDefaultsUtil instance] getBitcoinUnit];
            return [Setting attributedStrForBitcoinUnit:unit];
        }];
        [BitcoinUnitSetting setResult:^(NSDictionary *dict) {
            if ([[dict allKeys] containsObject:SETTING_VALUE]) {
                [[UserDefaultsUtil instance] setBitcoinUnit:[dict getIntFromDict:SETTING_VALUE]];
                [[NSNotificationCenter defaultCenter] postNotificationName:BitherBalanceChangedNotification object:nil];
            }
        }];
        __block Setting *sself = BitcoinUnitSetting;
        [BitcoinUnitSetting setSelectBlock:^(UIViewController *controller) {
            SelectViewController *selectController = [controller.storyboard instantiateViewControllerWithIdentifier:@"SelectViewController"];
            UINavigationController *nav = controller.navigationController;
            selectController.setting = sself;
            [nav pushViewController:selectController animated:YES];
        }];
    }
    return BitcoinUnitSetting;
}

+ (NSAttributedString *)attributedStrForBitcoinUnit:(BitcoinUnit)unit {
    CGFloat fontSize = 18;
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_black", [UnitUtil imageNameSlim:unit]]];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@", [UnitUtil unitName:unit]] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]}];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    CGRect bounds = attachment.bounds;
    bounds.size = CGSizeMake(image.size.width * fontSize / image.size.height, fontSize);
    attachment.bounds = bounds;
    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize * 0.5f] range:NSMakeRange(1, 1)];
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    [attr insertAttributedString:attachmentString atIndex:0];
    [attr addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithFloat:-fontSize * 0.09f] range:NSMakeRange(0, 1)];
    return attr;
}

+ (NSDictionary *)getBitcoinUnitDict:(BitcoinUnit)unit {
    BitcoinUnit defaultUnit = [[UserDefaultsUtil instance] getBitcoinUnit];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:[NSNumber numberWithInt:unit] forKey:SETTING_VALUE];
    [dict setObject:[Setting attributedStrForBitcoinUnit:unit] forKey:SETTING_KEY_ATTRIBUTED];
    if (defaultUnit == unit) {
        [dict setObject:[NSNumber numberWithBool:YES] forKey:SETTING_IS_DEFAULT];
    }
    return dict;

}

+ (Setting *)getExchangeSetting {
    if (!ExchangeSetting) {
        ExchangeSetting = [[Setting alloc] initWithName:NSLocalizedString(@"Default Currency", nil) icon:nil];
        [ExchangeSetting setResult:^(NSDictionary *dict) {
            if ([[dict allKeys] containsObject:SETTING_VALUE]) {
                [[UserDefaultsUtil instance] setExchangeType:[dict getIntFromDict:SETTING_VALUE]];
            }
        }];
        [ExchangeSetting setGetValueBlock:^() {
            Currency defaultExchange = [[UserDefaultsUtil instance] getDefaultCurrency];
            return [NSString stringWithFormat:@"%@ %@", [BitherSetting getCurrencySymbol:defaultExchange], [BitherSetting getCurrencyName:defaultExchange]];
        }];
        [ExchangeSetting setGetArrayBlock:^() {
            NSMutableArray *array = [NSMutableArray new];
            [array addObject:[self getExchangeDict:USD]];
            [array addObject:[self getExchangeDict:CNY]];
            [array addObject:[self getExchangeDict:EUR]];
            [array addObject:[self getExchangeDict:GBP]];
            [array addObject:[self getExchangeDict:JPY]];
            [array addObject:[self getExchangeDict:KRW]];
            [array addObject:[self getExchangeDict:CAD]];
            [array addObject:[self getExchangeDict:AUD]];
            return array;

        }];
        __block Setting *sself = ExchangeSetting;
        [ExchangeSetting setSelectBlock:^(UIViewController *controller) {
            SelectViewController *selectController = [controller.storyboard instantiateViewControllerWithIdentifier:@"SelectViewController"];
            UINavigationController *nav = controller.navigationController;
            selectController.setting = sself;
            [nav pushViewController:selectController animated:YES];

        }];
    }
    return ExchangeSetting;
}

+ (NSDictionary *)getExchangeDict:(Currency)exchangeType {
    Currency defaultExchange = [[UserDefaultsUtil instance] getDefaultCurrency];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:[NSNumber numberWithInt:exchangeType] forKey:SETTING_VALUE];
    [dict setObject:[NSString stringWithFormat:@"%@ %@", [BitherSetting getCurrencySymbol:exchangeType], [BitherSetting getCurrencyName:exchangeType]] forKey:SETTING_KEY];
    if (defaultExchange == exchangeType) {
        [dict setObject:[NSNumber numberWithBool:YES] forKey:SETTING_IS_DEFAULT];
    }
    return dict;

}

+ (Setting *)getMarketSetting {
    if (!MarketSetting) {
        Setting *setting = [[Setting alloc] initWithName:NSLocalizedString(@"Default Exchange", nil) icon:nil];

        [setting setGetValueBlock:^() {
            return [GroupUtil getMarketName:[[UserDefaultsUtil instance] getDefaultMarket]];
        }];
        [setting setGetArrayBlock:^() {
            MarketType defaultMarket = [[UserDefaultsUtil instance] getDefaultMarket];
            NSMutableArray *array = [NSMutableArray new];
            for (int i = BITSTAMP; i <= MARKET796; i++) {
                NSMutableDictionary *dict = [NSMutableDictionary new];
                [dict setObject:[NSNumber numberWithInt:i] forKey:SETTING_VALUE];
                [dict setObject:[GroupUtil getMarketName:i] forKey:SETTING_KEY];
                if (i == defaultMarket) {
                    [dict setObject:[NSNumber numberWithBool:YES] forKey:SETTING_IS_DEFAULT];
                }
                [array addObject:dict];
            }
            return array;
        }];
        [setting setResult:^(NSDictionary *dict) {
            if ([[dict allKeys] containsObject:SETTING_VALUE]) {
                [[UserDefaultsUtil instance] setMarket:[dict getIntFromDict:SETTING_VALUE]];
            }
        }];

        __block Setting *sself = setting;
        [setting setSelectBlock:^(UIViewController *controller) {
            SelectViewController *selectController = [controller.storyboard instantiateViewControllerWithIdentifier:@"SelectViewController"];
            UINavigationController *nav = controller.navigationController;
            selectController.setting = sself;
            [nav pushViewController:selectController animated:YES];

        }];
        MarketSetting = setting;
    }
    return MarketSetting;
}

+ (Setting *)getTransactionFeeSetting {
    if (!TransactionFeeSetting) {
        Setting *setting = [[Setting alloc] initWithName:NSLocalizedString(@"Default Transaction Fee", nil) icon:nil];
        [setting setGetValueBlock:^() {
            return [BitherSetting getTransactionFeeMode:[[UserDefaultsUtil instance] getTransactionFeeMode]];
        }];
        [setting setGetArrayBlock:^() {
            NSMutableArray *array = [NSMutableArray new];
            [array addObject:[self getTransactionFeeDict:High]];
            [array addObject:[self getTransactionFeeDict:Normal]];
            [array addObject:[self getTransactionFeeDict:Low]];
            return array;

        }];
        [setting setResult:^(NSDictionary *dict) {
            if ([[dict allKeys] containsObject:SETTING_VALUE]) {
                [[UserDefaultsUtil instance] setTransactionFeeMode:[dict getIntFromDict:SETTING_VALUE]];
            }
        }];
        __block Setting *sself = setting;
        [setting setSelectBlock:^(UIViewController *controller) {
            SelectViewController *selectController = [controller.storyboard instantiateViewControllerWithIdentifier:@"SelectViewController"];
            UINavigationController *nav = controller.navigationController;
            selectController.setting = sself;
            [nav pushViewController:selectController animated:YES];

        }];
        TransactionFeeSetting = setting;
    }
    return TransactionFeeSetting;
}

+ (NSDictionary *)getTransactionFeeDict:(TransactionFeeMode)transcationFeeMode {
    TransactionFeeMode defaultTxFeeMode = [[UserDefaultsUtil instance] getTransactionFeeMode];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:[NSNumber numberWithInt:transcationFeeMode] forKey:SETTING_VALUE];
    [dict setObject:[BitherSetting getTransactionFeeMode:transcationFeeMode] forKey:SETTING_KEY];
    if (defaultTxFeeMode == transcationFeeMode) {
        [dict setObject:[NSNumber numberWithBool:YES] forKey:SETTING_IS_DEFAULT];
    }
    return dict;

}

+ (Setting *)getNetworkSetting {
    if (!NetworkSetting) {
        Setting *setting = [[Setting alloc] initWithName:NSLocalizedString(@"Network Setting", nil) icon:nil];
        [setting setGetValueBlock:^() {
            BOOL syncOnlyWifi = [[UserDefaultsUtil instance] getSyncBlockOnlyWifi];
            return [self getSyncName:syncOnlyWifi];

        }];
        [setting setGetArrayBlock:^() {
            NSMutableArray *array = [NSMutableArray new];
            [array addObject:[self getSyncOnlyWifiDict:NO]];
            [array addObject:[self getSyncOnlyWifiDict:YES]];
            return array;
        }];

        [setting setResult:^(NSDictionary *dict) {
            if ([[dict allKeys] containsObject:SETTING_VALUE]) {
                [[UserDefaultsUtil instance] setSyncBlockOnlyWifi:[dict getBoolFromDict:SETTING_VALUE]];
                [[PeerUtil instance] startPeer];
            }
        }];
        __block Setting *sself = setting;
        [setting setSelectBlock:^(UIViewController *controller) {
            SelectViewController *selectController = [controller.storyboard instantiateViewControllerWithIdentifier:@"SelectViewController"];
            UINavigationController *nav = controller.navigationController;
            selectController.setting = sself;
            [nav pushViewController:selectController animated:YES];

        }];
        NetworkSetting = setting;
    }
    return NetworkSetting;
}

+ (NSDictionary *)getSyncOnlyWifiDict:(BOOL)syncOnlyWifi {
    BOOL defaultSyncOnlyWifi = [[UserDefaultsUtil instance] getSyncBlockOnlyWifi];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:[NSNumber numberWithBool:syncOnlyWifi] forKey:SETTING_VALUE];
    [dict setObject:[self getSyncName:syncOnlyWifi] forKey:SETTING_KEY];
    if (defaultSyncOnlyWifi == syncOnlyWifi) {
        [dict setObject:[NSNumber numberWithBool:YES] forKey:SETTING_IS_DEFAULT];
    }
    return dict;

}

+ (NSString *)getSyncName:(BOOL)syncOnlyWifi {
    if (syncOnlyWifi) {
        return NSLocalizedString(@"Sync over wifi only", nil);
    } else {
        return NSLocalizedString(@"Sync always", nil);
    }


}

+ (Setting *)getAdvanceSetting {
    if (!AdvanceSetting) {
        Setting *setting = [[Setting alloc] initWithName:NSLocalizedString(@"Advance Options", nil) icon:[UIImage imageNamed:@"advance_button_icon"]];
        [setting setSelectBlock:^(UIViewController *controller) {
            AdvanceViewController *advanceController = [controller.storyboard instantiateViewControllerWithIdentifier:@"AdvanceViewController"];
            advanceController.settings = [Setting advanceSettings];
            UINavigationController *nav = controller.navigationController;
            [nav pushViewController:advanceController animated:YES];

        }];
        AdvanceSetting = setting;
    }
    return AdvanceSetting;

}

+ (Setting *)getAvatarSetting {
    if (!AvatarSetting) {
        Setting *setting = [[Setting alloc] initWithName:NSLocalizedString(@"Set Avatar", nil) icon:[UIImage imageNamed:@"avatar_button_icon"]];
        [setting setSelectBlock:^(UIViewController *controller) {

        }];
        AvatarSetting = setting;
    }
    return AvatarSetting;

}

+ (Setting *)getCheckSetting {
    if (!CheckSetting) {
        Setting *setting = [[Setting alloc] initWithName:NSLocalizedString(@"Check Private Keys", nil) icon:[UIImage imageNamed:@"check_button_icon"]];
        [setting setSelectBlock:^(UIViewController *controller) {
            if ([BTAddressManager instance].privKeyAddresses.count == 0 && ![BTAddressManager instance].hasHDMKeychain && ![BTAddressManager instance].hasHDAccountHot) {
                if ([controller respondsToSelector:@selector(showMsg:)]) {
                    [controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"No private keys", nil)];
                }
                return;
            }
            HotCheckPrivateKeyViewController *hotCheck = [controller.storyboard instantiateViewControllerWithIdentifier:@"HotCheckPrivateKeyViewController"];
            UINavigationController *nav = controller.navigationController;
            [nav pushViewController:hotCheck animated:YES];


        }];
        CheckSetting = setting;
    }
    return CheckSetting;

}

+ (Setting *)getEditPasswordSetting {
    if (!EditPasswordSetting) {
        Setting *setting = [[Setting alloc] initWithName:NSLocalizedString(@"Change Password", nil) icon:[UIImage imageNamed:@"edit_password_button_icon"]];
        [setting setSelectBlock:^(UIViewController *controller) {
            if (![BTPasswordSeed getPasswordSeed]) {
                if ([controller respondsToSelector:@selector(showMsg:)]) {
                    [controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"No private keys", nil)];
                }
                return;
            }
            if ([controller conformsToProtocol:@protocol(DialogEditPasswordDelegate)]) {
                [[[DialogEditPassword alloc] initWithDelegate:(NSObject <DialogEditPasswordDelegate> *) controller] showInWindow:controller.view.window];
            }
        }];
        EditPasswordSetting = setting;
    }
    return EditPasswordSetting;
}

+ (Setting *)getColdMonitorSetting {
    if (!ColdMonitorSetting) {
        ColdMonitorSetting = [[Setting alloc] initWithName:NSLocalizedString(@"Watch Only QR Code", nil) icon:[UIImage imageNamed:@"qr_code_button_icon"]];
        [ColdMonitorSetting setSelectBlock:^(UIViewController *controller) {
            NSArray *addresses = [BTAddressManager instance].privKeyAddresses;
            NSMutableArray *pubKeys = [[NSMutableArray alloc] init];
            for (BTAddress *a in addresses) {
                NSString *pubStr = @"";
                if (a.isFromXRandom) {
                    pubStr = XRANDOM_FLAG;
                }
                pubStr = [pubStr stringByAppendingString:[NSString hexWithData:a.pubKey]];
                [pubKeys addObject:pubStr];
            }
            QrCodeViewController *qrCtr = [controller.storyboard instantiateViewControllerWithIdentifier:@"QrCode"];
            qrCtr.content = [BTQRCodeUtil joinedQRCode:pubKeys];
            qrCtr.qrCodeTitle = NSLocalizedString(@"Watch Only QR Code", nil);
            qrCtr.qrCodeMsg = NSLocalizedString(@"Scan with Bither Hot to watch Bither Cold", nil);
            [controller.navigationController pushViewController:qrCtr animated:YES];
        }];
    }
    return ColdMonitorSetting;
}

+ (Setting *)getRCheckSetting {
    if (!RCheckSetting) {
        RCheckSetting = [[Setting alloc] initWithName:NSLocalizedString(@"setting_name_rcheck", nil) icon:[UIImage imageNamed:@"rcheck_button_icon"]];
        [RCheckSetting setSelectBlock:^(UIViewController *controller) {
            if ([BTAddressManager instance].allAddresses.count > 0) {
                [controller.navigationController pushViewController:[controller.storyboard instantiateViewControllerWithIdentifier:@"rcheck"] animated:YES];
            } else {
                if ([controller respondsToSelector:@selector(showMsg:)]) {
                    [controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"rcheck_no_address", nil) afterDelay:0];
                }
            }
        }];
    }
    return RCheckSetting;
}

+ (Setting *)getTrashCanSetting {
    if (!TrashCanSetting) {
        TrashCanSetting = [[Setting alloc] initWithName:NSLocalizedString(@"trash_can", nil) icon:[UIImage imageNamed:@"trash_can_button_icon"]];
        [TrashCanSetting setSelectBlock:^(UIViewController *controller) {
            if ([BTAddressManager instance].trashAddresses.count > 0) {
                [controller.navigationController pushViewController:[controller.storyboard instantiateViewControllerWithIdentifier:@"trash_can"] animated:YES];
            } else {
                if ([controller respondsToSelector:@selector(showMsg:)]) {
                    [controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"trash_can_empty", nil) afterDelay:0];
                }
            }
        }];
    }
    return TrashCanSetting;
}

+ (Setting *)getSwitchToColdSetting {
    if (!SwitchToColdSetting) {
        SwitchToColdSetting = [[Setting alloc] initWithName:NSLocalizedString(@"launch_sequence_switch_to_cold", nil) icon:nil];
        [SwitchToColdSetting setSelectBlock:^(UIViewController *controller) {
            if ([BTAddressManager instance].allAddresses.count == 0) {
                [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"launch_sequence_switch_to_cold_warn", nil) confirm:^{
                    [[BTSettings instance] setAppMode:COLD];
                    [controller presentViewController:[controller.storyboard instantiateViewControllerWithIdentifier:@"ChooseModeViewController"] animated:YES completion:^{

                    }];
                }                              cancel:nil] showInWindow:controller.view.window];
            }
        }];
    }
    return SwitchToColdSetting;
}

+ (Setting *)getQrCodeQualitySetting {
    if (!QrCodeQualitySetting) {
        Setting *setting = [[Setting alloc] initWithName:NSLocalizedString(@"qr_code_quality_setting_name", nil) icon:nil];
        [setting setGetValueBlock:^() {
            QRQuality q = [BTQRCodeUtil qrQuality];
            return [self getQrCodeQualityName:q];
        }];
        [setting setGetArrayBlock:^() {
            NSMutableArray *array = [NSMutableArray new];
            [array addObject:[self getQrCodeQualityDict:NORMAL]];
            [array addObject:[self getQrCodeQualityDict:LOW]];
            return array;
        }];

        [setting setResult:^(NSDictionary *dict) {
            if ([[dict allKeys] containsObject:SETTING_VALUE]) {
                [BTQRCodeUtil setQrQuality:[dict getIntFromDict:SETTING_VALUE]];
            }
        }];
        __block Setting *sself = setting;
        [setting setSelectBlock:^(UIViewController *controller) {
            SelectViewController *selectController = [controller.storyboard instantiateViewControllerWithIdentifier:@"SelectViewController"];
            UINavigationController *nav = controller.navigationController;
            selectController.setting = sself;
            [nav pushViewController:selectController animated:YES];
        }];
        QrCodeQualitySetting = setting;
    }
    return QrCodeQualitySetting;
}

+ (Setting *)getHDMServerPasswordResetSetting {
    if (!HDMServerPasswordResetSetting) {
        Setting *setting = [[Setting alloc] initWithName:NSLocalizedString(@"hdm_reset_server_password_setting_name", nil) icon:nil];
        [setting setSelectBlock:^(UIViewController *controller) {
            [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"hdm_reset_server_password_confirm", nil) confirm:^{
                __block DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
                [dp showInWindow:controller.view.window completion:^{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        __block BOOL result = [[[HDMResetServerPasswordUtil alloc] initWithViewController:controller andDialogProgress:dp] changeServerPassword];
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [dp dismissWithCompletion:^{
                                if (result) {
                                    if ([controller respondsToSelector:@selector(showBannerWithMessage:)]) {
                                        [controller performSelector:@selector(showBannerWithMessage:) withObject:NSLocalizedString(@"hdm_reset_server_password_success", nil)];
                                    }
                                }
                            }];
                        });
                    });
                }];
            }                              cancel:nil] showInWindow:controller.view.window];
        }];
        HDMServerPasswordResetSetting = setting;
    }
    return HDMServerPasswordResetSetting;
}

+ (Setting *)getPasswordStrengthSetting {
    if (!PasswordStrengthCheckSetting) {
        Setting *setting = [[Setting alloc] initWithName:NSLocalizedString(@"password_strength_check", nil) icon:nil];
        [setting setGetValueBlock:^() {
            if ([[UserDefaultsUtil instance] getPasswordStrengthCheck]) {
                return NSLocalizedString(@"password_strength_check_on", nil);
            } else {
                return NSLocalizedString(@"password_strength_check_off", nil);
            }
        }];
        [setting setGetArrayBlock:^() {
            BOOL check = [[UserDefaultsUtil instance] getPasswordStrengthCheck];
            NSMutableArray *array = [NSMutableArray new];
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:[NSNumber numberWithBool:YES] forKey:SETTING_VALUE];
            [dict setObject:NSLocalizedString(@"password_strength_check_on", nil) forKey:SETTING_KEY];
            [dict setObject:[NSNumber numberWithBool:check] forKey:SETTING_IS_DEFAULT];
            [array addObject:dict];

            dict = [NSMutableDictionary new];
            [dict setObject:[NSNumber numberWithBool:NO] forKey:SETTING_VALUE];
            [dict setObject:NSLocalizedString(@"password_strength_check_off", nil) forKey:SETTING_KEY];
            [dict setObject:[NSNumber numberWithBool:!check] forKey:SETTING_IS_DEFAULT];
            [array addObject:dict];

            return array;
        }];

        [setting setResult:^(NSDictionary *dict) {
            if ([[dict allKeys] containsObject:SETTING_VALUE]) {
                BOOL check = [dict getBoolFromDict:SETTING_VALUE];
                if (check) {
                    [[UserDefaultsUtil instance] setPasswordStrengthCheck:check];
                } else {
                    UIWindow *window = ApplicationDelegate.window;
                    __block AdvanceViewController *a = nil;
                    UINavigationController *nav = nil;
                    if ([window.topViewController isKindOfClass:[UINavigationController class]]) {
                        nav = window.topViewController;
                    } else if ([window.topViewController isKindOfClass:[IOS7ContainerViewController class]]) {
                        IOS7ContainerViewController *c = window.topViewController;
                        if ([c.controller isKindOfClass:[UINavigationController class]]) {
                            nav = c.controller;
                        }
                    }
                    if (nav) {
                        for (NSUInteger index = nav.viewControllers.count - 1; index >= MAX(0, nav.viewControllers.count - 2); index--) {
                            if ([nav.viewControllers[index] isKindOfClass:[AdvanceViewController class]]) {
                                a = nav.viewControllers[index];
                            }
                        }
                    }
                    [[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"password_strength_check_off_warn", nil) confirm:^{
                        [[UserDefaultsUtil instance] setPasswordStrengthCheck:NO];
                        if (a) {
                            [a reload];
                        }
                    }                              cancel:nil] showInWindow:window];
                }
            }
        }];
        __block Setting *a = setting;
        [setting setSelectBlock:^(UIViewController *controller) {
            SelectViewController *selectController = [controller.storyboard instantiateViewControllerWithIdentifier:@"SelectViewController"];
            UINavigationController *nav = controller.navigationController;
            selectController.setting = a;
            [nav pushViewController:selectController animated:YES];
        }];
        PasswordStrengthCheckSetting = setting;
    }
    return PasswordStrengthCheckSetting;
}

+ (NSDictionary *)getQrCodeQualityDict:(QRQuality)quality {
    QRQuality q = [BTQRCodeUtil qrQuality];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:[NSNumber numberWithInteger:quality] forKey:SETTING_VALUE];
    [dict setObject:[self getQrCodeQualityName:quality] forKey:SETTING_KEY];
    if (q == quality) {
        [dict setObject:[NSNumber numberWithBool:YES] forKey:SETTING_IS_DEFAULT];
    }
    return dict;
}

+ (NSString *)getQrCodeQualityName:(QRQuality)quality {
    switch (quality) {
        case LOW:
            return NSLocalizedString(@"qr_code_quality_setting_low", nil);
        case NORMAL:
        default:
            return NSLocalizedString(@"qr_code_quality_setting_normal", nil);
    }
}

+ (Setting *)getTotalBalanceHideSetting {
    if (!TotalBalanceHideSetting) {
        TotalBalanceHideSetting = [[Setting alloc] initWithName:NSLocalizedString(@"total_balance_hide_setting_name", nil) icon:nil];
        [TotalBalanceHideSetting setGetValueBlock:^() {
            return [TotalBalanceHideUtil displayName:[UserDefaultsUtil instance].getTotalBalanceHide];
        }];
        [TotalBalanceHideSetting setGetArrayBlock:^() {
            TotalBalanceHide hide = [[UserDefaultsUtil instance] getTotalBalanceHide];
            NSMutableArray *array = [NSMutableArray new];
            for(TotalBalanceHide h = TotalBalanceShowAll; h <= TotalBalanceHideAll; h++){
                NSMutableDictionary *dict = [NSMutableDictionary new];
                [dict setObject:[NSNumber numberWithInt:h] forKey:SETTING_VALUE];
                [dict setObject:[TotalBalanceHideUtil displayName:h] forKey:SETTING_KEY];
                [dict setObject:[NSNumber numberWithBool:h == hide] forKey:SETTING_IS_DEFAULT];
                [array addObject:dict];
            }
            return array;
        }];
        [TotalBalanceHideSetting setResult:^(NSDictionary *dict) {
            TotalBalanceHide h = [dict getIntFromDict:SETTING_VALUE];
            [[UserDefaultsUtil instance] setTotalBalanceHide:h];
        }];
        __block Setting *a = TotalBalanceHideSetting;
        [TotalBalanceHideSetting setSelectBlock:^(UIViewController *controller) {
            SelectViewController *selectController = [controller.storyboard instantiateViewControllerWithIdentifier:@"SelectViewController"];
            UINavigationController *nav = controller.navigationController;
            selectController.setting = a;
            [nav pushViewController:selectController animated:YES];
        }];
    }
    return TotalBalanceHideSetting;
}

+ (Setting*)getNetworkMonitorSetting {
    if (!NetworkMonitorSetting) {
        NetworkMonitorSetting = [[Setting alloc]initWithName:NSLocalizedString(@"network_monitor_title", nil) icon:nil];
        [NetworkMonitorSetting setSelectBlock:^(UIViewController *controller) {
            UIViewController *c = [controller.storyboard instantiateViewControllerWithIdentifier:@"NetworkMonitorViewController"];
            UINavigationController *nav = controller.navigationController;
            [nav pushViewController:c animated:YES];
        }];
    }
    return NetworkMonitorSetting;
}

+ (NSArray *)advanceSettings {
    NSMutableArray *array = [NSMutableArray new];
    if ([[BTSettings instance] getAppMode] == HOT) {
        [array addObject:[Setting getNetworkSetting]];
    }
    [array addObject:[Setting getEditPasswordSetting]];
    [array addObject:[PinCodeSetting getPinCodeSetting]];
    [array addObject:[Setting getQrCodeQualitySetting]];
    [array addObject:[ImportPrivateKeySetting getImportPrivateKeySetting]];
    [array addObject:[ImportBip38PrivateKeySetting getImportBip38PrivateKeySetting]];
    if ([[BTSettings instance] getAppMode] == HOT && [[BTAddressManager instance] hdmKeychain] == nil) {
        [array addObject:[HDMRecoverSetting getHDMRecoverSetting]];
    }
    if ([[BTSettings instance] getAppMode] == HOT && [BTHDMBid getHDMBidFromDb]) {
        [array addObject:[Setting getHDMServerPasswordResetSetting]];
    }
    [array addObject:[MessageSigningSetting getMessageSigningSetting]];
    [array addObject:[Setting getPasswordStrengthSetting]];
    if ([[BTSettings instance] getAppMode] == HOT){
        [array addObject:[Setting getTotalBalanceHideSetting]];
    }
    if ([[BTSettings instance] getAppMode] == HOT && ([BTAddressManager instance].allAddresses.count > 0 || [BTAddressManager instance].hasHDAccountHot)) {
        [array addObject:[PaymentAddressSetting setting]];
    }
    [array addObject:[Setting getTrashCanSetting]];
    if ([[BTSettings instance] getAppMode] == HOT) {
        [array addObject:[ReloadTxSetting getReloadTxsSetting]];
    }
    if ([[BTSettings instance] getAppMode] == HOT) {
        [array addObject:[Setting getNetworkMonitorSetting]];
    }
//    if ([[BTSettings instance] getAppMode] == HOT) {
//        [array addObject:[Setting getKeychainSetting]];
//    }
    return array;
}

+ (Setting *)getKeychainSetting; {
    return [KeychainSetting getKeychainSetting];
}
@end

