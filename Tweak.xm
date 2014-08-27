#import <UIKit/UIKit.h>

#define PURGE_PREFS @"/var/mobile/Library/Preferences/com.sirifl0w.purge.plist"
#define REDUCE_MOTION_PREFS @"/var/mobile/Library/Preferences/com.apple.Accessibility.plist"

@interface SBAppSliderController : UIViewController 
{
    UIView *_pageView;
    UIView *_iconView;
}
@property(readonly, nonatomic) NSArray *applicationList;
- (void)_quitAppAtIndex:(unsigned int)arg1;
- (void)_layout;

// custom methods
- (void)P_killAllApps;
- (void)P_dismissAppSwitcher;

@end

@interface SBMediaController : NSObject

+ (id)sharedInstance;
- (id)nowPlayingApplication;
- (BOOL)isPlaying;

@end

@interface SBUIController : NSObject

+ (id)sharedInstance;
- (void)dismissSwitcherAnimated:(BOOL)arg1;

@end

@interface SBApplication : NSObject

@property (copy) NSString *displayIdentifier;

@end

static UIAlertView *killAlert;
static BOOL warningAlert = YES;
static BOOL autoDismiss = YES;
static BOOL nowPlaying = YES;
static BOOL reduceMotionEnabled = nil;
static NSString *blacklistID;

static void loadPreferences() {
    NSDictionary *P_PREFS = [[NSDictionary alloc] initWithContentsOfFile:PURGE_PREFS];
    autoDismiss = [P_PREFS objectForKey:@"autoDismissKey"] == nil ? YES : [[P_PREFS objectForKey:@"autoDismissKey"] boolValue];
    nowPlaying = [P_PREFS objectForKey:@"nowPlayingKey"] == nil ? YES : [[P_PREFS objectForKey:@"nowPlayingKey"] boolValue];
    warningAlert = [P_PREFS objectForKey:@"warningAlertKey"] == nil ? YES : [[P_PREFS objectForKey:@"warningAlertKey"] boolValue];
    blacklistID = [P_PREFS objectForKey:@"blacklistKey"];
    [P_PREFS release];
}

static NSString *P_LocalizedString(NSString *localizedString) { 
	NSBundle *purgePrefsBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/PurgePrefs.bundle"];
	return [purgePrefsBundle localizedStringForKey:localizedString value:@"" table:nil];
}

%hook SBAppSliderController

-(void)_layout {

	%orig();

    UIView *pageView = MSHookIvar<UIView *>(self, "_pageView");
    UIView *iconView = MSHookIvar<UIView *>(self, "_iconView");

    UILongPressGestureRecognizer *longHoldPage = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecieved:)];
    UILongPressGestureRecognizer *longHoldIcon = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecieved:)];

    [pageView addGestureRecognizer:longHoldPage];
    [iconView addGestureRecognizer:longHoldIcon];

}

%new 

- (void)P_killAllApps {

	NSDictionary *PPrefs = [[NSDictionary alloc] initWithContentsOfFile:PURGE_PREFS];
	blacklistID = [PPrefs objectForKey:@"blacklistKey"];

	NSDictionary *RM_PREFS = [[NSDictionary alloc] initWithContentsOfFile:REDUCE_MOTION_PREFS];
    reduceMotionEnabled = [RM_PREFS objectForKey:@"ReduceMotionEnabled"] == nil ? YES : [[RM_PREFS objectForKey:@"ReduceMotionEnabled"] boolValue];

	SBMediaController *mediaController = [%c(SBMediaController) sharedInstance];
	NSString *nowPlayingIdenitifer = [[mediaController nowPlayingApplication] displayIdentifier];
	BOOL excludeNowPlayingApp = (nowPlaying && [mediaController isPlaying]);

    for (NSString *identifier in [self applicationList]) {
        if (![identifier isEqualToString:@"com.apple.springboard"] && ![identifier isEqualToString:blacklistID]) {
            if ((![identifier isEqualToString:nowPlayingIdenitifer]) && excludeNowPlayingApp) {
                    [self _quitAppAtIndex:[[self applicationList] indexOfObject:identifier]];
                } else if (!excludeNowPlayingApp) {
                    [self _quitAppAtIndex:[[self applicationList] indexOfObject:identifier]];
                } 
            }
        }

// bug fix, auto dismiss failed when executing gesture upon opening the app swithcer within an app. More native fixes?

    if (autoDismiss) {
    	if (reduceMotionEnabled) {  
        	[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(P_dismissAppSwitcher) userInfo:nil repeats:NO];
    	} else {
			[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(P_dismissAppSwitcher) userInfo:nil repeats:NO];
	}
}
}

%new

- (void)P_dismissAppSwitcher {
	[[%c(SBUIController) sharedInstance] dismissSwitcherAnimated:YES];
}

%new

-(void)gestureRecieved:(UILongPressGestureRecognizer *)recognizer {

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (warningAlert) {    
            if ([[self applicationList] count] > 1) {
                killAlert = [[UIAlertView alloc] initWithTitle:nil message:P_LocalizedString(@"WARNING_LABEL") delegate:self cancelButtonTitle:P_LocalizedString(@"CANCEL") otherButtonTitles:P_LocalizedString(@"YES"), nil];       
            } else { 
                killAlert = [[UIAlertView alloc] initWithTitle:nil message:P_LocalizedString(@"NO_APPS_LABEL") delegate:self cancelButtonTitle:P_LocalizedString(@"CANCEL") otherButtonTitles:nil];
            }
                [killAlert show];
                [killAlert release];
            } else {	
            [self P_killAllApps];
        }
    }
}

%new

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        [self P_killAllApps];
    }
}

%end

%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    %init;
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPreferences, CFSTR("com.sirifl0w.purge.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    loadPreferences();
    [pool drain];
}
