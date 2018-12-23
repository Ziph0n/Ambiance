#import <Cephei/HBPreferences.h>
#import "DPHue/DPHue.h"
#import "DPHue/DPHueLight.h"
#import "MediaRemote.h"
#import "LEColorPicker/LEColorPicker.h"
#import <libactivator/libactivator.h>
#import "libfollow/libfollow.h"

/*@interface BBSectionIcon
@end

@interface BBBulletin
@property (nonatomic,copy) NSString *sectionID;
@property (nonatomic,readonly) BBSectionIcon *sectionIcon; 
@end

@interface UIImage (UIApplicationIconPrivate)
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier format:(int)format;
@end*/

extern "C" UIImage *_UICreateScreenUIImageWithRotation(BOOL rotate);

static HBPreferences *preferences;
static NSString *host;
static NSString *username;
static NSInteger mode;
static BOOL firstUse;

static LEColorPicker *colorPicker;

static NSArray *getHSBfromImage(UIImage *image) {
    NSMutableArray *HSBArray = [[NSMutableArray alloc] init];
    LEColorScheme *colorScheme = [colorPicker colorSchemeFromImage:image];
    UIColor *uiColor = [colorScheme backgroundColor];
	CGFloat hue, saturation, brightness, alpha;
	[uiColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
	int realHue = hue * 65535;
	int realSaturation = saturation * 254;
	int realBrightness = brightness * 254;
	[HSBArray addObject:@(realHue)];
	[HSBArray addObject:@(realSaturation)];
	[HSBArray addObject:@(realBrightness)];
	[colorScheme release];
	[uiColor release];
	return HSBArray;
}

@interface LAOnOff : NSObject <LAListener>
@end

@implementation LAOnOff

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	DPHue *someHue = [[DPHue alloc] initWithHueHost:host username:username];
	[someHue readWithCompletion:^(DPHue *hueLight, NSError *err) {
	    DPHueLight *light = hueLight.lights[0];
	    if (light.on) {
			[hueLight allLightsOff];
	    } else {
			[hueLight allLightsOn];
	    }
	}];
    [event setHandled:YES];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
    DPHue *someHue = [[DPHue alloc] initWithHueHost:host username:username];
    [someHue readWithCompletion:^(DPHue *hueLight, NSError *err) {
    	[hueLight allLightsOff];
    }];
}

+ (void)load {
    if ([LASharedActivator isRunningInsideSpringBoard]) {
        [LASharedActivator registerListener:[self new] forName:@"com.ziph0n.ambiance.switchonoff"];
    }
}

@end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
	%orig;

	colorPicker = [[LEColorPicker alloc] init];

	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(ambianceUpdateNowPlaying) name:(NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
	[nc addObserver:self selector:@selector(ambianceUpdateNowPlayingStatus) name:(NSString *)kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification object:nil];

	if (mode == 2) {
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateScreenMode) userInfo:nil repeats:YES];
	}
}

%new
- (void)ambianceUpdateNowPlaying {
	if (mode == 1) {
		MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
	        NSData *artwork = [(NSDictionary *)result objectForKey:(NSData *)(NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
	        UIImage *albumImage = [UIImage imageWithData:artwork];

			NSArray *HSBArray = getHSBfromImage(albumImage);
			
			DPHue *someHue = [[DPHue alloc] initWithHueHost:host username:username];
			[someHue readWithCompletion:^(DPHue *hueLight, NSError *err) {
			    for (DPHueLight *light in hueLight.lights) {
		        	light.on = TRUE;
				    light.hue = [HSBArray objectAtIndex:0];
					light.saturation = [HSBArray objectAtIndex:1];
				    light.brightness = [HSBArray objectAtIndex:2];
					[light write];
					[light release];
		    	}
			}];
			
			[HSBArray release];
			[someHue release];
		});
	}
}

%new
- (void)ambianceUpdateNowPlayingStatus {
	if (mode == 1) {
		MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
	        NSData *artwork = [(NSDictionary *)result objectForKey:(NSData *)(NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
	        UIImage *albumImage = [UIImage imageWithData:artwork];

			NSArray *HSBArray = getHSBfromImage(albumImage);

			DPHue *someHue = [[DPHue alloc] initWithHueHost:host username:username];
			[someHue readWithCompletion:^(DPHue *hueLight, NSError *err) {
			    for (DPHueLight *light in hueLight.lights) {
		        	light.on = TRUE;
				    light.hue = [HSBArray objectAtIndex:0];
					light.saturation = [HSBArray objectAtIndex:1];
				    light.brightness = [HSBArray objectAtIndex:2];
					[light write];
					[light release];
		    	}
			}];
			
			[HSBArray release];
			[someHue release];
		});
	}
}

%new
- (void)updateScreenMode {
	if (mode == 2) {
    	UIImage *screenshot = _UICreateScreenUIImageWithRotation(TRUE);
    	NSArray *HSBArray = getHSBfromImage(screenshot);

		DPHue *someHue = [[DPHue alloc] initWithHueHost:host username:username];
		[someHue readWithCompletion:^(DPHue *hueLight, NSError *err) {
			for (DPHueLight *light in hueLight.lights) {
	        	light.on = TRUE;
			    light.hue = [HSBArray objectAtIndex:0];
				light.saturation = [HSBArray objectAtIndex:1];
			    light.brightness = [HSBArray objectAtIndex:2];
				[light write];
				[light release];
	    	}
			
		}];
		[screenshot release];
		[HSBArray release];
		[someHue release];
	}
}

%end

%hook SBLockScreenManager
- (void)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2 {
    if (firstUse) {
        FBShowTwitterFollowAlert(@"Ambiance", @"Hey there! Thanks for using Ambiance! If you'd like to follow @Ziph0n on Twitter for more updates, tweak giveaways and other cool stuff, hit the button below!", @"Ziph0n");
        firstUse = FALSE;
        [preferences setBool:firstUse forKey:@"firstUse"];
    }
    %orig;
}
%end

// Started implementing notifications alert, 

/*%hook BBServer

- (void)publishBulletin:(BBBulletin*)bulletin destinations:(unsigned long long)arg2 alwaysToLockScreen:(BOOL)arg3 {
	%orig;
    NSString *bundleID = bulletin.sectionID;
	UIImage* iconImage = [UIImage _applicationIconImageForBundleIdentifier:bundleID format:11];
    NSArray *HSBArray = getHSBfromImage(iconImage);
    DPHue *someHue = [[DPHue alloc] initWithHueHost:host username:username];
	[someHue readWithCompletion:^(DPHue *hueLight, NSError *err) {
		for (DPHueLight *light in hueLight.lights) {
        	light.on = TRUE;
		    light.hue = [HSBArray objectAtIndex:0];
			light.saturation = [HSBArray objectAtIndex:1];
		    light.brightness = [HSBArray objectAtIndex:2];
			[light write];
			[light release];
    	}
	}];
}

%end*/

%ctor {
    preferences = [HBPreferences preferencesForIdentifier:@"com.ziph0n.ambiance"];
    [preferences registerObject:&host default:nil forKey:@"host"];
    [preferences registerObject:&username default:nil forKey:@"username"];
    [preferences registerInteger:&mode default:3 forKey:@"mode"];
    [preferences registerBool:&firstUse default:YES forKey:@"firstUse"];
}