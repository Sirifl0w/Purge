#import <UIKit/UIKit.h>

@interface UIApplication (Purge)
-(void)applicationOpenURL:(id)url;
@end

@interface SBAppSliderController : UIViewController 
{
    UIView *_pageView;
    UIView *_iconView;
}
@property(readonly, nonatomic) NSArray *applicationList;
- (void)_quitAppAtIndex:(unsigned int)arg1;
- (void)_layout;
@end

@interface SBMediaController : NSObject
{}
+ (id)sharedInstance;
- (id)nowPlayingApplication;
- (BOOL)isPlaying;
@end

@interface SBUIController : NSObject
{}
+ (id)sharedInstance;
- (void)dismissSwitcherAnimated:(BOOL)arg1;
@end

@interface SBApplication
{}
@end

static UIAlertView *killAlert;
static UILongPressGestureRecognizer *longHoldPage;
static UILongPressGestureRecognizer *longHoldIcon;
static BOOL warningAlert;
static BOOL autoDismiss;

%hook SBAppSliderController

-(void)_layout {

	%orig();

	UIView *appPage = MSHookIvar<UIView *>(self, "_pageView");
    UIView *iconView = MSHookIvar<UIView *>(self, "_iconView");

    longHoldPage = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecieved:)];
    [appPage addGestureRecognizer:longHoldPage];
    [longHoldPage release];

    longHoldIcon = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecieved:)];
    [iconView addGestureRecognizer:longHoldIcon];
    [longHoldIcon release];


}

%new 

- (void)killAllApps {

    NSDictionary *purgePrefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.sirifl0w.purge.plist"];
    autoDismiss = [purgePrefs objectForKey:@"autoDismissKey"] == nil ? YES : [[purgePrefs objectForKey:@"autoDismissKey"] boolValue];

// exclude now playing app when killing all apps when music is playing.  Remember to add to preferences. 

    SBMediaController *mController = [%c(SBMediaController) sharedInstance];
    NSString *nowPlayingIdenitifer = [[mController nowPlayingApplication] displayIdentifier];

        for (id identifier in [self applicationList]) {
                    if (![identifier isEqualToString:@"com.apple.springboard"]) {
                    if ((![identifier isEqualToString:nowPlayingIdenitifer]) && [mController isPlaying]) {
                            [self _quitAppAtIndex:[[self applicationList] indexOfObject:identifier]];
                    if (autoDismiss)        
                            [[%c(SBUIController) sharedInstance] dismissSwitcherAnimated:YES];
                        } else if (![mController isPlaying]) {
                            [self _quitAppAtIndex:[[self applicationList] indexOfObject:identifier]];
                    if (autoDismiss)        
                            [[%c(SBUIController) sharedInstance] dismissSwitcherAnimated:YES];
                        }
                    }
                    }
}

%new

-(void)gestureRecieved:(UILongPressGestureRecognizer *)recognizer {

    NSDictionary *purgePrefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.sirifl0w.purge.plist"];
    warningAlert = [purgePrefs objectForKey:@"warningAlertKey"] == nil ? YES : [[purgePrefs objectForKey:@"warningAlertKey"] boolValue];
    
        if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (warningAlert) {    
        if ([[self applicationList] count] > 1) {
                killAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to kill all apps?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
} else { 
                killAlert = [[UIAlertView alloc] initWithTitle:nil message:@"You have no apps in the app switcher." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        }
                [killAlert show];
                [killAlert release];
} else {
                [self killAllApps];
}
}
}

%new

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
        if (buttonIndex != 0) {
                [self killAllApps];
} else {
        // do nothing
        }
}

%end

static void preferences() {
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.sirifl0w.purge.plist"];
    [prefs release];
}

%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    %init;
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)preferences, CFSTR("com.sirifl0w.purge.prefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    preferences();
    [pool drain];
}

@implementation NSObject (Purge)

- (void)followme
{
[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.twitter.com/Sirifl0w"]];
}

@end

