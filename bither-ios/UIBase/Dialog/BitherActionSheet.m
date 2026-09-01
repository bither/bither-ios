//
//  BitherActionSheet.m
//  bither-ios
//

#import "BitherActionSheet.h"

static const CGFloat kActionSheetHorizontalMargin = 8.0;
static const CGFloat kActionSheetBottomMargin = 8.0;
static const CGFloat kActionSheetGroupSpacing = 8.0;
static const CGFloat kActionSheetTitleHeight = 44.0;
static const CGFloat kActionSheetButtonHeight = 57.0;
static const CGFloat kActionSheetCornerRadius = 13.0;

@interface BitherActionSheet ()

@property(nonatomic, copy) BitherActionSheetHandler handler;
@property(nonatomic, strong) NSString *sheetTitle;
@property(nonatomic, strong) NSArray *buttonTitles;
@property(nonatomic, strong) NSString *cancelButtonTitle;
@property(nonatomic, strong) UIControl *backgroundControl;
@property(nonatomic, strong) UIView *sheetContainer;
@property(nonatomic, strong) UIScrollView *actionGroup;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) NSMutableArray *actionButtons;
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, assign) BOOL dismissing;
@property(nonatomic, assign) BOOL sheetPositionLocked;
@property(nonatomic, assign) CGRect restingSheetFrame;

@end

@implementation BitherActionSheet

- (instancetype)initWithTitle:(NSString *)title
                 buttonTitles:(NSArray *)buttonTitles
             cancelButtonTitle:(NSString *)cancelButtonTitle
                       handler:(BitherActionSheetHandler)handler {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.sheetTitle = title;
        self.buttonTitles = [buttonTitles copy];
        self.cancelButtonTitle = cancelButtonTitle;
        self.handler = handler;
        [self configureViews];
    }
    return self;
}

- (void)configureViews {
    self.backgroundColor = [UIColor clearColor];

    self.backgroundControl = [[UIControl alloc] initWithFrame:self.bounds];
    self.backgroundControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundControl.backgroundColor = [UIColor colorWithWhite:0 alpha:0.35];
    [self.backgroundControl addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backgroundControl];

    self.sheetContainer = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.sheetContainer];

    self.actionGroup = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.actionGroup.backgroundColor = [UIColor colorWithWhite:0.98 alpha:0.98];
    self.actionGroup.layer.cornerRadius = kActionSheetCornerRadius;
    self.actionGroup.layer.masksToBounds = YES;
    self.actionGroup.showsVerticalScrollIndicator = NO;
    self.actionGroup.alwaysBounceVertical = NO;
    self.actionGroup.delaysContentTouches = NO;
    if (@available(iOS 11.0, *)) {
        self.actionGroup.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.sheetContainer addSubview:self.actionGroup];

    if (self.sheetTitle.length > 0) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.text = self.sheetTitle;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
        self.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [self.actionGroup addSubview:self.titleLabel];
    }

    UIColor *actionColor = [UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:1.0];
    self.actionButtons = [NSMutableArray arrayWithCapacity:self.buttonTitles.count];
    [self.buttonTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger index, BOOL *stop) {
        UIButton *button = [self actionButtonWithTitle:title color:actionColor bold:NO];
        button.tag = index;
        [button addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionGroup addSubview:button];
        [self.actionButtons addObject:button];
    }];

    self.cancelButton = [self actionButtonWithTitle:self.cancelButtonTitle color:actionColor bold:YES];
    self.cancelButton.backgroundColor = [UIColor colorWithWhite:0.98 alpha:0.98];
    self.cancelButton.layer.cornerRadius = kActionSheetCornerRadius;
    self.cancelButton.layer.masksToBounds = YES;
    [self.cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetContainer addSubview:self.cancelButton];
}

- (UIButton *)actionButtonWithTitle:(NSString *)title color:(UIColor *)color bold:(BOOL)bold {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setTitleColor:[color colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    button.titleLabel.font = bold ? [UIFont boldSystemFontOfSize:20.0] : [UIFont systemFontOfSize:20.0];
    button.backgroundColor = [UIColor clearColor];
    return button;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat safeBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeBottom = self.safeAreaInsets.bottom;
    }
    CGFloat width = CGRectGetWidth(self.bounds) - kActionSheetHorizontalMargin * 2;
    CGFloat titleHeight = self.titleLabel ? kActionSheetTitleHeight : 0;
    CGFloat actionContentHeight = titleHeight + self.actionButtons.count * kActionSheetButtonHeight;
    CGFloat cancelHeight = self.cancelButtonTitle.length > 0 ? kActionSheetButtonHeight : 0;
    CGFloat spacing = cancelHeight > 0 ? kActionSheetGroupSpacing : 0;
    CGFloat maximumActionHeight = CGRectGetHeight(self.bounds) - safeBottom - kActionSheetBottomMargin * 2 - spacing - cancelHeight;
    CGFloat actionHeight = MIN(actionContentHeight, maximumActionHeight);
    CGFloat containerHeight = actionHeight + spacing + cancelHeight;
    CGFloat bottom = kActionSheetBottomMargin + safeBottom;

    self.restingSheetFrame = CGRectMake(kActionSheetHorizontalMargin,
                                        CGRectGetHeight(self.bounds) - bottom - containerHeight,
                                        width,
                                        containerHeight);
    if (!self.sheetPositionLocked) {
        self.sheetContainer.frame = self.restingSheetFrame;
    }
    self.actionGroup.frame = CGRectMake(0, 0, width, actionHeight);
    self.actionGroup.contentSize = CGSizeMake(width, actionContentHeight);
    self.titleLabel.frame = CGRectMake(0, 0, width, titleHeight);

    CGFloat top = titleHeight;
    for (NSUInteger index = 0; index < self.actionButtons.count; index++) {
        UIButton *button = self.actionButtons[index];
        button.frame = CGRectMake(0, top, width, kActionSheetButtonHeight);
        if (index > 0 || self.titleLabel) {
            UIView *separator = [self separatorAtY:top];
            [self.actionGroup insertSubview:separator belowSubview:button];
        }
        top += kActionSheetButtonHeight;
    }

    self.cancelButton.frame = CGRectMake(0, actionHeight + spacing, width, cancelHeight);
}

- (UIView *)separatorAtY:(CGFloat)y {
    NSInteger tag = 10000 + (NSInteger)round(y);
    UIView *separator = [self.actionGroup viewWithTag:tag];
    if (!separator) {
        separator = [[UIView alloc] initWithFrame:CGRectZero];
        separator.tag = tag;
        separator.backgroundColor = [UIColor colorWithWhite:0.82 alpha:1.0];
    }
    CGFloat scale = [UIScreen mainScreen].scale;
    separator.frame = CGRectMake(0, y, CGRectGetWidth(self.actionGroup.bounds), 1.0 / scale);
    return separator;
}

- (void)showInViewController:(UIViewController *)viewController {
    UIView *hostView = viewController.view.window ?: viewController.view;
    self.frame = hostView.bounds;
    [hostView addSubview:self];
    [self layoutIfNeeded];

    self.sheetPositionLocked = YES;
    self.backgroundControl.alpha = 0;
    CGPoint restingCenter = CGPointMake(CGRectGetMidX(self.restingSheetFrame), CGRectGetMidY(self.restingSheetFrame));
    self.sheetContainer.center = CGPointMake(restingCenter.x,
                                             CGRectGetHeight(self.bounds) + CGRectGetHeight(self.sheetContainer.bounds) / 2.0);
    [UIView animateWithDuration:0.28
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.backgroundControl.alpha = 1;
        self.sheetContainer.center = restingCenter;
    } completion:^(BOOL finished) {
        if (!self.dismissing) {
            self.sheetPositionLocked = NO;
            self.sheetContainer.frame = self.restingSheetFrame;
        }
    }];
}

- (void)actionButtonPressed:(UIButton *)button {
    NSInteger index = button.tag;
    BitherActionSheetHandler handler = self.handler;
    [self dismissWithCompletion:^{
        if (handler) {
            handler(index);
        }
    }];
}

- (void)dismiss {
    [self dismissWithCompletion:nil];
}

- (void)dismissWithCompletion:(void (^)(void))completion {
    if (self.dismissing) {
        return;
    }
    self.dismissing = YES;
    self.userInteractionEnabled = NO;

    CALayer *sheetPresentationLayer = (CALayer *)self.sheetContainer.layer.presentationLayer;
    CGPoint currentPosition = sheetPresentationLayer ? sheetPresentationLayer.position : self.sheetContainer.layer.position;
    [self.sheetContainer.layer removeAllAnimations];
    self.sheetContainer.layer.position = currentPosition;

    CALayer *backgroundPresentationLayer = (CALayer *)self.backgroundControl.layer.presentationLayer;
    CGFloat currentBackgroundAlpha = backgroundPresentationLayer ? backgroundPresentationLayer.opacity : self.backgroundControl.alpha;
    [self.backgroundControl.layer removeAllAnimations];
    self.backgroundControl.alpha = currentBackgroundAlpha;

    self.sheetPositionLocked = YES;
    CGPoint offscreenCenter = CGPointMake(currentPosition.x,
                                          CGRectGetHeight(self.bounds) + CGRectGetHeight(self.sheetContainer.bounds) / 2.0);
    [UIView animateWithDuration:0.22
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        self.backgroundControl.alpha = 0;
        self.sheetContainer.center = offscreenCenter;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.handler = nil;
        if (completion) {
            completion();
        }
    }];
}

@end
