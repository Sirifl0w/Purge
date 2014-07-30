//
//  PurgePrefsListController.h
//  PurgePrefs
//
//  Created by Sirifl0w on 25.01.2014.
//  Copyright (c) 2014 Sirifl0w. All rights reserved.
//

#import "Preferences/PSListController.h"

@protocol MFMailComposeViewControllerDelegate <NSObject>
@end

@interface PurgePrefsListController : PSListController <MFMailComposeViewControllerDelegate>
@end

@interface MFMailComposeViewController : UINavigationController
- (id)_addAttachmentData:(id)arg1 mimeType:(id)arg2 fileName:(id)arg3;
- (void)addAttachmentData:(id)arg1 mimeType:(id)arg2 fileName:(id)arg3;
- (void)setMessageBody:(id)arg1 isHTML:(BOOL)arg2;
- (void)setToRecipients:(id)arg1;
- (void)setSubject:(id)arg1;
@property(nonatomic, weak) id <MFMailComposeViewControllerDelegate> mailComposeDelegate;
@end