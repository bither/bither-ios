//
//  SplitCoinUtil.m
//  bither-ios
//
//  Created by 韩珍 on 2017/11/15.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "SplitCoinUtil.h"
#import "UnitUtil.h"

@implementation SplitCoinUtil

+ (NSString *)getSplitCoinName:(SplitCoin)splitCoin {
    NSString *name;
    switch (splitCoin) {
        case SplitBCC:
            name = @"BCH";
            break;
        case SplitBTG:
            name = @"BTG";
            break;
        case SplitSBTC:
            name = @"SBTC";
            break;
        case SplitBTW:
            name = @"BTW";
            break;
        case SplitBCD:
            name = @"BCD";
            break;
        case SplitBTF:
            name = @"BTF";
            break;
        case SplitBTP:
            name = @"BTP";
            break;
        case SplitBTN:
            name = @"BTN";
            break;
        default:
            name = @"BCH";
            break;
    }
    return name;
}

+ (NSString *)getPathCoinCodee:(SplitCoin)splitCoin {
    NSString *name;
    switch (splitCoin) {
        case SplitBCC:
            name = @"bcc";
            break;
        case SplitBTG:
            name = @"btg";
            break;
        case SplitSBTC:
            name = @"sbtc";
            break;
        case SplitBTW:
            name = @"btw";
            break;
        case SplitBCD:
            name = @"bcd";
            break;
        case SplitBTF:
            name = @"btf";
            break;
        case SplitBTP:
            name = @"btp";
            break;
        case SplitBTN:
            name = @"btn";
            break;
        default:
            name = @"bcc";
            break;
    }
    return name;
}

+ (BitcoinUnit)getBitcoinUnit:(SplitCoin)splitCoin {
    BitcoinUnit unit = UnitBTC;
    switch (splitCoin) {
        case SplitBTW:
            unit = UnitBTW;
            break;
        case SplitBCD:
        case SplitBTP:
            unit = UnitBCD;
            break;
        default:
            unit = UnitBTC;
            break;
    }
    return unit;
}

+ (BitcoinUnit)getUnit:(NSString *)unitName {
    BitcoinUnit unit = [UnitUtil unit];
    if([unitName isEqualToString:@"BTW"]) {
        unit = UnitBTW;
    }else if([unitName isEqualToString:@"BCD"] || [unitName isEqualToString:@"BTP"]) {
        unit = UnitBCD;
    }else if([unitName isEqualToString:@"BCH"] || [unitName isEqualToString:@"BTG"] ||
             [unitName isEqualToString:@"SBTC"] || [unitName isEqualToString:@"BCD"] ||
            [unitName isEqualToString:@"BTF"] || [unitName isEqualToString:@"BTN"] ){
        unit = UnitBTC;
    }else{
        unit = [UnitUtil unit];
    }
    return unit;
}

+ (Coin)getCoin:(SplitCoin)splitCoin{
    switch (splitCoin) {
        case SplitBCC:
            return BCC;
        case SplitBTG:
            return BTG;
        case SplitSBTC:
            return SBTC;
        case SplitBTW:
            return BTW;
        case SplitBCD:
            return BCD;
        case SplitBTF:
            return BTF;
        case SplitBTP:
            return BTP;
        case SplitBTN:
            return BTN;
        default:
            return BCC;
    }
}
+ (u_int8_t)getAddressPrefixPubkey:(SplitCoin)splitCoin{
    switch (splitCoin) {
        case SplitBTF:
            return BITCOIN_FAITH_PUBKEY_ADDRESS;
        case SplitBTP:
            return BITCOIN_PAY_PUBKEY_ADDRESS;
        case SplitBTW:
            return BITCOIN_WORLD_PUBKEY_ADDRESS;
        case SplitBTG:
            return BITCOIN_GOLD_PUBKEY_ADDRESS;
        default:
            return BITCOIN_PUBKEY_ADDRESS;
    }
}

+ (u_int8_t)getAddressPrefixScript:(SplitCoin)splitCoin {
    switch (splitCoin) {
        case SplitBTF:
            return BITCOIN_FAITH_PUBKEY_ADDRESS;
        case SplitBTP:
            return BITCOIN_PAY_PUBKEY_ADDRESS;
        case SplitBTW:
            return BITCOIN_WORLD_PUBKEY_ADDRESS;
        case SplitBTG:
            return BITCOIN_GOLD_PUBKEY_ADDRESS;
        default:
            return BITCOIN_PUBKEY_ADDRESS;
    }
}
+ (BOOL)validSplitCoinAddress:(SplitCoin)splitCoin address:(NSString *)addr {
    NSData* d = addr.base58checkToData;
    if(d.length != 21) return NO;
    
    uint8_t version = *(const uint8_t *) d.bytes;
    
    if(version == [self getAddressPrefixPubkey:splitCoin] || version == [self getAddressPrefixScript:splitCoin]) {
        return YES;
    }
    return NO;
    
}

+ (SplitCoin)getCoinByAddressFormat:(NSString *)addr {
    NSData* d = addr.base58checkToData;
    uint8_t version = *(const uint8_t *) d.bytes;
    if(version == BITCOIN_FAITH_PUBKEY_ADDRESS || version == BITCOIN_FAITH_SCRIPT_ADDRESS) {
        return SplitBTF;
    }else if(version == BITCOIN_PAY_PUBKEY_ADDRESS || version == BITCOIN_PAY_SCRIPT_ADDRESS){
        return SplitBTP;
    }else if(version == BITCOIN_WORLD_PUBKEY_ADDRESS || version == BITCOIN_WORLD_SCRIPT_ADDRESS){
        return SplitBTW;
    }else if(version == BITCOIN_GOLD_PUBKEY_ADDRESS || version == BITCOIN_GOLD_SCRIPT_ADDRESS){
        return SplitBTG;
    }else{
        return None;
    }
}

@end
