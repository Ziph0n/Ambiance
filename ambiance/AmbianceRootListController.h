#import "../DPHue/DPHue.h"
#import "../DPHue/DPHueDiscover.h"
#import <CepheiPrefs/HBRootListController.h>

@interface AmbianceRootListController : HBRootListController <DPHueDiscoverDelegate>

@property (nonatomic, strong) DPHueDiscover *dhd;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSString *foundHueHost;

@end
