//
//  MinerFeeSettingViewController.m
//  bither-ios
//
//  Created by 韩珍珍 on 2024/4/30.
//  Copyright © 2024 Bither. All rights reserved.
//

#import "MinerFeeSettingViewController.h"
#import "MinerFeeSettingCell.h"
#import "MinerFeeModeModel.h"
#import "DialogProgressChangable.h"
#import "BitherApi.h"
#import "DialogAlert.h"

@interface MinerFeeSettingViewController () <UITableViewDataSource, UITableViewDelegate, MinerFeeSettingCellDelegate> {
    DialogProgressChangable *dp;
}

@property (weak, nonatomic) IBOutlet UIView *vTopBar;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property(strong, nonatomic) NSArray *datas;

@end

@implementation MinerFeeSettingViewController

- (instancetype)initWithDelegate:(NSObject <MinerFeeSettingViewControllerDelegate> *)delegate curMinerFeeMode:(MinerFeeMode)curMinerFeeMode curMinerFeeBase:(uint64_t)curMinerFeeBase {
    self = [self init];
    if (self) {
        self.delegate = delegate;
        self.curMinerFeeMode = curMinerFeeMode;
        self.curMinerFeeBase = curMinerFeeBase;
        self.datas = [MinerFeeModeModel getAllModes];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    dp = [[DialogProgressChangable alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    dp.touchOutSideToDismiss = NO;
    _lblTitle.text = NSLocalizedString(@"Miner Fee", nil);
    [_mTableView registerNib:[UINib nibWithNibName:@"MinerFeeSettingCell" bundle:nil] forCellReuseIdentifier:@"MinerFeeSettingCell"];
}

- (IBAction)btnCancelClicked {
    [self.navigationController popViewControllerAnimated:true];
}

//tableview delgate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MinerFeeSettingCell *cell = (MinerFeeSettingCell *) [tableView dequeueReusableCellWithIdentifier:@"MinerFeeSettingCell" forIndexPath:indexPath];
    cell.delegate = self;
    [cell showFromMinerFeeModeModel:_datas[indexPath.row] curMinerFeeMode:_curMinerFeeMode curMinerFeeBase:_curMinerFeeBase];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MinerFeeModeModel *model = _datas[indexPath.row];
    if (model.getMinerFeeMode == CustomFee && _curMinerFeeMode == CustomFee) {
        return 158;
    } else {
        return 50;
    }
}

- (void)minerFeeClicked:(MinerFeeMode)minerFeeMode minerFeeBase:(uint64_t)minerFeeBase {
    [self.view endEditing:true];
    if (minerFeeMode == CustomFee && minerFeeBase <= 0) {
        __weak typeof(self) weakSelf = self;
        DialogAlert *dialogAlert = [[DialogAlert alloc] initWithMessage:NSLocalizedString(@"miner_fee_custom_warn", nil) confirm:^{
            weakSelf.curMinerFeeMode = minerFeeMode;
            weakSelf.curMinerFeeBase = 0;
            [weakSelf.mTableView reloadData];
        } cancel:^{ }];
        dialogAlert.touchOutSideToDismiss = false;
        [dialogAlert showInWindow:self.view.window];
        return;
    }
    if (minerFeeMode == CustomFee || minerFeeMode == DynamicFee) {
        [[UserDefaultsUtil instance] setIsUseDynamicMinerFee:true];
    } else {
        [[UserDefaultsUtil instance] setIsUseDynamicMinerFee:false];
        [[UserDefaultsUtil instance] setTransactionFeeMode:minerFeeBase];
    }
    if (self.delegate) {
        [self.delegate changeMinerFeeMode:minerFeeMode minerFeeBase:minerFeeBase];
    }
    [self btnCancelClicked];
}

- (void)customConfirmClicked:(uint64_t)custom {
    [self.view endEditing:true];
    if (custom > 0) {
        __weak typeof(self) weakSelf = self;
        [dp showInWindow:self.view.window completion:^{
            [weakSelf queryCustomMaxCallback:^(uint64_t int64) {
                [self->dp dismiss];
                if (custom < int64) {
                    [weakSelf minerFeeClicked:CustomFee minerFeeBase:custom * 1000];
                } else {
                    DialogAlert *dialogAlert = [[DialogAlert alloc] initWithMessage:NSLocalizedString(@"miner_fee_custom_high", nil) confirm:^{
                        [weakSelf minerFeeClicked:CustomFee minerFeeBase:custom * 1000];
                    } cancel:^{ }];
                    dialogAlert.touchOutSideToDismiss = false;
                    [dialogAlert showInWindow:weakSelf.view.window];
                }
            }];
        }];
    } else {
        DialogAlert *dialogAlert = [[DialogAlert alloc] initWithConfirmMessage:NSLocalizedString(@"miner_fee_custom_empty", nil) confirm:^{ }];
        dialogAlert.touchOutSideToDismiss = false;
        [dialogAlert showInWindow:self.view.window];
    }
}

- (void)queryCustomMaxCallback:(UInt64ResponseBlock)callback {
    [[BitherApi instance] queryStatsDynamicFeeBaseCallback:^(uint64_t int64) {
        if (callback) {
            callback(int64 / 500);
        }
    } andErrorCallBack:^(NSError *error) {
        if (callback) {
            callback(600);
        }
    }];
}

@end
