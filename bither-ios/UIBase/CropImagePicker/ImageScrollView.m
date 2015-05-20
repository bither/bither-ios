//
//  ImageScrollView.m
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


#import "ImageScrollView.h"

#define kImageScrollViewRotateAnimationDuration (0.13)

#pragma mark -

@interface ImageScrollView () {
    UIImageView *_zoomView;  // if tiling, this contains a very low-res placeholder image,
    // otherwise it contains the full image.
    CGSize _imageSize;

    CGPoint _pointToCenterAfterResize;
    CGFloat _scaleToRestoreAfterResize;

    UIImage *_image;
    CGFloat _rotation;
}

@end

@implementation ImageScrollView

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
    _rotation = 0;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.delegate = self;
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateGesture:)];
    [self addGestureRecognizer:rotate];
}

- (void)handleRotateGesture:(UIRotationGestureRecognizer *)gesture {
    _rotation += gesture.rotation;
    if (_rotation > M_PI * 2) {
        _rotation = _rotation - M_PI * 2;
    } else if (_rotation < 0) {
        _rotation = _rotation + M_PI * 2;
    }
    self.rotation = _rotation;
    gesture.rotation = 0;
    if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:kImageScrollViewRotateAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.rotation = self.rotation;
        }                completion:nil];
    }
}

- (void)setImage:(UIImage *)image {
    _image = image;
    if (_image) {
        [self displayImage:_image];
    }
}

- (UIImage *)image {
    return _image;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _zoomView.frame;

    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;

    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;

    _zoomView.frame = frameToCenter;
}

- (void)setFrame:(CGRect)frame {
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);

    if (sizeChanging) {
        [self prepareToResize];
    }

    [super setFrame:frame];

    if (sizeChanging) {
        [self recoverFromResizing];
    }
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _zoomView;
}

- (void)displayImage:(UIImage *)image {
    // clear the previous image
    [_zoomView removeFromSuperview];
    _zoomView = nil;

    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;

    // make a new UIImageView for the new image
    _zoomView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:_zoomView];

    [self configureForImageSize:image.size];
    [self centerImage];
}


- (void)configureForImageSize:(CGSize)imageSize {
    _imageSize = imageSize;
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}

- (void)centerImage {
    CGFloat x = (self.contentSize.width - self.bounds.size.width) / 2;
    CGFloat y = (self.contentSize.height - self.bounds.size.height) / 2;
    self.contentOffset = CGPointMake(x, y);
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    CGSize boundsSize = self.bounds.size;
    CGFloat sizeMin = MIN(boundsSize.width, boundsSize.height);
    // calculate min/max zoomscale
    CGFloat xScale = sizeMin / _imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = sizeMin / _imageSize.height;   // the scale needed to perfectly fit the image height-wise

    CGFloat minScale = MAX(xScale, yScale);

    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];

    self.maximumZoomScale = fmaxf(maxScale, minScale);
    self.minimumZoomScale = minScale;
}

#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

#pragma mark - Rotation support

- (void)prepareToResize {
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:_zoomView];

    _scaleToRestoreAfterResize = self.zoomScale;

    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing {
    [self setMaxMinZoomScalesForCurrentBounds];

    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, _scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);

    // Step 2: restore center point, first making sure it is within the allowable range.

    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:_zoomView];

    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
            boundsCenter.y - self.bounds.size.height / 2.0);

    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];

    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);

    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);

    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset {
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset {
    return CGPointZero;
}

- (void)setRotation:(CGFloat)rotation {
    _rotation = rotation;
    self.transform = CGAffineTransformMakeRotation(rotation);
}

- (CGFloat)rotation {
    if (_rotation > M_PI_4 && _rotation <= M_PI_4 * 3) {
        _rotation = M_PI_2;
    } else if (_rotation > M_PI_4 * 3 && _rotation <= M_PI_4 * 5) {
        _rotation = M_PI;
    } else if (_rotation > M_PI_4 * 5 && _rotation <= M_PI_4 * 7) {
        _rotation = M_PI_2 * 3;
    } else {
        _rotation = 0;
    }
    return _rotation;
}

@end