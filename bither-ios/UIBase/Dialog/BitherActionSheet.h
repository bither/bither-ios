//
//  BitherActionSheet.h
//  bither-ios
//

#import <UIKit/UIKit.h>

typedef void (^BitherActionSheetHandler)(NSInteger buttonIndex);

@interface BitherActionSheet : UIView

- (instancetype)initWithTitle:(NSString *)title
                 buttonTitles:(NSArray *)buttonTitles
             cancelButtonTitle:(NSString *)cancelButtonTitle
                       handler:(BitherActionSheetHandler)handler;

- (void)showInViewController:(UIViewController *)viewController;
- (void)dismiss;

@end
