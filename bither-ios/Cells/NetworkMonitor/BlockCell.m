//  BlockCell.m
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


#import "BlockCell.h"
#import "NSString+Base58.h"
#import "DateUtil.h"

@interface BlockCell ()
@property(weak, nonatomic) IBOutlet UILabel *lbBlockNo;
@property(weak, nonatomic) IBOutlet UILabel *lbTime;
@property(weak, nonatomic) IBOutlet UILabel *lbBlockHash;

@end

@implementation BlockCell

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

- (void)setBlock:(BTBlock *)block {
    self.lbBlockNo.text = [NSString stringWithFormat:@"%d", block.blockNo];
    NSString *blockHash = [[NSString hexWithHash:block.blockHash] toLowercaseStringWithEn];
    self.lbBlockHash.text = blockHash;
    self.lbTime.text = [DateUtil getRelativeDate:[NSDate dateWithTimeIntervalSince1970:block.blockTime]];
}
@end
