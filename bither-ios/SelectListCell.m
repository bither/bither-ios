//
//  SelectListCell.m
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

#import "SelectListCell.h"

@interface SelectListCell ()
@property(weak, nonatomic) IBOutlet UILabel *lbName;
@property(weak, nonatomic) IBOutlet UIImageView *ivCheckMark;
@property(weak, nonatomic) IBOutlet UIImageView *ivHighlighted;

@end

@implementation SelectListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setName:(NSString *)name isDefault:(BOOL)isDefault {
    self.ivCheckMark.hidden = !isDefault;
    self.lbName.attributedText = nil;
    self.lbName.text = name;
}

- (void)setAttributedName:(NSAttributedString *)name isDefault:(BOOL)isDefault {
    self.ivCheckMark.hidden = !isDefault;
    self.lbName.text = nil;
    self.lbName.attributedText = name;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.ivHighlighted.highlighted = highlighted;
}

@end
