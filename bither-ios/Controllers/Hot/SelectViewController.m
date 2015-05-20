//
//  SelectViewController.m
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

#import "SelectViewController.h"
#import "SelectListCell.h"
#import "NSDictionary+Fromat.h"
#import "UIViewController+ConfigureTableView.h"

@interface SelectViewController () <UITableViewDataSource, UITableViewDelegate>
@property(weak, nonatomic) IBOutlet UIView *vTopBar;
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) NSArray *array;
@property(weak, nonatomic) IBOutlet UILabel *lblSettingName;

@end

@implementation SelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.array = self.setting.getArrayBlock();
    [self.tableView reloadData];
    self.lblSettingName.text = self.setting.settingName;
    [self configureHeaderAndFooterNoLogo:self.tableView background:ColorBg];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//tableview delgate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectListCell *cell = (SelectListCell *) [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *dict = [self.array objectAtIndex:indexPath.row];
    if ([dict objectForKey:SETTING_KEY_ATTRIBUTED] && [[dict objectForKey:SETTING_KEY_ATTRIBUTED] isKindOfClass:[NSAttributedString class]]) {
        [cell setAttributedName:[dict objectForKey:SETTING_KEY_ATTRIBUTED] isDefault:[dict getBoolFromDict:SETTING_IS_DEFAULT]];
    } else {
        [cell setName:[dict getStringFromDict:SETTING_KEY] isDefault:[dict getBoolFromDict:SETTING_IS_DEFAULT]];
    }
    return cell;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [self.array objectAtIndex:indexPath.row];
    if (self.setting.result) {
        self.setting.result(dict);
        [self.navigationController popViewControllerAnimated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
