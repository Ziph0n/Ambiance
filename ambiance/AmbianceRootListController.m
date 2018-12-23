#include "AmbianceRootListController.h"
#import <Cephei/HBPreferences.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

static HBPreferences *preferences;
static NSString *hostDict;
static NSString *usernameDict;

static UIAlertView *linkAlert;

@implementation AmbianceRootListController

+ (NSString *)hb_specifierPlist {
    return @"Root";
}

+ (NSString *)hb_shareText {
    return @"Controlling my Hue Lights has never been so easy thanks to #Ambiance by @Ziph0n";
}

+(NSString *)hb_shareURL {
    return @"";
}

+ (UIColor *)hb_tintColor {
    return [UIColor colorWithRed:102.f / 255.f green:102.f / 255.f blue:102.f / 255.f alpha:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    preferences = [HBPreferences preferencesForIdentifier:@"com.ziph0n.ambiance"];
    [preferences registerObject:&usernameDict default:nil forKey:@"username"];
    [preferences registerObject:&hostDict default:nil forKey:@"host"];
    HBLogDebug(@"host = %@ / username = %@", hostDict, usernameDict)
}

- (void)link {
    linkAlert = [[UIAlertView alloc] initWithTitle:@"Searching..." 
                                                    message:@"You have 30 seconds to tap on the Bridge link button" 
                                                    delegate:self 
                                                    cancelButtonTitle:@"Cancel" 
                                                    otherButtonTitles:nil];
    [linkAlert show];
	self.dhd = [[DPHueDiscover alloc] initWithDelegate:self];
    [self.dhd discoverForDuration:30 withCompletion:^(NSMutableString *log) {
        [self discoveryTimeHasElapsed];
    }];
}

- (void)discoveryTimeHasElapsed {
    [linkAlert dismissWithClickedButtonIndex:0 animated:YES];
    self.dhd = nil;
    [self.timer invalidate];
    if (!self.foundHueHost) {
        HBLogDebug(@"Failed to find Hue");
    }
}

- (void)createUsernameAt:(NSTimer *)timer {
    NSString *host = timer.userInfo;
    HBLogDebug(@"Attempting to create username at %@", host);
    HBLogDebug(@"%@: Attempting to authenticate to %@", [NSDate date], host);
    DPHue *someHue = [[DPHue alloc] initWithHueHost:host username:usernameDict];
    [someHue readWithCompletion:^(DPHue *hue, NSError *err) {
        if (hue.authenticated) {
            [linkAlert dismissWithClickedButtonIndex:0 animated:YES];
            HBLogDebug(@"%@: Successfully authenticated\n", [NSDate date]);
            [self.timer invalidate];
            hostDict = hue.host;
            HBLogDebug(@"hostDict = %@", hostDict);
        } else {
            HBLogDebug(@"%@: Authentication failed, will try to create username\n", [NSDate date]);
            [someHue registerUsername];
            HBLogDebug(@"Press Button On Hue!");
        }
    }];
}

- (void)foundHueAt:(NSString *)host discoveryLog:(NSMutableString *)log {
    DPHue *someHue = [[DPHue alloc] initWithHueHost:host username:usernameDict];
    [someHue readWithCompletion:^(DPHue *hue, NSError *err) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(createUsernameAt:) userInfo:host repeats:YES];
    }];
    [preferences setObject:host forKey:@"host"];
    HBLogDebug(@"host = %@", host);
    HBLogDebug(@"log = %@", log);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self discoveryTimeHasElapsed];
    }
}



- (void)turnon {
    DPHue *someHue = [[DPHue alloc] initWithHueHost:hostDict username:usernameDict];
    [someHue readWithCompletion:^(DPHue *hue, NSError *err) {
         [hue allLightsOn];
    }];
}

- (void)turnoff {
    DPHue *someHue = [[DPHue alloc] initWithHueHost:hostDict username:usernameDict];
    [someHue readWithCompletion:^(DPHue *hue, NSError *err) {
         [hue allLightsOff];
    }];
}

-(void)respring {
    system("killall -9 SpringBoard");
}

- (void)reddit {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.reddit.com/user/Ziph0n/"]];
}

- (void)sendEmail {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:ziph0ntweak@gmail.com?subject=Ambiance"]];
}

- (void)website {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https//www.ziph0n.com/"]];
}

#pragma clang diagnostic pop

@end
