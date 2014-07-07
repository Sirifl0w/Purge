//
//  PurgePrefsListController.m
//  PurgePrefs
//
//  Created by Sirifl0w on 25.01.2014.
//  Copyright (c) 2014 Sirifl0w. All rights reserved.
//

#import "PurgePrefsListController.h"
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import <sys/utsname.h>

#define STATUS_PATH @"/var/lib/dpkg/status"
#define DPKGL_PATH @"/var/tmp/dpkgl.log"

@interface UIImage (Purge)

+ (id)imageNamed:(id)arg1 inBundle:(id)arg2;

@end

@interface UIAlertView (Purge)

- (id)initWithTitle:(id)arg1 message:(id)arg2 delegate:(id)arg3 cancelButtonTitle:(id)arg4 otherButtonTitles:(id)arg5;

@end

@interface UITableViewCell (Purge)

- (void)setSeparatorColor:(id)arg1;

@end

@interface PSTableCell : UITableViewCell
@end

@implementation PurgePrefsListController

- (instancetype)init {
    self = [super init];

    if (self) {
        
        UIImage *heartNorm = [UIImage imageNamed:@"PurgeHeart.png" inBundle:[NSBundle bundleForClass:self.class]];
        UIImage *heartSelected = [UIImage imageNamed:@"PurgeHeartSelected.png" inBundle:[NSBundle bundleForClass:self.class]];
        UIImage *infoNorm = [UIImage imageNamed:@"PurgeInfo.png" inBundle:[NSBundle bundleForClass:self.class]];
        UIImage *infoSelected = [UIImage imageNamed:@"PurgeInfoSelected.png" inBundle:[NSBundle bundleForClass:self.class]];
        
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareButton setFrame:CGRectMake(0, 0, heartNorm.size.width, heartNorm.size.height)];
        [shareButton setImage:heartNorm forState:UIControlStateNormal];
        [shareButton setImage:heartSelected forState:UIControlStateHighlighted];
        [shareButton addTarget:self action:@selector(tweetTheLove) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *moreInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreInfoButton setFrame:CGRectMake(0, 0, infoNorm.size.width, infoNorm.size.height)];
        [moreInfoButton setImage:infoNorm forState:UIControlStateNormal];
        [moreInfoButton setImage:infoSelected forState:UIControlStateHighlighted];
        [moreInfoButton addTarget:self action:@selector(moreInfo) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:moreInfoButton] autorelease];
        self.navigationItem.titleView = shareButton;

    }

    return self;
}

- (void)viewWillAppear:(BOOL)arg1 {

    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [super viewWillAppear:arg1];
}

- (void)viewWillDisappear:(BOOL)arg1 {
    
    self.navigationController.navigationBar.tintColor = nil;
    
    [super viewWillDisappear:arg1];
}


- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"PurgePrefs" target:self] retain];
	}
    
	return _specifiers;
}

- (void)tweetTheLove {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
    
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"I love killing apps with #Purge, check it out for free in Cydia. cc/ @Sirifl0w"];
        [self presentViewController:tweetSheet animated:YES completion:nil];
        
    }
}
- (void)moreInfo {
    
    NSString *_content = @"Developed by @Sirifl0w \n Icon designed by @iJailpod \n \n Contact via Twitter or link below for support. \n v1.3";
    
    UIAlertView *_moreInfo = [[UIAlertView alloc] initWithTitle:@"About Purge" message:_content delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Support", nil];
    [_moreInfo show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *deviceType = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]; // credit to OhhMee and others
        
        NSString *emailTitle = @"Support: Purge (v1.3)";
        NSString *deviceInfo = [NSString stringWithFormat:@"%@-%@", deviceType, [[UIDevice currentDevice] systemVersion]];
        NSString *_fileName;
        NSData *fileData;
        
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        [mailCont setSubject:emailTitle];
        [mailCont setMessageBody:deviceInfo isHTML:NO];
        [mailCont setToRecipients:[NSArray arrayWithObject:@"sirifl0w@gmail.com"]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:DPKGL_PATH]) {
            fileData = [NSData dataWithContentsOfFile:DPKGL_PATH];
            _fileName = @"dpkgl.log";
        } else {
            fileData = [NSData dataWithContentsOfFile:STATUS_PATH];  // probably shooting myself in the foot here :/
            _fileName = @"status";
        }
        
        [mailCont addAttachmentData:fileData mimeType:@"text/plain" fileName:_fileName];
        [self presentViewController:mailCont animated:YES completion:NULL];
        
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(int)result error:(NSError *)error{
    [self dismissModalViewControllerAnimated:YES];
}

@end

@interface P_Header : PSTableCell
{
    UIView *headerView;
    UILabel *P_HeaderLabel;
    UILabel *P_HeaderSubLabel;
    UIButton *P_TwitterButton;
    UIButton *P_GithubButton;
}
@end


@implementation P_Header

- (void)setFrame:(struct CGRect)arg1 {
    
    [super setFrame:CGRectMake(0, 20, self.frame.size.width, 130)];
    
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])){
        
        self.backgroundColor = [UIColor clearColor];
        
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 130)];
        
        P_HeaderLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 65)] autorelease];
        [P_HeaderLabel setText:@"Purge"];
        [P_HeaderLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:55]];
        [P_HeaderLabel setTextAlignment:NSTextAlignmentCenter];
        [P_HeaderLabel setTextColor:[UIColor blackColor]];
        [P_HeaderLabel setBackgroundColor:[UIColor clearColor]];
        
        P_HeaderSubLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 65, self.frame.size.width, 25)] autorelease];
        [P_HeaderSubLabel setText:@"© 2013-2014, Sirifl0w"];
        [P_HeaderSubLabel setFont:[UIFont systemFontOfSize:14]];
        [P_HeaderSubLabel setTextAlignment:NSTextAlignmentCenter];
        [P_HeaderSubLabel setTextColor:[UIColor grayColor]];
        [P_HeaderSubLabel setBackgroundColor:[UIColor clearColor]];

        P_TwitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [P_TwitterButton setFrame:CGRectMake(0, 90, self.frame.size.width/2, 40)];
        [P_TwitterButton setImage:[UIImage imageNamed:@"twitterLogo.png" inBundle:[NSBundle bundleForClass:self.class]] forState:UIControlStateNormal];
        [P_TwitterButton addTarget:self action:@selector(P_Twitter) forControlEvents:UIControlEventTouchUpInside];
        [P_TwitterButton setBackgroundColor:[UIColor clearColor]];

        P_GithubButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [P_GithubButton setFrame:CGRectMake(self.frame.size.width/2, 90, self.frame.size.width/2, 40)];
        [P_GithubButton setImage:[UIImage imageNamed:@"githubLogo.png" inBundle:[NSBundle bundleForClass:self.class]] forState:UIControlStateNormal];
        [P_GithubButton addTarget:self action:@selector(P_Github) forControlEvents:UIControlEventTouchUpInside];
        [P_GithubButton setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:headerView];
		[headerView addSubview:P_HeaderSubLabel];
        [headerView addSubview:P_HeaderLabel];
        [headerView addSubview:P_TwitterButton];
        [headerView addSubview:P_GithubButton];
    }
    
	return self;
}

- (void)layoutSubviews {
    [self setSeparatorColor:[UIColor clearColor]];
    [super layoutSubviews];
}


- (void)P_Twitter
{
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/Sirifl0w"]];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitterrific:///profile?screen_name=Sirifl0w"]];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=Sirifl0w"]];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/Sirifl0w"]];
	}
}


- (void)P_Github
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.github.com/sirifl0w/purge"]];
}

@end

