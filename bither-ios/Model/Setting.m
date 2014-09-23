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
#import "ScanPrivateKeyDelegate.h"
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
#import "QRCodeEncodeUtil.h"

@interface SignTransactionScanDelegate : Setting<ScanQrCodeDelegate>
-(instancetype)init;
@property (weak) UIViewController* controller;
@end

@interface ColdWalletCloneSetting : Setting<ScanQrCodeDelegate,DialogPasswordDelegate>
-(instancetype)init;
@property (weak) UIViewController* controller;
@property NSString* scanContent;
@end

@interface CloneQrCodeSetting : Setting<DialogPasswordDelegate>
-(instancetype)init;
@property (weak) UIViewController* controller;
@end

@interface DonationSetting : Setting<UIActionSheetDelegate,SendDelegate>
-(instancetype)init;
@property (weak) UIViewController* controller;
@property NSMutableArray* addresses;
@end

@interface ReloadTxSetting : Setting<DialogPasswordDelegate>
-(void)showDialogPassword;
@property (weak)UIViewController *controller;
@end

@implementation Setting

static Setting* ExchangeSetting;
static Setting* MarketSetting;
static Setting* TransactionFeeSetting;
static Setting* NetworkSetting;
static Setting* AvatarSetting;
static Setting* CheckSetting;
static Setting* EditPasswordSetting;
static Setting* ImportPrivateKeySetting;
static Setting* DonateSetting;
static Setting* SignTransactionSetting;
static Setting* CloneScanSetting;
static Setting* CloneQrSetting;
static Setting* ColdMonitorSetting;
static Setting* AdvanceSetting;
static ReloadTxSetting* reloadTxsSetting;

static double reloadTime;

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


+(Setting *)getImportPrivateKeySetting{
    if(!ImportPrivateKeySetting){
        Setting *  setting=[[Setting alloc] initWithName:NSLocalizedString(@"Import Private Key", nil) icon:nil ];
        
        [setting setSelectBlock:^(UIViewController * controller){
            [ScanPrivateKeyDelegate instance].controller=controller;
            UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Import Private Key", nil)
                                                                  delegate:        [ScanPrivateKeyDelegate instance]
                                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:NSLocalizedString(@"From Private Key QR Code", nil),NSLocalizedString(@"From Private Key Text", nil),nil];
            
            actionSheet.actionSheetStyle=UIActionSheetStyleDefault;
            [actionSheet showInView:controller.navigationController.view];
        }];
        ImportPrivateKeySetting = setting;
    }
    return ImportPrivateKeySetting;
}

+(Setting *)getDonateSetting{
    if(!DonateSetting){
        DonateSetting = [[DonationSetting alloc]init];
    }
    return DonateSetting;
}


+(Setting*)getSignTransactionSetting{
    if(!SignTransactionSetting){
        SignTransactionScanDelegate* setting = [[SignTransactionScanDelegate alloc]init];
        SignTransactionSetting = setting;
    }
    return SignTransactionSetting;
}

+(Setting*)getCloneSetting{
    if([BTAddressManager instance].privKeyAddresses.count > 0){
        if(!CloneQrSetting){
            CloneQrSetting = [[CloneQrCodeSetting alloc]init];
        }
        return CloneQrSetting;
    }else{
        if(!CloneScanSetting){
            CloneScanSetting = [[ColdWalletCloneSetting alloc]init];
        }
        return CloneScanSetting;
    }
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
            qrCtr.content =[QRCodeEncodeUtil joinedQRCode:pubKeys];
            qrCtr.qrCodeTitle = NSLocalizedString(@"Watch Only QR Code", nil);
            qrCtr.qrCodeMsg = NSLocalizedString(@"Scan with Bither Hot to watch Bither Cold", nil);
            [controller.navigationController pushViewController:qrCtr animated:YES];
        }];
    }
    return ColdMonitorSetting;
}

+(Setting *)getReloadTxsSetting{
    if (!reloadTxsSetting) {
     reloadTxsSetting=[[ReloadTxSetting alloc] initWithName:NSLocalizedString(@"Reload Transactions data", nil) icon:nil];

        [reloadTxsSetting setSelectBlock:^(UIViewController * controller){
            if (reloadTime>0&&reloadTime+60*60>(double)[[NSDate new]timeIntervalSince1970]) {
                if([controller respondsToSelector:@selector(showMsg:)]){
                    [controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"You can only reload transactions data in a hour..", nil)];
                }
                
            }else{
                DialogAlert *dialogAlert=[[DialogAlert alloc] initWithMessage:NSLocalizedString(@"Reload Transactions data?\nNeed long time.\nConsume network data.\nRecommand trying only with wrong data.", nil) confirm:^{
                    reloadTxsSetting.controller=controller;
                    [reloadTxsSetting showDialogPassword];
                   
                    
                    
                } cancel:^{
                    
                }];
                [dialogAlert showInWindow:controller.view.window];
            }

        }];
       
        
    }
    return reloadTxsSetting;
}

+(NSArray *)hotSettings{
    NSMutableArray * array=[NSMutableArray new];
    [array addObject:[Setting getExchangeSetting]];
    [array addObject:[Setting getMarketSetting]];
    [array addObject:[Setting getTransactionFeeSetting]];
    [array addObject:[Setting getCheckSetting]];
    [array addObject:[Setting getDonateSetting]];
    [array addObject:[Setting getAdvanceSetting]];
    return array;
}



+(NSArray*)coldSettings{
    NSMutableArray *array = [NSMutableArray new];
    [array addObject:[Setting getSignTransactionSetting]];
    [array addObject:[Setting getCloneSetting]];
    if([BTAddressManager instance].privKeyAddresses.count > 0){
        [array addObject:[Setting getColdMonitorSetting]];
    }
    [array addObject:[Setting getAdvanceSetting]];
    return array; 
}
+(NSArray*)advanceSettings{
    NSMutableArray *array = [NSMutableArray new];
    
    [array addObject:[Setting getEditPasswordSetting]];
    [array addObject:[Setting getImportPrivateKeySetting]];
    if ([[BTSettings instance] getAppMode]==HOT) {
        [array addObject:[Setting getReloadTxsSetting]];
    }
    return array;
}

@end


@implementation SignTransactionScanDelegate

-(instancetype)init{
    self = [super initWithName:NSLocalizedString(@"Sign Transaction", nil) icon:@"scan_button_icon"];
    if(self){
        __weak SignTransactionScanDelegate *d = self;
        [self setSelectBlock:^(UIViewController * controller){
            d.controller = controller;
            ScanQrCodeTransportViewController *scan = [[ScanQrCodeTransportViewController alloc]initWithDelegate:d title:NSLocalizedString(@"Scan Unsigned TX", nil) pageName:NSLocalizedString(@"unsigned tx QR code", nil)];
            [controller presentViewController:scan animated:YES completion:nil];
        }];
    }
    return self;
}

-(void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader{
    QRCodeTxTransport *tx = [QRCodeTxTransport formatQRCodeTransport:result];
    if(tx){
        SignTransactionViewController* signController = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"SignTransaction"];
        signController.tx = tx;
        [self.controller.navigationController pushViewController:signController animated:NO];
    }
    [reader dismissViewControllerAnimated:YES completion:^{
        if(!tx){
            if([self.controller respondsToSelector:@selector(showMsg:)]){
                [self.controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"Scan unsigned transaction failed", nil)];
            }
        }
    }];
}
@end



@implementation ColdWalletCloneSetting

-(instancetype)init{
    self = [super initWithName:NSLocalizedString(@"Cold Wallet Clone", nil) icon:@"scan_button_icon"];
    if(self){
        __weak ColdWalletCloneSetting *d = self;
        [self setSelectBlock:^(UIViewController * controller){
            d.scanContent = nil;
            d.controller = controller;
            ScanQrCodeTransportViewController *scan = [[ScanQrCodeTransportViewController alloc]initWithDelegate:d title:NSLocalizedString(@"Scan The Clone Source", nil) pageName:NSLocalizedString(@"clone QR code", nil)];
            [controller presentViewController:scan animated:YES completion:nil];
        }];
    }
    return self;
}

-(void)handleResult:(NSString *)result byReader:(ScanQrCodeViewController *)reader{
    [reader dismissViewControllerAnimated:YES completion:^{
        if([QRCodeEncodeUtil splitQRCode:result].count % 3 == 0){
            self.scanContent = result;
            DialogPassword *dialog = [[DialogPassword alloc]initWithDelegate:self];
            [dialog showInWindow:self.controller.view.window];
        }else{
            [self showMsg:NSLocalizedString(@"Clone failed.", nil)];
        }
    }];
}

-(void)onPasswordEntered:(NSString*)password{
    DialogProgress* dp = [[DialogProgress alloc]initWithMessage:NSLocalizedString(@"Cloning...", nil)];
    [dp showInWindow:self.controller.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *commponent =[QRCodeEncodeUtil splitQRCode:self.scanContent];
            NSMutableArray* keys = [[NSMutableArray alloc]init];
            for(int i = 0; i < commponent.count; i+=3){
                NSString* s =[QRCodeEncodeUtil joinedQRCode:[commponent subarrayWithRange:NSMakeRange(i, 3)]];                [keys addObject:s];
            }
            BOOL result = [KeyUtil addBitcoinjKey:[keys reverseObjectEnumerator].allObjects withPassphrase:password error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.controller respondsToSelector:@selector(reload)]){
                    [self.controller performSelector:@selector(reload)];
                }
                [dp dismissWithCompletion:^{
                    [self showMsg:result ? NSLocalizedString(@"Clone success.", nil) : NSLocalizedString(@"Clone failed.", nil)];
                }];
            });
        });
    }];
}

-(BOOL)notToCheckPassword{
    return YES;
}

-(NSString*)passwordTitle{
    return NSLocalizedString(@"Enter source password", nil);
}

-(void)showMsg:(NSString*)msg{
    if([self.controller respondsToSelector:@selector(showMsg:)]){
        [self.controller performSelector:@selector(showMsg:) withObject:msg];
    }
}
@end

@implementation CloneQrCodeSetting

-(instancetype)init{
    self = [super initWithName:NSLocalizedString(@"Cold Wallet Clone QR Code", nil) icon:@"qr_code_button_icon"];
    if(self){
        __weak CloneQrCodeSetting *d = self;
        [self setSelectBlock:^(UIViewController * controller){
            d.controller = controller;
            [[[DialogPassword alloc]initWithDelegate:d] showInWindow:controller.view.window];
        }];
    }
    return self;
}

-(void)onPasswordEntered:(NSString *)password{
    NSArray *addresses = [BTAddressManager instance].privKeyAddresses;
    NSMutableArray* keys = [[NSMutableArray alloc]init];
    for(BTAddress* a in addresses){
        [keys addObject:a.encryptPrivKey];
    }
    QrCodeViewController* qrController = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"QrCode"];
    qrController.content =[QRCodeEncodeUtil joinedQRCode:keys];
    qrController.qrCodeTitle = NSLocalizedString(@"Cold Wallet Clone QR Code", nil);
    qrController.qrCodeMsg = NSLocalizedString(@"Scan by clone destination", nil);
    [self.controller.navigationController pushViewController:qrController animated:YES];
}

@end

@implementation ReloadTxSetting

-(void)showDialogPassword{
    DialogPassword *dialog = [[DialogPassword alloc]initWithDelegate:self];
    [dialog showInWindow:self.controller.view.window];
}
-(void)onPasswordEntered:(NSString *)password{
    DialogProgress *dialogProgrees=[[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    [dialogProgrees showInWindow:self.controller.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            reloadTime=[[NSDate new] timeIntervalSince1970];
            [[PeerUtil instance] stopPeer];
            for(BTAddress * address in [[BTAddressManager instance]allAddresses]){
                [address setIsSyncComplete:NO];
                [address updateAddress];
            }
            [[BTTxProvider instance] clearAllTx];
            [TransactionsUtil syncWallet:^{
                [[PeerUtil instance] startPeer];
                [dialogProgrees dismiss];
                if([self.controller respondsToSelector:@selector(showMsg:)]){
                    [self.controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"Reload transactions data success", nil)];
                }
                
            } andErrorCallBack:^(MKNetworkOperation *errorOp, NSError *error) {
                [dialogProgrees dismiss];
                if([self.controller respondsToSelector:@selector(showMsg:)]){
                    [self.controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"Network failure.", nil)];
                }
                
            }];
            
           
        });
    }];
    

}

@end

@implementation DonationSetting

-(instancetype)init{
    self = [super initWithName:NSLocalizedString(@"Donate", nil) icon:@"donate_button_icon"];
    if(self){
        __weak DonationSetting *d = self;
        [self setSelectBlock:^(UIViewController * controller){
            d.controller = controller;
            [d show];
        }];
    }
    return self;
}

-(void)show{
    self.addresses = [[NSMutableArray alloc]init];
    NSArray* as = [BTAddressManager instance].privKeyAddresses;
    for(BTAddress * a in as){
        if(a.balance > 0){
            [self.addresses addObject:a];
        }
    }
    as = [BTAddressManager instance].watchOnlyAddresses;
    for(BTAddress *a in as){
        if(a.balance > 0){
            [self.addresses addObject:a];
        }
    }
    if(self.addresses.count == 0){
        if([self.controller respondsToSelector:@selector(showMsg:)]){
            [self.controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"No bitcoins available for donation.",nil)];
        }
        return;
    }
    [self.addresses sortUsingComparator:^NSComparisonResult(BTAddress* obj1, BTAddress* obj2) {
        return [self compare:obj1 and:obj2];
    }];
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Select an address to donate", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for(BTAddress* a in self.addresses){
        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@ (%@BTC)", [StringUtil shortenAddress:a.address], [StringUtil stringForAmount:a.balance]]];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.cancelButtonIndex = self.addresses.count;
    [actionSheet showInView:self.controller.navigationController.view];
}

-(NSComparisonResult)compare:(BTAddress*)obj1 and:(BTAddress*)obj2{
    if(obj1.hasPrivKey && !obj2.hasPrivKey){
        return NSOrderedAscending;
    }else if(!obj1.hasPrivKey && obj2.hasPrivKey){
        return NSOrderedDescending;
    }
    uint64_t balance1 = obj1.balance;
    uint64_t balance2 = obj2.balance;
    if(balance1 > balance2){
        return NSOrderedAscending;
    }else if(balance1 == balance2){
        return NSOrderedSame;
    }else{
        return NSOrderedDescending;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex >= 0 && buttonIndex < self.addresses.count){
        BTAddress* a = self.addresses[buttonIndex];
        if(a.hasPrivKey){
            SendViewController* send =[self.controller.storyboard instantiateViewControllerWithIdentifier:@"Send"];
            send.address = a;
            send.toAddress = DONATE_ADDRESS;
            send.amount =  DONATE_AMOUNT < a.balance ? DONATE_AMOUNT : a.balance;
            send.sendDelegate = self;
            [self.controller.navigationController pushViewController:send animated:YES];
        }else{
            UnsignedTransactionViewController *unsignedTx = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"UnsignedTransaction"];
            unsignedTx.address = a;
            unsignedTx.toAddress = DONATE_ADDRESS;
            unsignedTx.amount = DONATE_AMOUNT < a.balance ? DONATE_AMOUNT : a.balance;
            unsignedTx.sendDelegate = self;
            [self.controller.navigationController pushViewController:unsignedTx animated:YES];
        }
    }
}

-(void)sendSuccessed:(BTTx*)tx{
    if([self.controller respondsToSelector:@selector(showMsg:)]){
        [self.controller performSelector:@selector(showMsg:) withObject:NSLocalizedString(@"Thank you for donating.",nil)];
    }
}

@end
