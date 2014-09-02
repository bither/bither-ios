//
//  BlockCell.m
//  bither-ios
//
//  Created by noname on 14-9-2.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "BlockCell.h"
#import "NSString+Base58.h"

@interface BlockCell()
@property (weak, nonatomic) IBOutlet UILabel *lbBlockNo;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UILabel *lbBlockHash;

@end

@implementation BlockCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setBlock:(BTBlock *)block{
    self.lbBlockNo.text=[NSString stringWithFormat:@"d%",block.blockNo];
    self.lbBlockHash.text=[NSString hexWithHash:block.blockHash];
}
@end
