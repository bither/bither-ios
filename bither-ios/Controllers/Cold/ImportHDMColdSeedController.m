#import "ImportHDMColdSeedController.h"
#import "WorldListCell.h"
#import "KeyboardController.h"
#import "UIViewController+PiShowBanner.h"
#import "BTBIP39.h"
#import "ImportHDMCold.h"
#import "DialogPassword.h"

#define kTextFieldHorizontalMargin (10)


#define kTextFieldFontSize (14)
#define kTextFieldHeight (35)
#define kTextFieldHorizontalMargin (10)
#define WORD_COUNT 24


@interface ImportHDMColdSeedController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
        , UITextFieldDelegate, KeyboardControllerDelegate, DialogPasswordDelegate, DialogOperationDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray *worldListArray;
@property(weak, nonatomic) IBOutlet UIView *worldListView;
@property(weak, nonatomic) IBOutlet UIView *topBar;
@property(weak, nonatomic) IBOutlet UIButton *btnOk;
@property(weak, nonatomic) IBOutlet UIView *inputView;

@property(weak, nonatomic) IBOutlet UITextField *tfKey;

@property KeyboardController *kc;
@end

@implementation ImportHDMColdSeedController {


}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
    tf.keyboardType = UIKeyboardTypeASCIICapable;

}


- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addWorld:(id)sender {
    NSString *world = [self.tfKey.text toLowercaseStringWithEn];
    if ([[[BTBIP39 sharedInstance] getWords] containsObject:world]) {
        [self.worldListArray addObject:world];
        [self.collectionView reloadData];

        self.tfKey.text = @"";
        if (self.worldListArray.count > 3) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.worldListArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        }

    } else {
        [self showMsg:NSLocalizedString(@"hdm_import_word_list_wrong_word_warn", nil)];
    }
    if (self.worldListArray.count == WORD_COUNT) {
        if ([self.tfKey isFirstResponder]) {
            [self.tfKey resignFirstResponder];
        }
        DialogPassword *dialogPassword = [[DialogPassword alloc] initWithDelegate:self];
        [dialogPassword showInWindow:self.view.window];

    }
}

- (void)onPasswordEntered:(NSString *)password {


    ImportHDMCold *importPrivateKey = [[ImportHDMCold alloc] initWithController:self content:nil worldList:self.worldListArray passwrod:password importHDSeedType:HDMColdPhrase];
    [importPrivateKey importHDSeed];

}

- (void)showMsg:(NSString *)msg {
    [self showBannerWithMessage:msg belowView:nil];
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
    return (CGSize) {100, 50};
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