//
//  SettingListCell.m
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

#import "SettingListCell.h"

@interface SettingListCell ()
@property(weak, nonatomic) IBOutlet UIImageView *ivIcon;
@property(weak, nonatomic) IBOutlet UILabel *lbName;
@property(weak, nonatomic) IBOutlet UILabel *lbValue;
@property(weak, nonatomic) IBOutlet UIImageView *ivHighlighted;

@end

@implementation SettingListCell

- (void)setSetting:(Setting *)setting {
    self.lbName.text = setting.settingName;
    if (setting.icon) {
        self.lbValue.hidden = YES;
        self.ivIcon.hidden = NO;
        self.ivIcon.image = [setting getIcon];
    } else {
        self.lbValue.hidden = NO;
        self.ivIcon.hidden = YES;
        if (setting.getValueBlock) {
            self.lbValue.text = nil;
            self.lbValue.attributedText = nil;
            NSObject *value = setting.getValueBlock();
            if ([value isKindOfClass:[NSAttributedString class]]) {
                self.lbValue.attributedText = (NSAttributedString *) value;
            } else if ([value isKindOfClass:[NSString class]]) {
                self.lbValue.text = (NSString *) value;
            }
        } else {
            self.lbValue.text = @"";
            self.lbValue.attributedText = nil;
        }
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.ivHighlighted.highlighted = highlighted;
}
@end
