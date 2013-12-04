#import <UIKit/UIKit.h>

@interface SBAppSliderController : UIViewController 
{
    UIView *_pageView;

}

@property(readonly, nonatomic) NSArray *applicationList;
- (void)_quitAppAtIndex:(unsigned int)arg1;
- (void)_layout;

@end

static UIAlertView *killAlert;

%hook SBAppSliderController

-(void)_layout {

	%orig();

	UIView *appPage = MSHookIvar<UIView *>(self, "_pageView");

    UILongPressGestureRecognizer *longHoldPage = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showKillAlert:)];
    [appPage addGestureRecognizer:longHoldPage];
    [longHoldPage release];


}

%new

-(void)showKillAlert:(UILongPressGestureRecognizer *)recognizer {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
        if ([[self applicationList] count] > 1) {

    killAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to kill all apps?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];

} else { 
    
    killAlert = [[UIAlertView alloc] initWithTitle:nil message:@"You have no apps in the app switcher." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];

}
    [killAlert show];
    [killAlert release];
}
}

%new

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
        if (buttonIndex != 0) {
            for (id identifier in [self applicationList]) {
                        if (![identifier isEqualToString:@"com.apple.springboard"]) {
                                [self _quitAppAtIndex:[[self applicationList] indexOfObject:identifier]];
                                [[%c(SBUIController) sharedInstance] dismissSwitcherAnimated:YES];
                                }
                            }
}
        else {
        // do nothing
        }
}

%end