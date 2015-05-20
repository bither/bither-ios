//
//  ImageCropView.m
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


#import "ImageCropView.h"
#import "ImageScrollView.h"
#import "UIImage_Extensions.h"

@interface ImageCropView () {
    CGRect _highlightedRect;
}
@property(strong, nonatomic) ImageScrollView *isv;
@property(strong, nonatomic) UIView *topOverlay;
@property(strong, nonatomic) UIView *leftOverlay;
@property(strong, nonatomic) UIView *rightOverlay;
@property(strong, nonatomic) UIView *bottomOverlay;
@property(strong, nonatomic) UIImageView *centerOverlay;
@end

@implementation ImageCropView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self firstConfigure];
    }
    return self;
}

- (void)firstConfigure {
    self.backgroundColor = [UIColor clearColor];

    self.centerOverlay = [[UIImageView alloc] initWithFrame:CGRectZero];
    UIImage *image = [UIImage imageNamed:@"crop_photo_overlay"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2, image.size.width / 2, image.size.height / 2, image.size.width / 2)];
    self.centerOverlay.image = image;
    self.centerOverlay.alpha = 0.8;
    self.topOverlay = [[UIView alloc] initWithFrame:CGRectZero];
    self.topOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
    self.leftOverlay = [[UIView alloc] initWithFrame:CGRectZero];
    self.leftOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
    self.rightOverlay = [[UIView alloc] initWithFrame:CGRectZero];
    self.rightOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
    self.bottomOverlay = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottomOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
    [self addSubview:self.topOverlay];
    [self addSubview:self.leftOverlay];
    [self addSubview:self.rightOverlay];
    [self addSubview:self.bottomOverlay];
    [self addSubview:self.centerOverlay];
    [self configureFrame:self.frame];

    self.isv = [[ImageScrollView alloc] initWithFrame:_highlightedRect];
    self.isv.clipsToBounds = NO;
    self.isv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.isv];
    [self sendSubviewToBack:self.isv];
}

- (void)setFrame:(CGRect)frame {
    [self configureFrame:frame];
    [super setFrame:frame];
}

- (void)configureFrame:(CGRect)frame {
    CGFloat highlightedSize = fminf(frame.size.width, frame.size.height);
    _highlightedRect = CGRectMake((frame.size.width - highlightedSize) / 2, (frame.size.height - highlightedSize) / 2, highlightedSize, highlightedSize);
    self.centerOverlay.frame = _highlightedRect;
    self.topOverlay.frame = CGRectMake(0, 0, frame.size.width, _highlightedRect.origin.y);
    self.bottomOverlay.frame = CGRectMake(0, _highlightedRect.origin.y + _highlightedRect.size.height, frame.size.width, frame.size.height - _highlightedRect.origin.y - _highlightedRect.size.height);
    self.leftOverlay.frame = CGRectMake(0, self.topOverlay.frame.origin.y + self.topOverlay.frame.size.height, _highlightedRect.origin.x, self.bottomOverlay.frame.origin.y - self.topOverlay.frame.origin.y - self.topOverlay.frame.size.height);
    self.rightOverlay.frame = CGRectMake(_highlightedRect.origin.x + _highlightedRect.size.width, self.topOverlay.frame.origin.y + self.topOverlay.frame.size.height, frame.size.width - _highlightedRect.origin.x - _highlightedRect.size.width, self.bottomOverlay.frame.origin.y - self.topOverlay.frame.origin.y - self.topOverlay.frame.size.height);
}

- (UIImage *)croppedImage {
    self.isv.rotation = self.isv.rotation;
    UIImage *img = self.isv.image;
    CGRect zoomViewFrame = [self.isv viewForZoomingInScrollView:self.isv].frame;
    CGRect rect = CGRectZero;
    rect.origin.x = (self.isv.contentOffset.x + zoomViewFrame.origin.x) / self.isv.zoomScale;
    rect.origin.y = (self.isv.contentOffset.y + zoomViewFrame.origin.y) / self.isv.zoomScale;
    rect.size.width = _highlightedRect.size.width / self.isv.zoomScale;
    rect.size.height = _highlightedRect.size.height / self.isv.zoomScale;
    return [[img cropImageWithBounds:rect] imageRotatedByRadians:self.isv.rotation];
}

- (UIImage *)image {
    return self.isv.image;
}

- (void)setImage:(UIImage *)image {
    self.isv.image = image;
}

@end
