//  CheckViewController.m
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
#import "CheckViewController.h"
#import "CheckScoreAndBgAnimatableView.h"
#import "DialogPassword.h"
#import "UIViewController+PiShowBanner.h"
#import "CheckPrivateKeyCell.h"
#import <Bitheri/BTPasswordSeed.h>
#import <Bitheri/BTAddressManager.h>

#define kResetScoreAnim (99)
#define kAddScoreAnimPrefix (100)

@interface CheckViewController ()<CheckScoreAndBgAnimatableViewDelegate,DialogPasswordDelegate, UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray* privateKeys;
    NSString* _password;
    NSMutableArray* dangerKeys;
    NSUInteger checkingIndex;
}
@property (weak, nonatomic) IBOutlet CheckScoreAndBgAnimatableView *vHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblPoints;
@property (weak, nonatomic) IBOutlet UIView *vPointsContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblCheckStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *vContainer;
@property (weak, nonatomic) IBOutlet UIImageView *ivCheckProgress;

@property (atomic) BOOL checking;

@end

@implementation CheckViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.vContainer.frame = CGRectMake(self.vContainer.frame.origin.x, self.vContainer.frame.origin.y, self.vContainer.frame.size.width, self.vHeader.frame.size.height);
    self.lblCheckStatus.text = NSLocalizedString(@"Private keys are safe.", nil);
    privateKeys = [[NSMutableArray alloc]init];
    dangerKeys = [[NSMutableArray alloc]init];
    self.vHeader.delegate = self;
    self.vHeader.score = 100;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
}

- (IBAction)checkPressed:(id)sender {
    if([BTAddressManager instance].privKeyAddresses.count > 0){
        if(!self.checking){
            [[[DialogPassword alloc]initWithDelegate:self]showInWindow:self.view.window];
        }
    }else{
        [self showBannerWithMessage:NSLocalizedString(@"No private keys", nil) belowView:nil belowTop:0 autoHideIn:1 withCompletion:nil];
    }
}

-(void)onPasswordEntered:(NSString *)password{
    self.checking = YES;
    _password = password;
    [self refreshPrivateKeys];
    [UIView animateWithDuration:kCheckScoreAndBgAnimatableViewDefaultAnimationDuration animations:^{
        self.vPointsContainer.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1.2, 1.2), 0, 10);
        self.btnCheck.alpha = 0;
        self.vContainer.frame = CGRectMake(self.vContainer.frame.origin.x, self.vContainer.frame.origin.y, self.vContainer.frame.size.width, self.view.frame.size.height - self.vContainer.frame.origin.y * 2);
    } completion:^(BOOL finished) {
        self.btnCheck.hidden = YES;
        self.lblCheckStatus.text = NSLocalizedString(@"Checking private keys...", nil);
        [self.vHeader animateToScore:0 withAnimationId:kResetScoreAnim];
        [self moveProgress];
    }];
}

-(void)onAnimation:(NSInteger)animationId endWithScore:(NSUInteger)score{
    if(animationId == kResetScoreAnim){
        [self beginCheck];
    }else if(animationId == (kAddScoreAnimPrefix + privateKeys.count - 1) && self.checking){
        [self checkFinished];
    }
}

-(void)beginCheck{
    checkingIndex = 0;
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger totalCount = privateKeys.count;
        NSUInteger safeCount = 0;
        NSString *password = _password;
        _password = nil;
        for (BTAddress *a in privateKeys){
            BOOL result = [[[BTPasswordSeed alloc]initWithBTAddress:a]checkPassword:password];
            if(result){
                safeCount++;
            }
            NSUInteger score = floorf((float)safeCount / (float)totalCount * 100.0f);
            checkingIndex++;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.vHeader animateToScore:score withAnimationId:kAddScoreAnimPrefix + checkingIndex - 1];
                [self.tableView reloadData];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:checkingIndex - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            });
        }
        password=nil;
    });
}

-(void)checkFinished{
    if(self.vHeader.score < 100){
        self.lblCheckStatus.text = NSLocalizedString(@"Private keys in danger.", nil);
    }else{
        self.lblCheckStatus.text = NSLocalizedString(@"Private keys are safe.", nil);
    }
    self.btnCheck.hidden = NO;
    self.btnCheck.alpha = 0;
    [self.ivCheckProgress.layer removeAllAnimations];
    [self.ivCheckProgress setHidden:YES];
    [UIView animateWithDuration:kCheckScoreAndBgAnimatableViewDefaultAnimationDuration animations:^{
        self.vPointsContainer.transform = CGAffineTransformIdentity;
        self.btnCheck.alpha = 1;
    } completion:^(BOOL finished) {
        self.checking = NO;
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return privateKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BTAddress* address = privateKeys[indexPath.row];
    CheckPrivateKeyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell showAddress:address.address checking:checkingIndex == indexPath.row checked:checkingIndex > indexPath.row safe:![dangerKeys containsObject:address]];
    return cell;
}

-(void)displayScore:(NSUInteger)score{
    self.lblPoints.text = [NSString stringWithFormat:@"%lu", (unsigned long)score];
}

-(void)moveProgress{
    self.ivCheckProgress.hidden=NO;
    [UIView animateWithDuration:1.2f animations:^{
        self.ivCheckProgress.frame=CGRectMake(300-17, 0, self.ivCheckProgress.frame.size.width, self.ivCheckProgress.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished&&self.checking) {
            self.ivCheckProgress.frame=CGRectMake(0, 0, self.ivCheckProgress.frame.size.width, self.ivCheckProgress.frame.size.height);
            [self moveProgress];
        }
    }];
}
-(void)refreshPrivateKeys{
    [privateKeys removeAllObjects];
    [privateKeys addObjectsFromArray:[BTAddressManager instance].privKeyAddresses];
    [dangerKeys removeAllObjects];
    [self.tableView reloadData];
}

@end
