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
#import "UserDefaultsUtil.h"
#import "NSDictionary+Fromat.h"
#import "SelectViewController.h"
#import "ImportPrivateKeySetting.h"
#import "DialogEditPassword.h"
#import "ScanQrCodeTransportViewController.h"
#import "SignTransactionViewController.h"
#import "QrCodeViewController.h"
#import "QRCodeTxTransport.h"
#import <bitheri/BTAddressManager.h>
#import "DialogProgress.h"
#import "KeyUtil.h"
#import "SendViewController.h"
#import "UnsignedTransactionViewController.h"
#import "BTSettings.h"
#import "AdvanceViewController.h"
#import "DialogAlert.h"
#import "BTTxProvider.h"
#import "PeerUtil.h"
#import "TransactionsUtil.h"
#import "BTQRCodeUtil.h"
#import "ReloadTxSetting.h"
#import "ImportPrivateKeySetting.h"



@implementation Setting

static Setting* ExchangeSetting;
static Setting* MarketSetting;
static Setting* TransactionFeeSetting;
static Setting* NetworkSetting;
static Setting* AvatarSetting;
static Setting* CheckSetting;
static Setting* EditPasswordSetting;
static Setting* ColdMonitorSetting;
static Setting* AdvanceSetting;
static Setting* reloadTxsSetting;

-(instancetype)initWithName:(NSString *)name  icon:(NSString *)icon {
    self=[super init];
    if (self) {
        _settingName=name;
        _icon=icon;

    }
    
    return self;
}
-(void)selection{
    
}

+(Setting * )getExchangeSetting{
    if(!ExchangeSetting){
        ExchangeSetting =[[Setting alloc] initWithName:NSLocalizedString(@"Default Currency", nil)  icon:nil ];
        [ExchangeSetting setResult:^(NSDictionary * dict){
            if ([[dict  allKeys] containsObject:SETTING_VALUE]) {
                [[UserDefaultsUtil instance] setExchangeType:[dict getIntFromDict:SETTING_VALUE]];
            }
        }];
        [ExchangeSetting setGetValueBlock:^(){
             ExchangeType defaultExchange=[[UserDefaultsUtil instance] getDefaultExchangeType];
            return [BitherSetting getExchangeName:defaultExchange];
        }];
        [ExchangeSetting setGetArrayBlock:^(){
            NSMutableArray * array=[NSMutableArray new];
            [array addObject:[self getExchangeDict:USD]];
            [array addObject:[self getExchangeDict:CNY]];
            return array;
            
        }];
        __block Setting * sself= ExchangeSetting;
        [ExchangeSetting setSelectBlock:^(UIViewController * controller){
            SelectViewController *selectController = [controller.storyboard instantiateViewControllerWithIdentifier:@"SelectViewController"];UINavigationController *nav = controller.navigationController;
            selectController.setting=sself;
            [nav pushViewController:selectController animated:YES];
            
        }];
    }
    return ExchangeSetting;
}
+(NSDictionary *)getExchangeDict:(ExchangeType)exchangeType{
    ExchangeType defaultExchange=[[UserDefaultsUtil instance] getDefaultExchangeType];
    NSMutableDictionary *dict=[NSMutableDictionary new];
    [dict setObject:[NSNumber numberWithInt:exchangeType] forKey:SETTING_VALUE];
    [dict setObject:[BitherSetting getExchangeName:exchangeType] forKey:SETTING_KEY];
    if (defaultExchange==exchangeType) {
        [dict setObject:[NSNumber numberWithBool:YES] forKey:SETTING_IS_DEFAULT];
    }
    return dict;
    
}
+(Setting * )getMarketSetting{
    if(!MarketSetting){
        Setting * setting=[[Setting alloc] initWithName:NSLocalizedString(@"Default Exchange", nil) icon:nil ];
        
        [setting setGetValueBlock:^(){
            return [BitherSetting getMarketName:[[UserDefaultsUtil instance] getDefaultMarket]];
        }];
        [setting setGetArrayBlock:^(){
            MarketType defaultMarket=[[UserDefaultsUtil instance] getDefaultMarket];
            NSMutableArray * array=[NSMutableArray new];
            for (int i=BITSTAMP; i<=CHBTC; i++) {
                NSMutableDictionary *dict=[NSMutableDictionary new];
                [dict setObject:[NSNumber numberWithInt:i] forKey:SETTING_VALUE];
                [dict setObject:[BitherSetting getMarketName:i] forKey:SETTING_KEY];
                if (i==defaultMarket) {
                    [dict setObject:[NSNumber numberWithBool:YES] forKey:SETTING_IS_DEFAULT];
                }
                [array addObject:dict];
            }
            return array;
            
        }];
        [setting setResult:^(NSDictionary * dict){
            if ([[dict  allKeys] containsObject:SETTING_VALUE]) {
                [[UserDefaultsUtil instance] setMarket:[dict getIntFromDict:SETTING_VALUE]];
            }
        }];
        
        __block Setting * sself=setting;
        [setting setSelectBlock:^(UIViewController * controller){
            SelectViewController *selectController = [controller.storyboard instantiateViewControllerWithIdentifier:@"SelectViewController"];UINavigationController *nav = controller.navigationController;
            selectController.setting=sself;
            [nav pushViewController:selectController animated:YES];
            
        }];
        MarketSetting = setting;
    }
    return MarketSetting;
}

+(Setting * )getTransactionFeeSetting{
    if(!TransactionFeeSetting){
        Setting *  setting=[[Setting alloc] initWithName:NSLocalizedString(@"Default Transaction Fee", nil) icon:nil ];
        [setting setGetValueBlock:^(){
            return [BitherSetting getTransactionFeeMode:[[UserDefaultsUtil instance] getTransactionFeeMode]];
        }];
        [setting setGetArrayBlock:^(){
            NSMutableArray * array=[NSMutableArray new];
            [array addObject:[self getTransactionFeeDict:Normal]];
            [array addObject:[self getTransactionFeeDict:Low]];
            return array;
            
        }];
        [setting setResult:^(NSDictionary * dict){
            if ([[dict  allKeys] containsObject:SETTING_VALUE]) {
                [[UserDefaultsUtil instance] setTransactionFeeMode:[dict getIntFromDict:SETTING_VALUE]];
            }
        }];
        __block Setting * sself=setting;
        [setting setSelectBlock:^(UIViewController * controller){
            SelectViewController *selectController = [controller.storyboard instantiateViewControllerWithIdentifier:@"SelectViewController"];UINavigationController *nav = controller.navigationController;
            selectController.setting=sself;
            [nav pushViewController:selectController animated:YES];
            
        }];
        TransactionFeeSetting = setting;
    }
    return TransactionFeeSetting;
}
+(NSDictionary *)getTransactionFeeDict:(TransactionFeeMode)transcationFeeMode{
    TransactionFeeMode defaultTxFeeMode=[[UserDefaultsUtil instance] getTransactionFeeMode];
    NSMutableDictionary *dict=[NSMutableDictionary new];
    [dict setObject:[NSNumber numberWithInt:transcationFeeMode] forKey:SETTING_VALUE];
    [dict setObject:[BitherSetting getTransactionFeeMode:transcationFeeMode] forKey:SETTING_KEY];
    if (defaultTxFeeMode==transcationFeeMode) {
        [dict setObject:[NSNumber numberWithBool:YES] forKey:SETTING_IS_DEFAULT];
    }
    return dict;
    
}

+(Setting * )getNetworkSetting{
    if(!NetworkSetting){
        Setting *   setting=[[Setting alloc] initWithName:NSLocalizedString(@"Network Setting", nil) icon:nil ];
        [setting setGetValueBlock:^(){
            BOOL syncOnlyWifi=[[UserDefaultsUtil instance] getSyncBlockOnlyWifi];
            return [self getSyncName:syncOnlyWifi];
            
        }];
        [setting setGetArrayBlock:^(){
            NSMutableArray * array=[NSMutableArray new];
            [array addObject:[self getSyncOnlyWifiDict:NO]];
            [array addObject:[self getSyncOnlyWifiDict:YES]];
            return array;
        }];
        
        [setting setResult:^(NSDictionary * dict){
            if ([[dict  allKeys] containsObject:SETTING_VALUE]) {
                [[UserDefaultsUtil instance] setSyncBlockOnlyWifi:[dict getBoolFromDict:SETTING_VALUE]];
            }
        }];
        __block Setting * sself=setting;
        [setting setSelectBlock:^(UIViewController * controller){
            SelectViewController *selectController = [controller.storyboard instantiateViewControllerWithIdentifier:@"SelectViewController"];UINavigationController *nav = controller.navigationController;
            selectController.setting=sself;
            [nav pushViewController:selectController animated:YES];
            
        }];
        NetworkSetting = setting;
    }
    return NetworkSetting;
}

+(NSDictionary *)getSyncOnlyWifiDict:(BOOL)syncOnlyWifi{
    BOOL defaultSyncOnlyWifi=[[UserDefaultsUtil instance] getSyncBlockOnlyWifi];
    NSMutableDictionary *dict=[NSMutableDictionary new];
    [dict setObject:[NSNumber numberWithBool:syncOnlyWifi] forKey:SETTING_VALUE];
    [dict setObject:[self getSyncName:syncOnlyWifi] forKey:SETTING_KEY];
    if (defaultSyncOnlyWifi==syncOnlyWifi) {
        [dict setObject:[NSNumber numberWithBool:YES] forKey:SETTING_IS_DEFAULT];
    }
    return dict;
    
}

+(NSString *)getSyncName:(BOOL)syncOnlyWifi{
    if (syncOnlyWifi) {
        return NSLocalizedString(@"Sync over wifi only", nil);
    }else{
        return NSLocalizedString(@"Sync always", nil);
    }
    

}
+(Setting *)getAdvanceSetting{
    if(!AdvanceSetting){
        Setting * setting=[[Setting alloc] initWithName:NSLocalizedString(@"Advance Options", nil) icon:@"advance_button_icon" ];
        [setting setSelectBlock:^(UIViewController * controller){
            AdvanceViewController *advanceController = [controller.storyboard instantiateViewControllerWithIdentifier:@"AdvanceViewController"];
            advanceController.settings=[Setting advanceSettings];
            UINavigationController *nav = controller.navigationController;
            [nav pushViewController:advanceController animated:YES];
            
        }];
        AdvanceSetting = setting;
    }
    return AdvanceSetting;

}

+(Setting *)getAvatarSetting{
    if(!AvatarSetting){
        Setting * setting=[[Setting alloc] initWithName:NSLocalizedString(@"Set Avatar", nil) icon:@"avatar_button_icon" ];
        [setting setSelectBlock:^(UIViewController * controller){
            
        }];
        AvatarSetting = setting;
    }
    return AvatarSetting;
    
}
+(Setting *)getCheckSetting{
    if(!CheckSetting){
        Setting * setting=[[Setting alloc] initWithName:NSLocalizedString(@"Check Private Keys", nil) icon:@"check_button_icon" ];
        [setting setSelectBlock:^(UIViewController * controller){
            if([BTAddressManager instance].privKeyAddresses.count == 0){
                if([controller respondsToSelector:@selector(showMsg:)]){
                    [controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"No private keys", nil)];
                }
                return;
            }
            HotCheckPrivateKeyViewController  *hotCheck = [controller.storyboard instantiateViewControllerWithIdentifier:@"HotCheckPrivateKeyViewController"];
            UINavigationController *nav = controller.navigationController;
            [nav pushViewController:hotCheck animated:YES];
            
            
        }];
        CheckSetting = setting;
    }
    return CheckSetting;
    
}

+(Setting *)getEditPasswordSetting{
    if(!EditPasswordSetting){
        Setting * setting=[[Setting alloc] initWithName:NSLocalizedString(@"Change Password", nil) icon:@"edit_password_button_icon" ];
        [setting setSelectBlock:^(UIViewController * controller){
            if([BTAddressManager instance].privKeyAddresses.count == 0){
                if([controller respondsToSelector:@selector(showMsg:)]){
                    [controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"No private keys", nil)];
                }
                return;
            }
            if([controller conformsToProtocol:@protocol(DialogEditPasswordDelegate)]){
                [[[DialogEditPassword alloc]initWithDelegate:(NSObject<DialogEditPasswordDelegate>*)controller]showInWindow:controller.view.window];
            }
        }];
        EditPasswordSetting = setting;
    }
    return EditPasswordSetting;
}

+(Setting*)getColdMonitorSetting{
    if(!ColdMonitorSetting){
        ColdMonitorSetting = [[Setting alloc]initWithName:NSLocalizedString(@"Watch Only QR Code", nil) icon:@"qr_code_button_icon"];
        [ColdMonitorSetting setSelectBlock:^(UIViewController * controller){
            NSArray* addresses = [BTAddressManager instance].privKeyAddresses;
            NSMutableArray* pubKeys = [[NSMutableArray alloc]init];
            for(BTAddress* a in addresses){
                [pubKeys addObject:[NSString hexWithData:a.pubKey].uppercaseString];
            }
            QrCodeViewController* qrCtr = [controller.storyboard instantiateViewControllerWithIdentifier:@"QrCode"];
            qrCtr.content =[BTQRCodeUtil joinedQRCode:pubKeys];
            qrCtr.qrCodeTitle = NSLocalizedString(@"Watch Only QR Code", nil);
            qrCtr.qrCodeMsg = NSLocalizedString(@"Scan with Bither Hot to watch Bither Cold", nil);
            [controller.navigationController pushViewController:qrCtr animated:YES];
        }];
    }
    return ColdMonitorSetting;
}

+(NSArray*)advanceSettings{
    NSMutableArray *array = [NSMutableArray new];
    [array addObject:[Setting getEditPasswordSetting]];
    [array addObject:[ImportPrivateKeySetting getImportPrivateKeySetting]];
    if ([[BTSettings instance] getAppMode]==HOT) {
        [array addObject:[ReloadTxSetting getReloadTxsSetting]];
    }
    return array;
}
@end

