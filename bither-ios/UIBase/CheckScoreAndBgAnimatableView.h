//
//  CheckScoreAndBgAnimatableView.h
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

#import <UIKit/UIKit.h>

#define kCheckScoreAndBgAnimatableViewDefaultAnimationDuration (0.6f)

@protocol CheckScoreAndBgAnimatableViewDelegate <NSObject>
@optional
- (void)displayScore:(NSUInteger)score;

- (void)onAnimation:(NSInteger)animationId beginWithScore:(NSUInteger)score;

- (void)onAnimation:(NSInteger)animationId endWithScore:(NSUInteger)score;
@end

@interface CheckScoreAndBgAnimatableView : UIView {
    NSUInteger _score;
}
@property NSUInteger score;
@property NSUInteger targetScore;
@property(weak) NSObject <CheckScoreAndBgAnimatableViewDelegate> *delegate;

- (void)setBeginColor:(UIColor *)color;

- (void)setMiddleColor:(UIColor *)color;

- (void)setEndColor:(UIColor *)color;

- (void)animateToScore:(NSUInteger)score withAnimationId:(NSUInteger)animationId;

- (void)animateToScore:(NSUInteger)score withAnimationId:(NSUInteger)animationId andDuration:(NSTimeInterval)duration;
@end
