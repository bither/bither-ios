#import <Foundation/Foundation.h>


typedef enum {
    HDMColdSeedQRCode, HDMColdPhrase
} ImportHDSeedType;

@interface ImportHDMCold : NSObject

- (instancetype)initWithController:(UIViewController *)controller content:(NSString *)content worldList:(NSArray *)array passwrod:(NSString *)passwrod importHDSeedType:(ImportHDSeedType)importHDSeedType;

- (void)importHDSeed;
@end