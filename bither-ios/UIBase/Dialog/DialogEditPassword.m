//
//  DialogEditPassword.m
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

#import "DialogEditPassword.h"
#import "UserDefaultsUtil.h"
#import "KeyboardController.h"
#import "UIBaseUtil.h"
#import "PasswordStrengthUtil.h"
#import "DialogAlert.h"
#import <AudioToolbox/AudioToolbox.h>
#import <Bitheri/BTAddressManager.h>

#define kOuterPadding (1)
#define kInnerMargin (10)
#define kWidth (240)

#define kTextFieldFontSize (14)
#define kTextFieldHeight (35)
#define kTextFieldHorizontalMargin (10)

#define kButtonFontSize (15)
#define kButtonHeight (36)

#define kTitleFontSize (18)
#define kTitleHeight (20)

#define kSubTitleFontSize (12)
#define kSubTitleHeight (13)

#define kShakeTime (7)
#define kShakeDuration (0.04f)
#define kShakeWaveSize (5)

#define kCheckingFontSize (16)

@interface DialogEditPassword () <UITextFieldDelegate, KeyboardControllerDelegate>
@property UIView *vChecking;
@property UIView *vContent;
@property UILabel *lblSubTitle;
@property UITextField *tfPassword;
@property UITextField *tfPasswordNew;
@property UITextField *tfPasswordConfirm;
@property UIProgressView *pvStrength;
@property UILabel *lblStrength;
@property UIView *vStrength;
@property UIButton *btnConfirm;
@property UIButton *btnCancel;
@property KeyboardController *kc;
@end

@implementation DialogEditPassword
- (instancetype)initWithDelegate:(NSObject <DialogEditPasswordDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [self firstConfigure];
        [self configureKeyboard];
    }
    return self;
}


- (void)confirmPressed:(id)sender {
    NSString *p = self.tfPassword.text;
    NSString *nP = self.tfPasswordNew.text;
    NSString *cP = self.tfPasswordConfirm.text;
    if (![StringUtil compareString:nP compare:cP]) {
        [self showError:NSLocalizedString(@"New passwords not same", nil)];
        return;
    }
    if ([StringUtil isEmpty:p] || [StringUtil isEmpty:nP] || [StringUtil isEmpty:cP]) {
        [self shake];
        return;
    }
    if ([[UserDefaultsUtil instance] getPasswordStrengthCheck]) {
        PasswordStrengthUtil *strength = [PasswordStrengthUtil checkPassword:nP];
        if (!strength.passed) {
            [self.tfPasswordNew becomeFirstResponder];
            [self shakeStrength];
            return;
        }
        if (strength.warning) {
            [self endEditing:YES];
            __block DialogEditPassword *d = self;
            [[[DialogAlert alloc] initWithMessage:[NSString stringWithFormat:NSLocalizedString(@"password_strength_warning", nil), strength.name] confirm:^{
                [d edit];
            }                              cancel:^{
                [self.tfPasswordNew becomeFirstResponder];
            }] showInWindow:self.window];
            return;
        }
    }
    [self edit];
}

- (void)edit {
    __block NSString *p = self.tfPassword.text;
    __block NSString *nP = self.tfPasswordNew.text;
    self.vChecking.hidden = NO;
    self.vContent.hidden = YES;
    [self endEditing:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        BOOL result = [self checkPassword:p];
        if (!result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!result) {
                    self.vChecking.hidden = YES;
                    self.vContent.hidden = NO;
                    [self showError:NSLocalizedString(@"Password wrong.", nil)];
                    [self.tfPassword becomeFirstResponder];
                }
            });
        } else {
            BOOL success = NO;
            if ([BTPasswordSeed hasPasswordSeed]) {
                success = [[BTAddressManager instance] changePassphraseWithOldPassphrase:p andNewPassphrase:nP];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [self dismissWithMsg:NSLocalizedString(@"Change password success", nil)];
                } else {
                    [self dismissWithMsg:NSLocalizedString(@"Change password failed", nil)];
                }
            });
        }
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    });
}

- (void)dismissWithMsg:(NSString *)msg {
    [self dismissWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(showMsg:)]) {
            [self.delegate showMsg:msg];
        }
    }];
}

- (void)showError:(NSString *)error {
    self.lblSubTitle.text = error;
    self.lblSubTitle.textColor = [UIColor redColor];
    self.vStrength.hidden = YES;
    self.lblSubTitle.hidden = NO;
    CGRect frame = self.tfPassword.frame;
    frame.origin.y = CGRectGetMaxY(self.lblSubTitle.frame) + kInnerMargin;
    self.tfPassword.frame = frame;
    [self shake];
}

- (void)shake {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self shakeTime:kShakeTime interval:kShakeDuration length:kShakeWaveSize];
}

- (void)shakeStrength {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self.vStrength shakeTime:kShakeTime interval:kShakeDuration length:kShakeWaveSize];
}

- (void)dismissError {
    self.lblSubTitle.text = [self subTitle];
    self.lblSubTitle.textColor = [UIColor whiteColor];
}

- (void)dialogWillDismiss {
    [self endEditing:YES];
    [super dialogWillDismiss];
}

- (void)cancelPressed:(id)sender {
    [self dismiss];
}

- (void)dialogDidShow {
    [super dialogDidShow];
    [self.tfPassword becomeFirstResponder];
}

- (void)configureKeyboard {
    self.kc = [[KeyboardController alloc] initWithDelegate:self];
}

- (void)firstConfigure {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, kWidth, kOuterPadding * 2 + kTextFieldHeight * 3 + kSubTitleHeight + kTitleHeight + kButtonHeight + kInnerMargin * 5);
    self.touchOutSideToDismiss = NO;

    self.vChecking = [[UIView alloc] initWithFrame:self.vContent.frame];
    self.vChecking.backgroundColor = [UIColor clearColor];
    self.vChecking.autoresizingMask = self.vContent.autoresizingMask;
    [self addSubview:self.vChecking];

    self.vContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.vContent.backgroundColor = [UIColor clearColor];
    self.vContent.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.vContent];

    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(kOuterPadding, kOuterPadding, kWidth - kOuterPadding * 2, kTitleHeight)];
    lblTitle.font = [UIFont systemFontOfSize:kTitleFontSize];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    lblTitle.text = [self title];

    UILabel *lblSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(kOuterPadding, CGRectGetMaxY(lblTitle.frame), kWidth - kOuterPadding, kSubTitleHeight)];
    lblSubTitle.font = [UIFont systemFontOfSize:kSubTitleFontSize];
    lblSubTitle.textColor = [UIColor whiteColor];
    lblSubTitle.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    lblSubTitle.text = [self subTitle];
    self.lblSubTitle = lblSubTitle;

    [self.vContent addSubview:lblTitle];
    [self.vContent addSubview:lblSubTitle];

    UIView *vStrength = [[UIView alloc] initWithFrame:CGRectMake(kOuterPadding, CGRectGetMaxY(lblSubTitle.frame) + kInnerMargin / 2 + kTextFieldHeight, kWidth - kOuterPadding * 2, kSubTitleHeight)];
    vStrength.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    vStrength.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    vStrength.hidden = YES;
    self.vStrength = vStrength;
    [self.vContent addSubview:vStrength];

    UIProgressView *pvStrength = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    pvStrength.frame = CGRectMake(0, (vStrength.frame.size.height - pvStrength.frame.size.height) / 2, vStrength.frame.size.width, pvStrength.frame.size.height);
    pvStrength.transform = CGAffineTransformMakeScale(1, vStrength.frame.size.height / pvStrength.frame.size.height);
    pvStrength.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    pvStrength.trackTintColor = [UIColor colorWithWhite:0.3 alpha:0.3];
    self.pvStrength = pvStrength;
    [self.vStrength addSubview:pvStrength];

    UILabel *lblStrength = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, vStrength.frame.size.width, vStrength.frame.size.height)];
    lblStrength.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    lblStrength.textColor = [UIColor whiteColor];
    lblStrength.font = [UIFont systemFontOfSize:kSubTitleFontSize * 0.8f];
    lblStrength.textAlignment = NSTextAlignmentCenter;
    lblStrength.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.lblStrength = lblStrength;
    [self.vStrength addSubview:lblStrength];

    self.tfPassword = [[UITextField alloc] initWithFrame:CGRectMake(kOuterPadding, CGRectGetMaxY(lblSubTitle.frame) + kInnerMargin, kWidth - kOuterPadding * 2, kTextFieldHeight)];
    self.tfPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Old Password", nil) attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:0.5]}];
    [self configureTextField:self.tfPassword];
    self.tfPassword.returnKeyType = UIReturnKeyNext;
    CGFloat buttonTop = CGRectGetMaxY(self.tfPassword.frame) + kInnerMargin;
    [self.vContent addSubview:self.tfPassword];

    self.tfPasswordNew = [[UITextField alloc] initWithFrame:CGRectMake(kOuterPadding, CGRectGetMaxY(self.tfPassword.frame) + kInnerMargin, kWidth - kOuterPadding * 2, kTextFieldHeight)];
    self.tfPasswordNew.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"New Password", nil) attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:0.5]}];
    [self configureTextField:self.tfPasswordNew];
    self.tfPasswordNew.returnKeyType = UIReturnKeyNext;
    buttonTop = CGRectGetMaxY(self.tfPasswordNew.frame) + kInnerMargin;
    [self.vContent addSubview:self.tfPasswordNew];

    self.tfPasswordConfirm = [[UITextField alloc] initWithFrame:CGRectMake(kOuterPadding, CGRectGetMaxY(self.tfPasswordNew.frame) + kInnerMargin, kWidth - kOuterPadding * 2, kTextFieldHeight)];
    self.tfPasswordConfirm.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Confirm New Password", nil) attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:0.5]}];
    [self configureTextField:self.tfPasswordConfirm];
    self.tfPasswordConfirm.returnKeyType = UIReturnKeyDone;
    buttonTop = CGRectGetMaxY(self.tfPasswordConfirm.frame) + kInnerMargin;
    [self.vContent addSubview:self.tfPasswordConfirm];

    self.btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(kOuterPadding, buttonTop, (kWidth - kOuterPadding * 2 - kInnerMargin) / 2, kButtonHeight)];
    [self.btnCancel setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
    self.btnCancel.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [self.btnCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self.btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btnCancel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.btnCancel addTarget:self action:@selector(cancelPressed:) forControlEvents:UIControlEventTouchUpInside];

    self.btnConfirm = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.btnCancel.frame) + kInnerMargin, buttonTop, (kWidth - kOuterPadding * 2 - kInnerMargin) / 2, kButtonHeight)];
    [self.btnConfirm setBackgroundImage:[UIImage imageNamed:@"dialog_btn_bg_normal"] forState:UIControlStateNormal];
    self.btnConfirm.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [self.btnConfirm setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [self.btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btnConfirm.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.btnConfirm addTarget:self action:@selector(confirmPressed:) forControlEvents:UIControlEventTouchUpInside];

    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, CGRectGetMaxY(self.btnConfirm.frame) + kOuterPadding);

    [self.vContent addSubview:self.btnCancel];
    [self.vContent addSubview:self.btnConfirm];

    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activity.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    UILabel *lblChecking = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    lblChecking.font = [UIFont systemFontOfSize:kCheckingFontSize];
    lblChecking.textColor = [UIColor whiteColor];
    lblChecking.numberOfLines = 2;
    lblChecking.text = NSLocalizedString(@"Changing password\nDo not turn off the screen", nil);
    lblChecking.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    CGRect rect = [lblChecking.text boundingRectWithSize:CGSizeMake(self.frame.size.width - activity.frame.size.width - kInnerMargin, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : lblChecking.font, NSParagraphStyleAttributeName : [NSParagraphStyle defaultParagraphStyle]} context:nil];
    rect.size.width = ceilf(rect.size.width);
    rect.size.height = ceilf(rect.size.height);
    CGFloat width = activity.frame.size.width + kInnerMargin + rect.size.width;
    CGFloat left = (self.frame.size.width - width) / 2;
    activity.frame = CGRectMake(left, (self.frame.size.height - activity.frame.size.height) / 2, activity.frame.size.width, activity.frame.size.height);
    lblChecking.frame = CGRectMake(CGRectGetMaxX(activity.frame) + kInnerMargin, (self.frame.size.height - rect.size.height) / 2, rect.size.width, rect.size.height);
    activity.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    lblChecking.autoresizingMask = activity.autoresizingMask;
    [activity startAnimating];
    [self.vChecking addSubview:activity];
    [self.vChecking addSubview:lblChecking];
    self.vChecking.hidden = YES;

    [self.vContent bringSubviewToFront:self.tfPassword];
    if (self.tfPasswordConfirm) {
        [self.vContent bringSubviewToFront:self.tfPasswordConfirm];
    }
}

- (void)keyboardFrameChanged:(CGRect)frame {
    CGFloat totalHeight = frame.origin.y;
    CGFloat top = (totalHeight - self.frame.size.height) / 2;
    self.frame = CGRectMake(self.frame.origin.x, top, self.frame.size.width, self.frame.size.height);
}

- (BOOL)checkPassword:(NSString *)password {
    BTPasswordSeed *passwordSeed = [BTPasswordSeed getPasswordSeed];
    if (passwordSeed) {
        return [passwordSeed checkPassword:password];
    }
    return YES;
}

- (NSString *)title {
    return NSLocalizedString(@"Change Password", nil);
}

- (NSString *)subTitle {
    return NSLocalizedString(@"Length: 6 - 43", nil);
}

- (void)configureTextField:(UITextField *)tf {
    tf.textColor = [UIColor whiteColor];
    tf.background = [UIImage imageNamed:@"textfield_activated_holo_light"];
    tf.delegate = self;
    tf.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    tf.font = [UIFont systemFontOfSize:kTextFieldFontSize];
    tf.borderStyle = UITextBorderStyleNone;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kTextFieldHorizontalMargin, tf.frame.size.height)];
    leftView.backgroundColor = [UIColor clearColor];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kTextFieldHorizontalMargin, tf.frame.size.height)];
    rightView.backgroundColor = [UIColor clearColor];
    tf.leftView = leftView;
    tf.rightView = rightView;
    tf.leftViewMode = UITextFieldViewModeAlways;
    tf.rightViewMode = UITextFieldViewModeAlways;
    tf.enablesReturnKeyAutomatically = YES;
    tf.keyboardType = UIKeyboardTypeASCIICapable;
    tf.secureTextEntry = YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self dismissError];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(configureStrength) object:nil];
    if ([textField isEqual:self.tfPasswordNew] || [textField isEqual:self.tfPasswordConfirm]) {
        if ([StringUtil validPartialPassword:string]) {
            if (textField.text.length - range.length + string.length <= 43) {
                if (textField == self.tfPasswordNew || textField == self.tfPasswordConfirm) {
                    [self performSelector:@selector(configureStrength) withObject:nil afterDelay:0.1];
                }
                return YES;
            }
        }

    } else {
        if ([StringUtil validPartialPassword:string]) {
            if (textField.text.length - range.length + string.length <= 43) {
                return YES;
            }
        }

    }
    return NO;
}

- (void)configureStrength {
    NSString *password = self.tfPasswordNew.text;
    if (password.length > 0 && !self.tfPassword.isFirstResponder) {
        if (!self.lblSubTitle.hidden) {
            self.lblSubTitle.hidden = YES;
            self.vStrength.hidden = NO;
            self.vStrength.alpha = 0.1;
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frame = self.tfPassword.frame;
                frame.origin.y = CGRectGetMinY(self.lblSubTitle.frame) + kInnerMargin / 2;
                self.tfPassword.frame = frame;
                self.vStrength.alpha = 1;
            }];
        }
        PasswordStrengthUtil *strength = [PasswordStrengthUtil checkPassword:password];
        float progress = strength.progress;
        if (self.pvStrength.progress != progress) {
            self.pvStrength.tintColor = strength.color;
            self.lblStrength.text = strength.name;
            [self.pvStrength setProgress:progress animated:YES];
        }
    } else {
        if (self.lblSubTitle.hidden) {
            self.vStrength.hidden = YES;
            self.lblSubTitle.hidden = NO;
            self.lblSubTitle.alpha = 0.1;
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frame = self.tfPassword.frame;
                frame.origin.y = CGRectGetMaxY(self.lblSubTitle.frame) + kInnerMargin;
                self.tfPassword.frame = frame;
                self.lblSubTitle.alpha = 1;
            }];
        }
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self configureStrength];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.tfPassword) {
        [self.tfPasswordNew becomeFirstResponder];
    } else if (textField == self.tfPasswordNew) {
        [self.tfPasswordConfirm becomeFirstResponder];
    } else if (textField == self.tfPasswordConfirm) {
        [self confirmPressed:self.btnConfirm];
    }
    return YES;
}

@end
