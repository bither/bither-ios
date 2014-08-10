//  UIViewController+ConfigureTableView.m
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

#import "UIViewController+ConfigureTableView.h"



@implementation UIViewController(ConfigureTableView)


-(void)configureHeaderAndFooter :(UITableView * )tableView background:(UIColor *)colorBg isHot:(BOOL)isHot{
    UIImageView *ivTop = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"list_item_card_shadow_top"]];
    ivTop.contentMode = UIViewContentModeScaleToFill;
    UIView *vBottomCover = [[UIView alloc]initWithFrame:CGRectMake(0, -1, tableView.frame.size.width, 1)];
    UIImageView *ivBottom = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"list_item_card_shadow_bottom"]];
    ivBottom.contentMode = UIViewContentModeScaleToFill;
    UIImageView *ivTopLeft = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"list_item_card_corner_top_left"]];
    UIImageView *ivTopRight = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"list_item_card_corner_top_right"]];
    UIImageView *ivBottomLeft = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"list_item_card_corner_bottom_left"]];
    UIImageView *ivBottomRight = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"list_item_card_corner_bottom_right"]];
    UIImageView *ivLogo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"setting_footer_logo"]];
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, ivTop.frame.size.height)];
    header.backgroundColor = [UIColor clearColor];
    ivTop.frame = CGRectMake(10, 0, tableView.frame.size.width - 20, ivTop.frame.size.height);
    [header addSubview:ivTop];
    ivTopLeft.frame = CGRectMake(10, header.frame.size.height, ivTopLeft.frame.size.width, ivTopLeft.frame.size.height);
    ivTopRight.frame = CGRectMake(header.frame.size.width - ivTopRight.frame.size.width - 10, header.frame.size.height, ivTopRight.frame.size.width, ivTopRight.frame.size.height);
    [header addSubview:ivTopRight];
    [header addSubview:ivTopLeft];
    tableView.tableHeaderView= header;
    
    CGFloat logoTopMargin = 8;
    CGFloat logoBottomMargin = 6;
    UILabel *lblVersion = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
    lblVersion.textAlignment = NSTextAlignmentCenter;
    lblVersion.textColor = [UIColor colorWithWhite:1 alpha:0.6f];
    lblVersion.font = [UIFont systemFontOfSize:12];
    if (isHot) {
       lblVersion.text = [NSString stringWithFormat:@"Bither Hot %@", [[[NSBundle mainBundle]infoDictionary]objectForKey:(NSString*)kCFBundleVersionKey]];
    }else{
        lblVersion.text = [NSString stringWithFormat:@"Bither Cold %@", [[[NSBundle mainBundle]infoDictionary]objectForKey:(NSString*)kCFBundleVersionKey]];
    
    }
   
    [lblVersion sizeToFit];
    
    UIView* footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, ivBottom.frame.size.height + logoTopMargin + ivLogo.frame.size.height + logoBottomMargin + lblVersion.frame.size.height)];
    footer.backgroundColor = [UIColor clearColor];
    vBottomCover.backgroundColor = colorBg;
    [footer addSubview:vBottomCover];
    
    ivBottom.frame = CGRectMake(10, -1,tableView.frame.size.width - 20, ivBottom.frame.size.height);
    [footer addSubview:ivBottom];
    ivBottomLeft.frame = CGRectMake(10, -1-ivBottomLeft.frame.size.height, ivBottomLeft.frame.size.width, ivBottomLeft.frame.size.height);
    ivBottomRight.frame = CGRectMake(footer.frame.size.width - ivBottomRight.frame.size.width - 10, -1-ivBottomRight.frame.size.height, ivBottomRight.frame.size.width, ivBottomRight.frame.size.height);
    [footer addSubview:ivBottomRight];
    [footer addSubview:ivBottomLeft];
    ivLogo.frame = CGRectMake((footer.frame.size.width - ivLogo.frame.size.width)/2, CGRectGetMaxY(ivBottom.frame) + logoTopMargin, ivLogo.frame.size.width, ivLogo.frame.size.height);
    [footer addSubview:ivLogo];
    lblVersion.frame = CGRectMake((footer.frame.size.width - lblVersion.frame.size.width)/2, CGRectGetMaxY(ivLogo.frame) + logoBottomMargin, lblVersion.frame.size.width, lblVersion.frame.size.height);
    [footer addSubview:lblVersion];
    tableView.tableFooterView = footer;
}


-(void)configureHeaderAndFooterNoLogo :(UITableView * )tableView background:(UIColor *)colorBg{
    UIImageView *ivTop = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"list_item_card_shadow_top"]];
    ivTop.contentMode = UIViewContentModeScaleToFill;
    UIView *vBottomCover = [[UIView alloc]initWithFrame:CGRectMake(0, -1, tableView.frame.size.width, 1)];
    UIImageView *ivBottom = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"list_item_card_shadow_bottom"]];
    ivBottom.contentMode = UIViewContentModeScaleToFill;
    UIImageView *ivTopLeft = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"list_item_card_corner_top_left"]];
    UIImageView *ivTopRight = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"list_item_card_corner_top_right"]];
    UIImageView *ivBottomLeft = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"list_item_card_corner_bottom_left"]];
    UIImageView *ivBottomRight = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"list_item_card_corner_bottom_right"]];
  
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, ivTop.frame.size.height)];
    header.backgroundColor = [UIColor clearColor];
    ivTop.frame = CGRectMake(10, 0, tableView.frame.size.width - 20, ivTop.frame.size.height);
    [header addSubview:ivTop];
    ivTopLeft.frame = CGRectMake(10, header.frame.size.height, ivTopLeft.frame.size.width, ivTopLeft.frame.size.height);
    ivTopRight.frame = CGRectMake(header.frame.size.width - ivTopRight.frame.size.width - 10, header.frame.size.height, ivTopRight.frame.size.width, ivTopRight.frame.size.height);
    [header addSubview:ivTopRight];
    [header addSubview:ivTopLeft];
    tableView.tableHeaderView= header;
    
    CGFloat logoTopMargin = 8;
    CGFloat logoBottomMargin = 6;
    
    UIView* footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, ivBottom.frame.size.height + logoTopMargin  + logoBottomMargin )];
    footer.backgroundColor = [UIColor clearColor];
    vBottomCover.backgroundColor = colorBg;
    [footer addSubview:vBottomCover];
    
    ivBottom.frame = CGRectMake(10, -1,tableView.frame.size.width - 20, ivBottom.frame.size.height);
    [footer addSubview:ivBottom];
    ivBottomLeft.frame = CGRectMake(10, -1-ivBottomLeft.frame.size.height, ivBottomLeft.frame.size.width, ivBottomLeft.frame.size.height);
    ivBottomRight.frame = CGRectMake(footer.frame.size.width - ivBottomRight.frame.size.width - 10, -1-ivBottomRight.frame.size.height, ivBottomRight.frame.size.width, ivBottomRight.frame.size.height);
    [footer addSubview:ivBottomRight];
    [footer addSubview:ivBottomLeft];
   
    tableView.tableFooterView = footer;
}

@end
