// Copyright Barry Ezell. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
//  1. Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in the
//     documentation and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of its contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  SettingsViewController.m
//  AudiobooksPlus
//
//  Created by Barry Ezell on 7/24/09.
//

#import "SettingsViewController.h"
#import "Reachability.h"
#import "WebViewController.h"
#import "IFLinkCellController.h"
#import "IFButtonCellController.h"
#import "IFSwitchCellController.h"
#import "IFTextCellController.h"
#import	"IFChoiceCellController.h"
#import	"IFValueCellController.h"
#import "LogViewController.h"
#import "TimeRibbonSettingsViewController.h"
#import "SoundsViewController.h"
#import "CoreDataUtility.h"
#import "MasterMusicPlayer.h"
#import "UIDevice+Hardware.h"

@implementation SettingsViewController

@synthesize autoshowTutorial;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //back button for child views
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" 
																   style:UIBarButtonItemStyleBordered 
																  target:nil 
																  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release]; 
	
	if (autoshowTutorial) {
		[self tutorialButtonWasPressed];
	}
}

- (void)constructTableGroups {
	/*
	  BTE: see the example project in dev/cocoa/GenericTableView
	 */
			
	//Help & faqs, etc.
	NSMutableArray *infoCells = [NSMutableArray array];
	IFButtonCellController *tutorialButton = [[[IFButtonCellController alloc] 
											   initWithLabel:@"Tutorial" 
											   withAction:@selector(tutorialButtonWasPressed) 
											   onTarget:self] autorelease];
	[infoCells addObject:tutorialButton];

	IFButtonCellController *faqButton = [[[IFButtonCellController alloc] 
										  initWithLabel:@"FAQs" 
										  withAction:@selector(faqButtonWasPressed) 
										  onTarget:self] autorelease];
	[infoCells addObject:faqButton];
	
	IFButtonCellController *emailButton = [[[IFButtonCellController alloc] 
											initWithLabel:@"Email Support" 
											withAction:@selector(supportButtonWasPressed) 
											onTarget:self] autorelease];
	[infoCells addObject:emailButton];
	
	IFButtonCellController *tellFriendButton = [[[IFButtonCellController alloc] 
												 initWithLabel:@"Tell a Friend" 
												 withAction:@selector(tellFriendButtonWasPressed) 
												 onTarget:self] autorelease];
	[infoCells addObject:tellFriendButton];
	
	IFButtonCellController *upToDateButton = [[[IFButtonCellController alloc] 
												 initWithLabel:@"Stay Up to Date" 
												 withAction:@selector(upToDateButtonWasPressed) 
												 onTarget:self] autorelease];
	[infoCells addObject:upToDateButton];
	
#ifdef PODCASTS_LITE
	IFButtonCellController *upgrayyedButton = [[[IFButtonCellController alloc] 
											   initWithLabel:@"Upgrade to Bookmark" 
											   withAction:@selector(upgrayyedButtonWasPressed) 
											   onTarget:self] autorelease];
	[infoCells addObject:upgrayyedButton];
#else
    /*
	IFButtonCellController *topBooksButton = [[[IFButtonCellController alloc] 
											   initWithLabel:@"Top Books on iTunes" 
											   withAction:@selector(topBooksButtonWasPressed) 
											   onTarget:self] autorelease];
	[infoCells addObject:topBooksButton];
     */
#endif
	
	//Settings
	NSMutableArray *settingCells = [NSMutableArray array];
	
	IFButtonCellController *settingsHelpButton = [[[IFButtonCellController alloc] 
												   initWithLabel:@"Guide to settings" 
												   withAction:@selector(settingsHelpButtonWasPressed) 
												   onTarget:self] autorelease];;
	[settingCells addObject:settingsHelpButton];
	
	IFButtonCellController *showTimeRibbonVCButton = [[[IFButtonCellController alloc]
													   initWithLabel:@"Time Ribbon Settings"
													   withAction:@selector(timeRibbonButtonWasPressed)
													   onTarget:self] autorelease];
	[settingCells addObject:showTimeRibbonVCButton];

	
	IFSwitchCellController *quickBookmarkSwitch = [[[IFSwitchCellController alloc]
													initWithLabel:@"Quick Bookmarking On" 
													atKey:QUICK_BKMK_DEFAULT 
													inModel:model] autorelease];
	[settingCells addObject:quickBookmarkSwitch];
	
	IFSwitchCellController *autoplaySwitch = [[[IFSwitchCellController alloc] 
											   initWithLabel:@"Autoplay last track" 
											   atKey:AUTOPLAY 
											   inModel:model] autorelease];
	[settingCells addObject:autoplaySwitch];
    
    IFSwitchCellController *expandedSearchSwitch = [[[IFSwitchCellController alloc]
                                                     initWithLabel:@"Expanded book search" 
                                                     atKey:EXPANDED_BOOK_SEARCH 
                                                     inModel:model] autorelease];
    [settingCells addObject:expandedSearchSwitch];
	
	IFSwitchCellController *keepAwakeSwitch = [[[IFSwitchCellController alloc] 
												initWithLabel:@"Keep awake Heads-Up" 
												atKey:KEEP_AWAKE_HUD
												inModel:model] autorelease];
	[settingCells addObject:keepAwakeSwitch];
		
	NSArray *choices = [NSArray arrayWithObjects:@"Nothing", @"Play/Pause", @"Jump back 15 sec.", @"Toggle Heads-Up Mode", @"Quick bookmark",nil];
	IFChoiceCellController *shakeChoices = [[[IFChoiceCellController alloc] initWithLabel:@"When device is shaken:" 
																			   andChoices:choices 
																					atKey:SHAKE_ACTION 
																				  inModel:model] autorelease];
	[settingCells addObject:shakeChoices];
	
	NSArray *bkmkChoiceArray = [NSArray arrayWithObjects:@"Date and Time", @"Bookmark #",@"Blank",nil];
	IFChoiceCellController *bkmkChoices = [[[IFChoiceCellController alloc] initWithLabel:@"Default bookmark title:" 
																			  andChoices:bkmkChoiceArray
																				   atKey:BOOKMARK_TITLE
																				 inModel:model] autorelease];
	[settingCells addObject:bkmkChoices];
    
    
	IFButtonCellController *showSoundsVCButton = [[[IFButtonCellController alloc]
													   initWithLabel:@"Sound Settings"
													   withAction:@selector(soundsButtonWasPressed)
													   onTarget:self] autorelease];
	[settingCells addObject:showSoundsVCButton];
	
#ifndef PODCASTS_LITE
	IFSwitchCellController *deadManSwitch = [[[IFSwitchCellController alloc] 
												initWithLabel:@"Sleep Timer rock for +10" 
												atKey:SLEEP_TIMER_DEAD_MAN
												inModel:model] autorelease];
	[settingCells addObject:deadManSwitch];
#endif
		
	//IFSwitchCellController *keepAwakeSwitch = [[[IFSwitchCellController alloc] initWithLabel:@"Keep awake Heads-Up" atKey:@"keepAwakeInHUD" inModel:model] autorelease];
	//[settingCells addObject:keepAwakeSwitch];
	
	// Advanced settings
	NSMutableArray *advancedSettingCells = [[NSMutableArray alloc] init];
    
	IFButtonCellController *resetSettingsButton = [[[IFButtonCellController alloc] 
                                                 initWithLabel:@"Reset Settings" 
                                                 withAction:@selector(resetSettingsWasPressed) 
                                                 onTarget:self] autorelease];
	[advancedSettingCells addObject:resetSettingsButton];
	
	IFButtonCellController *resetDbButton = [[[IFButtonCellController alloc] 
												   initWithLabel:@"Reset Database" 
												   withAction:@selector(resetDbWasPressed) 
												   onTarget:self] autorelease];
	[advancedSettingCells addObject:resetDbButton];
		
	/*
	 Once all the groups have been defined, a collection is created that allows the generic table view
	 controller to construct the views, manage user input, and update the model(s):

	 */
		
	tableGroups = [[NSArray arrayWithObjects:infoCells, settingCells, advancedSettingCells, nil] retain];
	
	tableHeaders = [[NSArray arrayWithObjects:@"Info Center", @"Settings", @"Advanced Options", nil] retain];
	
	NSString *footer = [NSString stringWithFormat:@"Bookmark version %@\nCopyright 2011 DockMarket LLC",
						[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
	
	//the count has to match tableGroups!!!!
	tableFooters = [[NSArray arrayWithObjects:[NSNull null], [NSNull null], footer, nil] retain];		
	
	[advancedSettingCells release];
}

- (void)openWebViewToURLString:(NSString *)urlString {
	//first test connectivity
	if (![self canReachServer]) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"No connection" message:@"Cannot connect to the server. Please make sure you are online and try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil] autorelease];
		[alert show];		
		return;
	}
	
	WebViewController *web = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
	NSURL *url = [NSURL URLWithString:urlString];
	web.url = url;
	[self.navigationController pushViewController:web animated:YES];
	[web release];
}

- (void)tutorialButtonWasPressed {		
	[self openWebViewToURLString:@"http://bookmarkapp.com/help"];
}

- (void)faqButtonWasPressed {
	[self openWebViewToURLString:@"http://bookmarkapp.com/faq"];
}

- (void)upgrayyedButtonWasPressed {
	[self openWebViewToURLString:@"http://bookmarkapp.com/upgrade"];
}
																																		
- (void)topBooksButtonWasPressed {
	[self openWebViewToURLString:@"http://bookmarkapp.com/books"];
}
												   
- (void)settingsHelpButtonWasPressed {
	[self openWebViewToURLString:@"http://bookmarkapp.com/settings"];
}

- (void)resetDbWasPressed {   
    
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Reset Database" 
                                                     message:@"This will delete all bookmarks and notes! To continue, type Reset in the box below.\n\n\n" // IMPORTANT
                                                    delegate:self 
                                           cancelButtonTitle:@"Cancel" 
                                           otherButtonTitles:@"Continue", nil];
    prompt.tag = 0;
    
    UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectMake(12.0, 120.0, 260.0, 25.0)] autorelease]; 
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setPlaceholder:@"type Reset here"];
    [prompt addSubview:textField];
    
    /*
    // set place
    [prompt setTransform:CGAffineTransformMakeTranslation(0.0, 110.0)];
     */
    [prompt show];
    [prompt release];
    
    // set cursor and show keyboard
    [textField becomeFirstResponder];
}

- (void)resetSettingsWasPressed {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Reset Settings" 
                                                     message:@"Reset all settings to defaults?"
                                                   delegate:self 
                                          cancelButtonTitle:@"Cancel" 
                                          otherButtonTitles:@"Reset",nil] autorelease];
    alert.tag = 1;
    [alert show];
}

- (void)timeRibbonButtonWasPressed {
	TimeRibbonSettingsViewController *trVC = [[TimeRibbonSettingsViewController alloc] initWithNibName:@"TimeRibbonSettingsViewController" bundle:nil];
	[self.navigationController pushViewController:trVC animated:YES];
	[trVC release];
}

- (void)soundsButtonWasPressed {
    SoundsViewController *soundVC = [[SoundsViewController alloc] initWithNibName:@"SoundsViewController" bundle:nil];
    [self.navigationController pushViewController:soundVC animated:YES];
    [soundVC release];
}

- (void)showLogView {
	LogViewController *lvc = [[LogViewController alloc] initWithNibName:@"LogViewController" bundle:nil];
	[self.navigationController pushViewController:lvc animated:YES];
	[lvc release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0 && buttonIndex == 1) {
        
        // Get the textview subview and ensure its value is "reset"
        NSString *msg = @"";
        for (UIView *view in [alertView subviews]) {
            if ([view isKindOfClass:[UITextField class]]) {
                UITextField *tf = (UITextField *)view;
                if ([tf.text caseInsensitiveCompare:@"reset"] == NSOrderedSame) {
                    [[CoreDataUtility sharedUtility] deleteDb];
                    msg = @"Database was reset. Please restart Bookmark now";
                } else {
                    msg = @"Reset was canceled";
                }
            }
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil 
                                                            message:msg 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    } else if (alertView.tag == 1 && buttonIndex == 1) {
        [[DMUserDefaults sharedInstance] resetDefaults];
        [[MasterMusicPlayer instance] setPlayerVolumes];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil 
                                                            message:@"Reset complete" 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

- (BOOL)canReachServer {
	Reachability *reach = [Reachability reachabilityWithHostName:@"bookmarkapp.com"];
	NetworkStatus netStat = [reach currentReachabilityStatus];
	if (netStat == ReachableViaWiFi || netStat == ReachableViaWWAN) {
		return YES;
	} 
	
	return NO;
}

- (IBAction)supportButtonWasPressed {
    NSString *body = [NSString stringWithFormat:@"\n\n\n\n\nBookmark version: %@\niOS version: %@\nDevice: %@",
                      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                      [[UIDevice currentDevice] systemVersion],
                      [[UIDevice currentDevice] platformString]];
    
	[self sendEmailWithSubject:@"Support request" andBody:body andTo:@"support@bookmarkapp.com" useHtml:NO];
}

- (IBAction)tellFriendButtonWasPressed {
	NSString *messageBody = @"I use the Bookmark audiobook player for iOS and thought you might like to try it too.  Check it out on the <a href=\"http://click.linksynergy.com/fs-bin/stat?id=eXyB0R5Jlew&offerid=146261&type=3&subid=0&tmpid=1826&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fus%252Fapp%252Fbookmark%252Fid326290323%253Fmt%253D8%2526uo%253D6%2526partnerId%253D30\">App Store</a>";
    [self sendEmailWithSubject:@"Bookmark audiobook player" andBody:messageBody andTo:nil];
}

- (void)upToDateButtonWasPressed {
	[self openWebViewToURLString:@"http://bookmarkapp.com/uptodate"];
}

- (void)sendEmailWithSubject:(NSString *)subject andBody:(NSString *)body andTo:(NSString *)to {
    [self sendEmailWithSubject:subject 
                       andBody:body 
                         andTo:to 
                       useHtml:YES];
}

- (void)sendEmailWithSubject:(NSString *)subject andBody:(NSString *)body andTo:(NSString *)to useHtml:(BOOL)html {
	MFMailComposeViewController *composeVC = [[MFMailComposeViewController alloc] init];    
    composeVC.mailComposeDelegate = self;    

	if (to) {
		[composeVC setToRecipients:[NSArray arrayWithObject:to]];
	}
	
    [composeVC setSubject:subject];    
	[composeVC setMessageBody:body isHTML:html];
	
    [self presentModalViewController:composeVC animated:YES];
    [composeVC release];
	
}

#pragma mark MFMailComposeViewControllerDelegate Implementation

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
