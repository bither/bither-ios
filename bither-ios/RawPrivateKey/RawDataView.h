//
//  RawDataView.h
//  bither-ios
//
//  Created by 宋辰文 on 14/12/9.
//  Copyright (c) 2014年 宋辰文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RawDataView : UIView
@property CGSize restrictedSize;
@property CGSize dataSize;
@property (readonly) NSUInteger dataLength;
@property (readonly) NSUInteger filledDataLength;
@property (readonly) NSData* data;
-(void)addData:(BOOL)d;
@end
