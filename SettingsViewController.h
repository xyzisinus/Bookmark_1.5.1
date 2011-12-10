//
//  SettingsViewController.h
//  AudiobooksPlus
//
//  Created by Barry Ezell on 7/24/09.
//  Copyright 2009 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "IFGenericTableViewController.h"

@interface SettingsViewController : IFGenericTableViewController <UIAlertViewDelegate, MFMailComposeViewControllerDelegate> {	
	BOOL autoshowTutorial;
}

@property (nonatomic) BOOL autoshowTutorial;

- (void)tutorialButtonWasPressed;
- (void)faqButtonWasPressed;
- (void)supportButtonWasPressed;
- (void)tellFriendButtonWasPressed;
- (void)upToDateButtonWasPressed;
- (void)topBooksButtonWasPressed;
- (void)upgrayyedButtonWasPressed;
- (void)sendEmailWithSubject:(NSString *)subject andBody:(NSString *)body andTo:(NSString *)to;
- (void)sendEmailWithSubject:(NSString *)subject andBody:(NSString *)body andTo:(NSString *)to useHtml:(BOOL)html;
- (void)openWebViewToURLString:(NSString *)urlString;
- (void)settingsHelpButtonWasPressed;
- (void)resetDbWasPressed;
- (void)resetSettingsWasPressed;
- (void)timeRibbonButtonWasPressed;
- (void)soundsButtonWasPressed;
- (void)showLogView;
- (BOOL)canReachServer;

@end
