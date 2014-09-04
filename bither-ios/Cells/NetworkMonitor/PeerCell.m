//
//  PeerCell.m
//  bither-ios
//
//  Created by noname on 14-9-2.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "PeerCell.h"

@interface PeerCell()
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbBlocks;
@property (weak, nonatomic) IBOutlet UILabel *lbVersion;
@property (weak, nonatomic) IBOutlet UILabel *lbProtocol;
@property (weak, nonatomic) IBOutlet UILabel *lbPing;

@end

@implementation PeerCell

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
-(void)setPeer:(BTPeer *)peer{
    self.lbAddress.text=peer.host;
    self.lbVersion.text= peer.userAgent;
    self.lbProtocol.text=[NSString stringWithFormat:@"protocol: %d",(int)peer.version];
    self.lbBlocks.text=[NSString stringWithFormat:@"%d blocks",(int)peer.versionLastBlock];
    self.lbPing.text=[NSString stringWithFormat:@"⇆ %ld ms",(long)(peer.pingTime*1000)];
    
    
}

@end
