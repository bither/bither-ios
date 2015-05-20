//  PeerCell.m
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


#import "PeerCell.h"

@interface PeerCell ()
@property(weak, nonatomic) IBOutlet UILabel *lbAddress;
@property(weak, nonatomic) IBOutlet UILabel *lbBlocks;
@property(weak, nonatomic) IBOutlet UILabel *lbVersion;
@property(weak, nonatomic) IBOutlet UILabel *lbProtocol;
@property(weak, nonatomic) IBOutlet UILabel *lbPing;

@end

@implementation PeerCell

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

- (void)setPeer:(BTPeer *)peer {
    self.lbAddress.text = peer.host;

    if (peer.status == BTPeerStatusConnected) {
        if (peer.userAgent.length > 20) {
            self.lbVersion.text = [NSString stringWithFormat:@"%@...", [peer.userAgent substringToIndex:20]];
        } else {
            self.lbVersion.text = peer.userAgent;
        }
        self.lbVersion.text = peer.userAgent;
        self.lbProtocol.text = [NSString stringWithFormat:@"protocol: %d", (int) peer.version];
        self.lbBlocks.text = [NSString stringWithFormat:@"%d blocks", (int) peer.displayLastBlock];
        self.lbPing.text = [NSString stringWithFormat:@"⇆ %ld ms", (long) (peer.pingTime * 1000)];

    } else {
        self.lbVersion.text = @"----";
        self.lbProtocol.text = [NSString stringWithFormat:@"protocol: %@", @"--"];
        self.lbBlocks.text = [NSString stringWithFormat:@"%@ blocks", @"--"];
        self.lbPing.text = [NSString stringWithFormat:@"%@ ms", @"--"];

    }


}

@end
