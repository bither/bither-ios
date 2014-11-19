//
//  TrashCanCell.m
//  bither-ios
//
//  Created by noname on 14-11-19.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "TrashCanCell.h"
@interface TrashCanCell()
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@end

@implementation TrashCanCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)viewOnNetPressed:(id)sender {
}
- (IBAction)restorePressed:(id)sender {
}

- (IBAction)copyPressed:(id)sender {
}

@end
