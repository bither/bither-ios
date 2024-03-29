//
//  ImportHDAccountSeedController.m
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
//
//  Created by songchenwen on 15/4/28.
//

#import <Bitheri/BTHDAccount.h>
#import <Bitheri/BTAddressManager.h>
#import "ImportHDAccountSeedController.h"
#import "KeyboardController.h"
#import "DialogPassword.h"
#import "DialogReplaceWorld.h"
#import "WorldListCell.h"
#import "UIViewController+PiShowBanner.h"
#import "BTBIP39.h"
#import "DialogProgress.h"
#import "PeerUtil.h"
#import "DialogCentered.h"
#import "DialogWithActions.h"
#import "AppDelegate.h"
#import "BTWordsTypeManager.h"


#define kTextFieldHorizontalMargin (10)

#define kTextFieldFontSize (14)
#define kTextFieldHeight (35)
#define kTextFieldHorizontalMargin (10)
#define WORD_COUNT 24
#define kZHTW_WORDS @"BIP39ZhTWWords"


@interface ImportHDAccountSeedController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
        , UITextFieldDelegate, KeyboardControllerDelegate, DialogPasswordDelegate, DialogOperationDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray *worldListArray;
@property(weak, nonatomic) IBOutlet UIView *worldListView;
@property(weak, nonatomic) IBOutlet UIView *topBar;
@property(weak, nonatomic) IBOutlet UIButton *btnOk;
@property(weak, nonatomic) IBOutlet UIView *inputView;
@property(weak, nonatomic) IBOutlet UIButton *btnDone;
@property(weak, nonatomic) IBOutlet UITextField *tfKey;
@property KeyboardController *kc;
@property(nonatomic, strong) BTBIP39 *bTBIP39;

@end

@implementation ImportHDAccountSeedController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view bringSubviewToFront:self.topBar];
//    self.tfKey.keyboardType = UIKeyboardTypeASCIICapable;
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.sectionInset = UIEdgeInsetsMake(6, 4, 0, 4);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 10;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.worldListView addSubview:self.collectionView];
    self.worldListArray = [NSMutableArray new];

    [self.collectionView registerClass:[WorldListCell class] forCellWithReuseIdentifier:@"WorldListCell"];

    self.tfKey.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"hdm_import_word_list_empty_message" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:0.5]}];
    [self configureTextField:self.tfKey];
    self.tfKey.returnKeyType = UIReturnKeyDone;
    self.collectionView.alwaysBounceVertical = YES;
    self.kc = [[KeyboardController alloc] initWithDelegate:self];
    self.btnDone.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.tfKey canBecomeFirstResponder]) {
        [self.tfKey becomeFirstResponder];
    }
}

- (void)keyboardFrameChanged:(CGRect)frame {
    CGRect toolBarFrame = self.inputView.frame;
    CGFloat totalHeight = frame.origin.y;
    CGFloat top = totalHeight - toolBarFrame.size.height;
    self.inputView.frame = CGRectMake(toolBarFrame.origin.x, top, toolBarFrame.size.width, toolBarFrame.size.height);
    self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x, self.collectionView.frame.origin.y, self.collectionView.frame.size.width, top - self.collectionView.frame.origin.y - self.topBar.frame.size.height);
    if (self.worldListArray.count > 3) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.worldListArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    }
}


- (void)configureTextField:(UITextField *)tf {
    tf.textColor = [UIColor blackColor];
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
    tf.keyboardType = UIKeyboardTypeDefault;
}


- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addWorld:(id)sender {
    NSString *world = [self.tfKey.text toLowercaseStringWithEn];
    world = [world stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.bTBIP39 = [BTBIP39 instanceForWord:world];
    if ([[self.bTBIP39 getWords] containsObject:world]) {
        [self.worldListArray addObject:world];
        [self.collectionView reloadData];

        self.tfKey.text = @"";
        if (self.worldListArray.count > 3) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.worldListArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        }

    } else {
        [self showMsg:NSLocalizedString(@"hdm_import_word_list_wrong_word_warn", nil)];
    }
    self.btnDone.enabled = (self.worldListArray.count % 3 == 0);
    if (self.worldListArray.count == WORD_COUNT) {
        [self donePressed:self.btnDone];
    }
}

- (IBAction)donePressed:(id)sender {
    if ([self.tfKey isFirstResponder]) {
        [self.tfKey resignFirstResponder];
    }
    DialogPassword *dialogPassword = [[DialogPassword alloc] initWithDelegate:self];
    [dialogPassword showInWindow:self.view.window];
}
#pragma mark - import HDAccount chose style
- (void)onPasswordEntered:(NSString *)password {
    [self reloadHdAccountTransactionsData: password];
}
#pragma mark - reloadHdAccountTransactionsData
- (void)reloadHdAccountTransactionsData:(NSString*) password{
    __block DialogProgress *dp = [[DialogProgress alloc] initWithMessage:NSLocalizedString(@"Please wait…", nil)];
    __block ImportHDAccountSeedController *s = self;
    [dp showInWindow:self.view.window completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if ([s isZhTw] && ![s.bTBIP39.wordList isEqualToString:kZHTW_WORDS]) {
                s.bTBIP39.wordList = kZHTW_WORDS;
            }
            NSString *code = [s.bTBIP39 toMnemonicWithArray:self.worldListArray];
            NSData *mnemonicCodeSeed = [s.bTBIP39 toEntropy:code];
            if (!mnemonicCodeSeed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showMsg:NSLocalizedString(@"Import failed.", nil)];
                    [dp dismiss];
                });
                return;
            }
            BOOL isHot = [BTSettings instance].getAppMode == HOT;
            if (isHot) {
                BTHDAccount *account;
                @try {
                    account = [[BTHDAccount alloc] initWithMnemonicSeed:mnemonicCodeSeed btBip39:s.bTBIP39 password:password fromXRandom:NO syncedComplete:NO addMode:Import andGenerationCallback:nil];
                } @catch (NSException *e) {
                    if ([e isKindOfClass:[DuplicatedHDAccountException class]]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [dp dismissWithCompletion:^{
                                [self showMsg:NSLocalizedString(@"import_hd_account_failed_duplicated", nil)];
                            }];
                        });
                        return;
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [dp dismissWithCompletion:^{
                                [self showMsg:NSLocalizedString(@"Import failed.", nil)];
                            }];
                        });
                        return;
                    }
                }
                
                if (!account) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showMsg:NSLocalizedString(@"Import failed.", nil)];
                        [dp dismiss];
                    });
                    return;
                }
                
                [[PeerUtil instance] stopPeer];
                [BTAddressManager instance].hdAccountHot = account;
                [[PeerUtil instance] startPeer];
            } else {
                BTHDAccountCold *account;
                @try {
                    account = [[BTHDAccountCold alloc] initWithMnemonicSeed:mnemonicCodeSeed btBip39:s.bTBIP39 andPassword:password addMode:Import];
                } @catch (NSException *e) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showMsg:NSLocalizedString(@"Import failed.", nil)];
                        [dp dismiss];
                    });
                    return;
                }
            }
            [[BTWordsTypeManager instance] saveWordsTypeValue:s.bTBIP39.wordList];
            [BTBIP39 sharedInstance].wordList = s.bTBIP39.wordList;
            dispatch_async(dispatch_get_main_queue(), ^{
                [dp dismiss];
                [self showMsg:NSLocalizedString(isHot ? @"Import hot wallet success." : @"Import success.", nil)];
                
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [s.navigationController popViewControllerAnimated:YES];
            });
        });
    }];

}

- (BOOL)isZhTw {
    for (NSString *word in self.worldListArray) {
        self.bTBIP39 = [BTBIP39 instanceForWord:word];
        if ([_bTBIP39.wordList isEqualToString:kZHTW_WORDS]) {
            return true;
        }
    }
    return false;
}

- (void)showMsg:(NSString *)msg {
    [self showBannerWithMessage:msg belowView:self.topBar];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.tfKey) {
        [self addWorld:self.btnOk];
    }
    return YES;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section; {
    return self.worldListArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
    WorldListCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"WorldListCell" forIndexPath:indexPath];
    NSString *world = [self.worldListArray objectAtIndex:indexPath.row];
    [cell setWorld:world index:indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath; {
    return (CGSize) {([UIScreen mainScreen].bounds.size.width - 4 * 6) / 3, 50};
}

- (void)replaceWorld:(NSString *)newWorld index:(int)index {
    if (index <= self.worldListArray.count - 1) {
        [self.worldListArray replaceObjectAtIndex:index withObject:newWorld];
    }
    [self.collectionView reloadData];

}

- (void)deleteWorld:(NSString *)world index:(int)index {
    if (index <= self.worldListArray.count - 1) {
        [self.worldListArray removeObjectAtIndex:index];
    }
    [self.collectionView reloadData];

}

- (void)beginOperation {
    if ([self.tfKey isFirstResponder]) {
        [self.tfKey resignFirstResponder];
    }
}
@end
