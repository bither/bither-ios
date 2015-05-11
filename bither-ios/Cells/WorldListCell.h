#import <Foundation/Foundation.h>
#import "DialogOperationWorld.h"

@interface WorldListCell : UICollectionViewCell

- (void)setWorld:(NSString *)world index:(NSInteger)index;

@property(weak) NSObject <DialogOperationDelegate> *delegate;
@end
