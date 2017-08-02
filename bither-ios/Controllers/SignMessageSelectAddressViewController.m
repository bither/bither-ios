//
//  SignMessageSelectAddressViewController.m
//  bither-ios
//
//  Created by 韩珍 on 2017/7/21.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "SignMessageSelectAddressViewController.h"
#import "BTBIP32Key.h"
#import "BTUtils.h"
#import "SignMessageSelectAddressCell.h"
#import "BTAddressManager.h"
#import "SignMessageViewController.h"

#define pageCount (10)

@interface SignMessageSelectAddressViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *_addresses;
    BOOL hasMore;
    BOOL isLoading;
    int page;
    BOOL isHd;
    int hdAccountId;
}

@property (weak, nonatomic) IBOutlet UIView *vTopBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property BTBIP32Key *bip32Key;
@property PathType pathType;

@end

@implementation SignMessageSelectAddressViewController

- (void)showAddresses:(NSArray *)addresses {
    isHd = NO;
    hasMore = NO;
    isLoading = NO;
    _addresses = [NSMutableArray new];
    [_addresses addObjectsFromArray:addresses];
    [self.tableView reloadData];
}

- (void)showHdAddresses:(PathType)path password:(NSString *)password {
    isHd = YES;
    hasMore = YES;
    isLoading = NO;
    page = 1;
    self.pathType = path;
    _addresses = [NSMutableArray new];
    BTAddressManager *addressManager = [BTAddressManager instance];
    if (addressManager.hasHDAccountHot) {
        self.bip32Key = [[addressManager.hdAccountHot xPub:password] deriveSoftened:path];
        hdAccountId = (int)addressManager.hdAccountHot.getHDAccountId;
    } else {
        self.bip32Key = [[addressManager.hdAccountCold xPub:password] deriveSoftened:path];
        hdAccountId = (int)addressManager.hdAccountCold.getHDAccountId;
    }
    [self loadAddress];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lblTitle.text = NSLocalizedString(@"sign_message_select_address", nil);
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadAddress {
    if (isLoading) {
        return;
    }
    isLoading = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSMutableArray *newAddress = [NSMutableArray new];
        for (int i = (page - 1) * pageCount; i < page * pageCount; i++) {
            BTBIP32Key *pathKey = [self.bip32Key deriveSoftened:i];
            BTHDAccountAddress *hdAccountAddress = [[BTHDAccountAddress alloc] initWithHDAccountId:hdAccountId address:pathKey.address pub:pathKey.pubKey path:_pathType index:i issued:NO andSyncedComplete:YES];
            [newAddress addObject:hdAccountAddress];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (newAddress && newAddress.count > 0) {
                if (page == 1) {
                    [_addresses removeAllObjects];
                    [_addresses addObjectsFromArray:newAddress];
                    [self.tableView reloadData];
                } else {
                    NSMutableArray *indexPathSet = [[NSMutableArray alloc] init];
                    for (BTAddress *address in newAddress) {
                        [_addresses addObject:address];
                        [indexPathSet addObject:[NSIndexPath indexPathForRow:_addresses.count - 1 inSection:0]];
                    }
                    [self.tableView insertRowsAtIndexPaths:indexPathSet withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                hasMore = YES;
            } else {
                hasMore = NO;
            }
            isLoading = NO;
        });
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _addresses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SignMessageSelectAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SignMessageSelectAddressCell" forIndexPath:indexPath];
    if ([_addresses[indexPath.row] isMemberOfClass:[BTAddress class]]) {
        [cell showByAddress:_addresses[indexPath.row] index:indexPath.row];
    } else if ([_addresses[indexPath.row] isMemberOfClass:[BTHDAccountAddress class]]) {
        [cell showByHDAccountAddress:_addresses[indexPath.row]];
    }
    if (indexPath.row > (_addresses.count - 2) && !isLoading && hasMore && isHd) {
        page ++;
        [self loadAddress];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 81;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SignMessageViewController *sign = [self.storyboard instantiateViewControllerWithIdentifier:@"SignMessage"];
    if ([_addresses[indexPath.row] isMemberOfClass:[BTAddress class]]) {
        sign.address = _addresses[indexPath.row];
    } else if ([_addresses[indexPath.row] isMemberOfClass:[BTHDAccountAddress class]]) {
        sign.hdAccountAddress = _addresses[indexPath.row];
    }
    [self.navigationController pushViewController:sign animated:YES];
}


@end
