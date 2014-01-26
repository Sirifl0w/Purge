//
//  PurgePrefsListController.m
//  PurgePrefs
//
//  Created by Sirifl0w on 25.01.2014.
//  Copyright (c) 2014 Sirifl0w. All rights reserved.
//

#import "PurgePrefsListController.h"

@implementation PurgePrefsListController

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"PurgePrefs" target:self] retain];
	}
    
	return _specifiers;
}

- (void)followme:(id)specifier
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.twitter.com/Sirifl0w"]];
}


- (void)PSourceCode:(id)specifier
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.github.com/sirifl0w/purge"]];
}

@end
