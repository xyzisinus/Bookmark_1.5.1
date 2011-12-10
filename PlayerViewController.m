//
//  PlayerViewController.m
//  Bookmark
//
//  Created by Barry Ezell on 1/31/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import "PlayerViewController.h"
#import "MasterMusicPlayer.h"
#import "Bookmark.h"
#import "BookmarksViewController.h"
#import "HeadsUpViewController.h"
#import "SleepTimerViewController.h"
#import "SettingsViewController.h"
#import "IFPreferencesModel.h"
#import "Reachability.h"
#import "SHK.h"
#import "SHKTwitter.h"
#import "SHKFacebook.h"

#ifdef __IPHONE_5_0 
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#endif

@implementation PlayerViewController

@synthesize managedObjectContext; 
@synthesize currentCategory;
@synthesize playImage, pauseImage;
@synthesize workTitleLabel, trackTitleLabel;
@synthesize timeElapsedLabel, timeRemainingLabel, trackNumLabel;
@synthesize toolbar, timeSlider, artView, playPauseButton;

- (void)dealloc {	
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self 
                                  name:@"PlayingItemChanged" 
                                object:nil];
    [notificationCenter removeObserver:self 
                                  name:@"PlaybackStateChanged" 
                                object:nil];
    [notificationCenter removeObserver:self 
                                  name:@"ShakeEvent" 
                                object:nil];    
    
	[playImage release];
	[pauseImage release];
	[managedObjectContext release];	
	[currentTimeUpdateTimer release];
	[workTitleLabel release];
	[trackTitleLabel release];
	[timeElapsedLabel release];
	[timeRemainingLabel release];
	[trackNumLabel release];
	[toolbar release];
	[timeSlider release];
	[artView release];
	[playPauseButton release];    
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];	
	
	// Background
    UIImageView *imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark_leather_2.png"]] autorelease];
    [self.view addSubview:imgView];
    [self.view sendSubviewToBack:imgView]; 
	
	// Navigation bar.  Bookmark count will be set in viewWillAppear.  
	forwardButton = [[UIBarButtonItem alloc] initWithTitle:@"Bookmarks (0)"
													 style:UIBarButtonItemStyleBordered
													target:self 
													action:@selector(showBookmarksView)];
	self.navigationItem.rightBarButtonItem = forwardButton;
	[forwardButton release];
            
    // Label colors
    timeElapsedLabel.textColor = PRIMARY_TEXT_COLOR;
    timeRemainingLabel.textColor = PRIMARY_TEXT_COLOR;
    workTitleLabel.textColor = SECONDARY_TEXT_COLOR;
    trackTitleLabel.textColor = SECONDARY_TEXT_COLOR;
    trackNumLabel.textColor = SECONDARY_TEXT_COLOR;
	
	//Add small sliver of background at very top of image stack.  Doing this for the work & track label animation.
	//If the label(s) are large enough, when sliding left they would appear to the left of the image.  By adding this
	//sliver on top, they'll slide underneath and the illusion won't be broken.
	
	UIImageView *sliverView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_sliver.png"]];	
	[sliverView setFrame:CGRectMake(0, 106, 10, 48)];
	[self.view addSubview:sliverView];
	[self.view bringSubviewToFront:sliverView];
	[sliverView release];	
	
	// Setup two images for play/pause
	self.playImage = [UIImage imageNamed:@"play.png"];
	self.pauseImage = [UIImage imageNamed:@"pause.png"];
	[playPauseButton setImage:pauseImage forState:UIControlStateNormal];
		
	// Add TimeRibbon
	TimeRibbonView *ribbon = [[TimeRibbonView alloc] initWithFrame:CGRectMake(0, 198, 320, 49)];
	[ribbon setDelegate:self];
	[self.view addSubview:ribbon];
	[ribbon release];
	
	// Bring to front - otherwise would be hidden behind other controls
	[self.view bringSubviewToFront:artView];
			
	// Use the iPod-connected volume view instead of a slider connected to the player	
	MPVolumeView *volView = [[MPVolumeView alloc] initWithFrame:CGRectMake(12, 11, 246, 23)];
	UIBarButtonItem *volItem = [[UIBarButtonItem alloc] initWithCustomView:volView];						
	UIBarButtonItem *elipsisItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more_actions.png"] 
																	style:UIBarButtonItemStyleBordered 
																   target:self 
																   action:@selector(moreButtonWasPressed)];
	
	NSArray *toolbarItems = [NSArray arrayWithObjects:volItem,elipsisItem,nil];	
	[toolbar setItems:toolbarItems];	
	[volView release];
	[volItem release];
	[elipsisItem release];	
	
	// Initialize touch label widths at 0, will be calculated in viewWillAppear
	trackTitleLabelWidth = 0;
	workTitleLabelWidth = 0;
	
	// The all-important MasterMusicPlayer	
	player = [MasterMusicPlayer instance];
		
	// Register for playback update notifications from MMP	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	[notificationCenter
	 addObserver: self
	 selector:    @selector (nowPlayingItemChanged:)
	 name:        @"PlayingItemChanged"
	 object:      nil];
	
	[notificationCenter
	 addObserver: self
	 selector:    @selector (playbackStateChanged:)
	 name:        @"PlaybackStateChanged"
	 object:      nil];
	
	// Listen for shake events (monitored by EventForwardingWindow.m)
	[notificationCenter
	 addObserver: self
	 selector:    @selector (shakeWasDetected)
	 name:        @"ShakeEvent"
	 object:      nil];	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];	
	
	if (!hasSetupPlayer) {				
		[self configurePlayerForCurrentWork:YES];
		hasSetupPlayer = YES;
	}

    // This is overridden for HUD so needs to be set on each appearance.
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" 
                                                                      style: UIBarButtonItemStyleBordered 
                                                                     target: nil 
                                                                     action: nil];    
    [[self navigationItem] setBackBarButtonItem: newBackButton];    
    [newBackButton release];

		
	//this will create and start the 1 sec. interval label update timer
	[self labelTimerStart];
		
	//update the bookmarks count
	[self updateBookmarksButton];
	
	//if we're returning from BookmarksViewController or HUD, should check work 
	//(because track could've changed when a bookmark was played)
	if (willReturnFromBookmarksView || willReturnFromHudView) {
		[self updateTrackAndTitleLabelsWithAnimation:NO];
		willReturnFromBookmarksView = NO;
	}
	
	//if returning from HUD, we'll need to reset album art now
	if (willReturnFromHudView) {
		artView.frame = CGRectMake(10, 54, 112, 112);
		[self.view addSubview:artView];
		willReturnFromHudView = NO;
	}
	
	//listen for image taps
	artView.delegate = self; 
	
	//listen for touch label taps
	workTitleLabel.labelDelegate = self;
	[workTitleLabel setUserInteractionEnabled:YES];
	trackTitleLabel.labelDelegate = self;
	[workTitleLabel setUserInteractionEnabled:YES];	
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];	
    	
	//Update the current work's times one more time.
	//Note the "stopped" check was added to fix a bug that would 
	//set the time of the first track in a work to 0 even after "updateAsComplete"
	//was called. It's b/c "current" was reset to the first track and the player showed
	//0 time because playback was stopped.
	if (player.playerController.playbackState != MPMusicPlaybackStateStopped) {        
		[player.currentCollection saveState];
	}	
		
	//turn off timer
	[self labelTimerStop];	
	
	//remove self as artView delegate (important for reducing retain count on self and allowing dealloc)	
	artView.delegate = nil;
	
	//remove self as touch label delegates
	workTitleLabel.labelDelegate = nil;
	trackTitleLabel.labelDelegate = nil;
}

// This does the main setup of string and image attributes with the current work and track.
// It is called when PlayerViewController is first created and upon resume from background.
- (void)configurePlayerForCurrentWork:(BOOL)shouldBeginPlaying {

    MPMediaItem *item = [player currentItem];    
    MPMediaItemCollection *collection = [player currentCollection];    
	DLog(@"configuring player for work: %@",[collection title]);
	
	//set the album art		
    artView.image = [collection artworkAtSize:CGSizeMake(300, 300)];
	
	//get the total time used for setting the upper slider
	totalWorkSeconds = [item duration];
	
	//set the work label and frame
	workTitleLabel.text = [collection title];	
	workTitleLabelWidth = [self calculateStringWidthForLabel:workTitleLabel];
	workTitleLabel.frame = CGRectMake(131, 102, workTitleLabelWidth, 29);
	
	//set the current track / total tracks and track title labels
	//(this will also trigger label animation)
	[self updateTrackAndTitleLabelsWithAnimation:YES];
	
	//set the current/elapsed playback times
	[self updateCurrentTime];
		
	//play the current track if not already playing	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if (shouldBeginPlaying && player.isPlaying == NO) {		
		[player beginPlaying];
	}	
        
	//since we have a prefs variable, set the default bookmarking style based on prefs
	if ([prefs integerForKey:@"isQuickBookmarkDefault"] == 1) {
		isQuickBookmarkDefault = YES;
	}
}

#pragma mark -
#pragma mark Timer lifecycle methods

- (void)labelTimerStart {
	currentTimeUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 
															  target:self 
															selector:@selector(updateCurrentTime) 
															userInfo:NULL 
															 repeats:YES];	
	[currentTimeUpdateTimer retain];
}

- (void)labelTimerStop {
	if (currentTimeUpdateTimer) {		
		[currentTimeUpdateTimer invalidate];
		[currentTimeUpdateTimer release];
		currentTimeUpdateTimer = NULL;
	}
}

#pragma mark -
#pragma mark Button Presses (tap-and-hold)

//Note: backward and forward buttons implement a system of both standard
//tap and tap-and-hold.  UIButton subclasses don't receive the touchesBegan
//messages so a subclass of UIButton doesn't work (tried it).
- (IBAction)backwardButtonTouchDown {
	[self performSelector:@selector(beginSeekingBackward) withObject:nil afterDelay:0.75];
}

- (void)backwardButtonTouchUp {
	[NSObject cancelPreviousPerformRequestsWithTarget:self 
											 selector:@selector(beginSeekingBackward) object:nil];
	
	if (inLongTap) {
		[player.playerController endSeeking];
	} else {		
		[player decrementTrack];	
	}	
	
	inLongTap = NO;
}

- (void)beginSeekingBackward {
	inLongTap = YES;
	[player.playerController beginSeekingBackward];
}

- (IBAction)forwardButtonTouchDown {
	[self performSelector:@selector(beginSeekingForward) withObject:nil afterDelay:0.75];
}

- (void)forwardButtonTouchUp {	
	[NSObject cancelPreviousPerformRequestsWithTarget:self 
											 selector:@selector(beginSeekingForward) object:nil];
	
	if (inLongTap) {
		[player.playerController endSeeking];
	} else {		
		[player incrementTrack];	
	}	
	
	inLongTap = NO;
}

- (void)beginSeekingForward {
	inLongTap = YES;
	[player.playerController beginSeekingForward];
}


#pragma mark -
#pragma mark ButtonPresses (standard)

- (void)togglePlayPause {
	[player togglePlayPause];
}

- (void)notesButtonWasPressed {    
	NotesViewController *nvc = [[NotesViewController alloc] initWithNibName:@"NotesViewController" bundle:nil];
    nvc.notes = player.currentCollection.notes;
	nvc.notesDelegate = self;  //see notesViewReturningWithNotes
	[self.navigationController pushViewController:nvc animated:YES];
	[nvc release];			
}

- (void)hudButtonWasPressed {	
	[self startHudMode];
}

- (void)moreButtonWasPressed {
	
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil 
										delegate:self 
							   cancelButtonTitle:@"Cancel" 
						  destructiveButtonTitle:nil 
							   otherButtonTitles:@"Jump to latest time",
			 @"Share",
			 @"Sleep Timer",
             @"Settings",			 							
			 nil];	
		
	[sheet setTag:0];
	[sheet showInView:self.view];
	[sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {	
    
    if (actionSheet.tag == 0) {
        if (buttonIndex == 3) {
            //settings button            
            SettingsViewController *viewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];	
            viewController.model = [DMUserDefaults sharedInstance];
            viewController.navigationItem.title = @"Info & Settings";
            [self.navigationController pushViewController:viewController animated:YES];
            [viewController release];
            
        } else if (buttonIndex == 2) {        
            [self startSleepMode];
            
        } else if (buttonIndex == 1) {
            //[self emailDetails];
            [self showShareMenu];
            
        } else if (buttonIndex == 0) {
            //jump to latest time
            [player jumpToMaxTime];        
        }	
    } else {
        if (buttonIndex == 0) { 
            NSString *msg = [NSString stringWithFormat:@"Listening to \"%@\"",player.currentCollection.title];
            float version = [[[UIDevice currentDevice] systemVersion] floatValue];
            if (version < 5.0) { 
                SHKItem *item = [SHKItem text:msg];
                if ([self reachable:@"twitter.com"]) {
                    [SHKTwitter shareItem:item];
                }
            } else {
                [self shareViaNativeTwitter:msg];
            }
        } else if (buttonIndex == 1) {
            SHKItem *item = [SHKItem text:[NSString stringWithFormat:@"I'm listening to %@",player.currentCollection.title]];
            if ([self reachable:@"facebook.com"]) {
                [SHKFacebook shareItem:item];
            }
        } else if (buttonIndex == 2) {
            [self email:NO];
        } 
    }
}

- (void)showShareMenu {    
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                       delegate:self 
                                              cancelButtonTitle:@"Cancel" 
                                         destructiveButtonTitle:nil 
                                              otherButtonTitles:@"Twitter",
                            @"Facebook",
                            @"Email",			 							
                            nil];	
    
	[sheet setTag:1];
	[sheet showInView:self.view];
	[sheet release];
}

- (void)shareViaNativeTwitter:(NSString *)text {
#ifdef __IPHONE_4_0 
    // Set up the built-in twitter composition view controller.
    TWTweetComposeViewController *tweetViewController = [[[TWTweetComposeViewController alloc] init] autorelease]; 
    
    // Set the initial tweet text. See the framework for additional properties that can be set.
    [tweetViewController setInitialText:text];
    
    // Create the completion handler block.
    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
            
        switch (result) {
            case TWTweetComposeViewControllerResultCancelled:
                // The cancel button was tapped.                
                break;
            case TWTweetComposeViewControllerResultDone:
                // The tweet was sent.
                break;
            default:
                break;
        }
        
        // Dismiss the tweet composition view controller.
        [self dismissModalViewControllerAnimated:YES];
    }];
    
    // Present the tweet composition view controller modally.
    [self presentModalViewController:tweetViewController animated:YES];   
#endif
}

#pragma mark -
#pragma mark HeadsUp, SleepMode, and AlbumArt methods

- (void)startHudMode {
	willReturnFromHudView = YES;		
	HeadsUpViewController *hud = [[HeadsUpViewController alloc] init];
	hud.player = player;
	hud.artView = artView;
    hud.showInstructions = YES;
    
    // Set a larger back button for easier navigation
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Back           " 
                                                                      style: UIBarButtonItemStyleBordered 
                                                                     target: nil 
                                                                     action: nil];    
    [[self navigationItem] setBackBarButtonItem: newBackButton];    
    [newBackButton release];
    
	[self.navigationController pushViewController:hud animated:NO];
	[hud release];
}

- (void)startSleepMode {
	if (![player isPlaying]) [player togglePlayPause];
	willReturnFromHudView = YES;
	SleepTimerViewController *stc = [[SleepTimerViewController alloc] initWithNibName:@"SleepTimerViewController" bundle:nil];
	stc.player = player;
	stc.artView = artView;
	[self.navigationController pushViewController:stc animated:NO];
	[stc release];
}

- (void)toggleAlbumArt {
	[UIView beginAnimations:@"album_art_resize" context:nil];
	[UIView setAnimationDuration:0.5];	
	
	if (artView.frame.size.width == 112) {
		[artView setFrame:CGRectMake(10, 54, 300, 300)];
	} else {
		[artView setFrame:CGRectMake(10, 54, 112, 112)];
	}
	[UIView commitAnimations];
}


#pragma mark  -
#pragma mark Bookmark methods

- (void)bookmarkButtonTouchDown {
	[self performSelector:@selector(performLongBookmarkTapAction) withObject:nil afterDelay:0.75];
}

- (void)bookmarkButtonTouchUp {
	[NSObject cancelPreviousPerformRequestsWithTarget:self 
											 selector:@selector(performLongBookmarkTapAction) object:nil];
	
	if (!inLongTap) {
		[self performShortBookmarkTapAction];
	} 	
	
	inLongTap = NO;
}

- (void)performShortBookmarkTapAction {
	(isQuickBookmarkDefault ? [self createQuickBookmark] : [self createStandardBookmark]);
}

- (void)performLongBookmarkTapAction {
	inLongTap = YES;
	(isQuickBookmarkDefault ? [self createStandardBookmark] : [self createQuickBookmark]);
}

- (void)createQuickBookmark {    
	[player chime];
	[Bookmark createBookmarkForStartTime:[player currentPlaybackTime] isQuickBookmark:YES];
	[self updateBookmarksButton];
}

//create a bookmark associated with a track
- (void)createStandardBookmark {	
	Bookmark *bookmark = [Bookmark createBookmarkForStartTime:[player currentPlaybackTime] isQuickBookmark:NO];	
	BookmarkViewController *bookmarkVC = [[BookmarkViewController alloc] initWithNibName:@"BookmarkViewController" bundle:nil];
    bookmarkVC.isNew = YES;
    bookmarkVC.bookmark = bookmark;
    [self.navigationController pushViewController:bookmarkVC animated:YES];
    [bookmarkVC release];
}

// Update bookmarks count on nav button
- (void)updateBookmarksButton {
	NSArray *bookmarks = [player.currentCollection bookmarks];
	forwardButton.title = [NSString stringWithFormat:@"Bookmarks (%d)", [bookmarks count]];	
}

- (void)showBookmarksView {	
	BookmarksViewController *bmvc = [[BookmarksViewController alloc] initWithNibName:@"BookmarksView" bundle:nil];	
	willReturnFromBookmarksView = YES; //will be used later by viewWillAppear
	[self.navigationController pushViewController:bmvc animated:YES];
	[bmvc release];	
}

#pragma mark BookmarkViewControllerDelegate

- (void)bookmarkViewShouldBeDismissed:(UIViewController *)bookmarkVC {	
	
	[UIView beginAnimations:@"dimiss_bookmark" context:bookmarkVC];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(afterBookmarkDismissal:finished:context:)];
	bookmarkVC.view.alpha = 0.0;
	[UIView commitAnimations];			 
	
}

- (void)afterBookmarkDismissal:(NSString *)animationID finished:(BOOL)finished context:(void *)context { 	
	BookmarkViewController *bookmarkVC = (BookmarkViewController *)context;
	[bookmarkVC.view removeFromSuperview];	
	[bookmarkVC release];
	bookmarkVC = nil;	
	
	[self updateBookmarksButton];
}


#pragma mark -
#pragma mark NotesView methods

- (void)notesViewReturningWithNotes:(NSString *)notes {
    player.currentCollection.notes = notes;	
}

#pragma mark -
#pragma mark Time tracking/updating

// Update time labels and slider. Do not request time info if
// player isn't active. This happens when the app is inactive (i.e., phone call, sync)
// or when backgrounded. If time requests are made of MPMusicPlayerController,
// its "server" can die.
- (void)updateCurrentTime {	
	if (player.isPlaying == YES) {
		timeElapsedLabel.text = [player currentPlaybackTimeString:NO];
        timeElapsedLabel.accessibilityLabel = [NSString stringWithFormat:@"Elapsed %@",[player currentPlaybackTimeString:YES]];
		timeRemainingLabel.text = [player currentRemainingTimeString:NO];
        timeRemainingLabel.accessibilityLabel = [NSString stringWithFormat:@"Remaining %@",[player currentRemainingTimeString:YES]];
		
		//update timer slider unless user is editing currently
		if (!userChangingTimeSlider) {
            long elapsed = player.currentPlaybackTime;			
            float done = (float) elapsed / (float) totalWorkSeconds;
            timeSlider.value = done;
        }
	}
}

- (void)updateTrackAndTitleLabelsWithAnimation:(BOOL)animation {	
    
	NSString *s = [[NSString alloc] initWithFormat:@"Track %i of %i", 
				   [player indexOfNowPlayingItem] + 1, 
				   [player totalItems]];	
	trackNumLabel.text = s;
	[s release];
	
	trackTitleLabel.text = [player.currentItem title];
	
	//calculate the touch label widths and set their widths
	trackTitleLabelWidth = [self calculateStringWidthForLabel:trackTitleLabel];	
	trackTitleLabel.frame = CGRectMake(131, 122, trackTitleLabelWidth, 29);
	
	//start (possible) animation of title labels after delay
	if (animation && !willAnimateLabels) {
		willAnimateLabels = YES;
		[self performSelector:@selector(labelWasTouched:) withObject:nil afterDelay:4];	
	}     
}

- (void)triggerUpdateMetadata {	
    DLog(@"triggerUpdateMetadata");
	[player.currentCollection saveState];	
}

#pragma mark -
#pragma mark Player state change notifications

- (void)playbackStateChanged:(NSNotification *)notification {	
	if (player.playerController.playbackState == MPMusicPlaybackStatePlaying) {
		[playPauseButton setImage:pauseImage forState:UIControlStateNormal];		
	} else if (player.playerController.playbackState == MPMusicPlaybackStatePaused) {
		[playPauseButton setImage:playImage forState:UIControlStateNormal];		
	} else if (player.playerController.playbackState == MPMusicPlaybackStateStopped) {
		[playPauseButton setImage:playImage forState:UIControlStateNormal];	
	}	
}

- (void)nowPlayingItemChanged:(NSNotification *)notification {
    DLog(@"nowPlayingItemChanged to %@",player.currentItem.title);
    
    if (player.currentItem == nil) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {        
        totalWorkSeconds = [[player currentItem] duration]; 
        [self updateTrackAndTitleLabelsWithAnimation:YES];		
    }
}

#pragma mark -
#pragma mark TimeRibbonDelegate methods

- (void)seekBackward {}
- (void)seekForward {}
- (void)jump:(long)seconds {
	[player click]; //click sound
	
	//invalidate and destroy timer if it exists, 
	//then create a timer for short pause
	if (jumpSecondsPauseTimer && [jumpSecondsPauseTimer isKindOfClass:[NSTimer class]] && [jumpSecondsPauseTimer isValid]) {
		[jumpSecondsPauseTimer invalidate];
		jumpSecondsPauseTimer = nil;
	}
	
	willJumpSeconds = seconds;
	jumpSecondsPauseTimer = [NSTimer scheduledTimerWithTimeInterval:0.75
															 target:self 
														   selector:@selector(jumpTimerHasFired) 
														   userInfo:nil 
															repeats:NO];
}
- (void)timeRibbonEnd {}

//jump:(long)seconds above creates a timer for a short pause before actually jumping to the next time.
//this is called after the timer is fired
- (void)jumpTimerHasFired {
	[player jumpPlaybackTime:willJumpSeconds];
	[jumpSecondsPauseTimer invalidate];
	jumpSecondsPauseTimer = nil;
	
	if (![player isPlaying]) [player togglePlayPause];	
}

- (IBAction)timeSliderTouchDown {
    userChangingTimeSlider = YES;    
}

- (IBAction)timeSliderTouchUp {
    userChangingTimeSlider = NO;
    long curPoint = timeSlider.value * totalWorkSeconds;
	player.currentPlaybackTime = curPoint;    
}

#pragma mark -
#pragma mark TouchImageViewDelegate methods

- (void)imageWasTouched {
	[self toggleAlbumArt];
}

- (void)swipeDetectedForMode:(DetectedSwipeMode)mode {
	if (mode == DetectedSwipeModeDown) {		
	}
}

#pragma mark -
#pragma mark TouchLabelDelegate methods

- (void)labelWasTouched:(UILabel *)label {
			
	//labels are 180px wide so shift if the string lenght(s) are > 180
	if (workTitleLabelWidth <= 180 && trackTitleLabelWidth <= 180) return;
			
	[UIView beginAnimations:@"slide_labels_left" context:nil];
	
	//The minimum animation duration is 3 seconds. 
	//For each 100px over 200px, add an additional second.	
	int greaterWidth = (workTitleLabelWidth > trackTitleLabelWidth ? workTitleLabelWidth : trackTitleLabelWidth);
	animationDuration = 3 + ((greaterWidth - 200) / 100);	
	
	[UIView setAnimationDuration:animationDuration];	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(labelSlideLeftHasFinished:finished:context:)];
	
	//note: shift will be > 180 to add some right-padding
	if (workTitleLabelWidth > 180) {
		[workTitleLabel setFrame:CGRectMake(127 - (workTitleLabelWidth - 190), 102, workTitleLabelWidth, 29)];
	}
	
	if (trackTitleLabelWidth > 180) {
		[trackTitleLabel setFrame:CGRectMake(127 - (trackTitleLabelWidth - 190), 122, trackTitleLabelWidth, 29)];
	}		
	
	[UIView commitAnimations];	
}

- (void)labelSlideLeftHasFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context { 
	[UIView beginAnimations:@"slide_labels_right" context:nil];
	[UIView setAnimationDuration:animationDuration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(labelSlideRightHasFinished:finished:context:)];
	[workTitleLabel setFrame:CGRectMake(131, 102, workTitleLabelWidth, 29)];
	[trackTitleLabel setFrame:CGRectMake(131, 122, trackTitleLabelWidth, 29)];	
	[UIView commitAnimations];
}

- (void)labelSlideRightHasFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
	willAnimateLabels = NO;
}

//For a given title or author, calculate the width of the string for
//the font that's used to set the label's width
- (int)calculateStringWidthForLabel:(UILabel *)label {
	NSString *str = label.text;
	UIFont *font = label.font;	
	CGSize size = [str sizeWithFont:font];	
	return size.width;
}

#pragma mark -
#pragma mark Shake methods

- (void)shakeWasDetected {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if ([prefs valueForKey:@"shakeAction"]) {
		int actionIdx = [prefs integerForKey:@"shakeAction"];
		if (actionIdx == 1) {
			//play/pause
			[self togglePlayPause];
		} else if (actionIdx == 2) {
			//back 15
			[self jump:-15.0];
		} else if (actionIdx == 3) {			
			//toggle heads'up
			if ([[self.navigationController topViewController] isKindOfClass:[SleepTimerViewController class]]) {
				//ignore request if in sleep timer (note: SleepTimer is kindOfClass HeadsUpViewController)
			} else if ([[self.navigationController topViewController] isKindOfClass:[HeadsUpViewController class]]) {
				[self.navigationController popViewControllerAnimated:YES];
			} else {
				[self startHudMode];
			}			
		} else if (actionIdx == 4) {
			//quick bookmark
            [self createQuickBookmark];
		}
	}	
}

#pragma mark MFMailComposeViewControllerDelegate Implementation

- (void)email:(BOOL)details { 
    // Note: not currently handling with/without details
    
	MFMailComposeViewController *composeVC = [[MFMailComposeViewController alloc] init];    
    composeVC.mailComposeDelegate = self;    
    
    NSMutableString *msgBody = [[[NSMutableString alloc] init] autorelease];
    [composeVC setSubject:[NSString stringWithFormat:@"Bookmarks and notes from %@",player.currentCollection.title]];    
    
    //create message body from Book & Bookmarks email strings
    [msgBody appendString:[player.currentCollection formatForEmail]];    
    
    [msgBody appendString:@"\nMade with Bookmark for iOS - http://bit.ly/4osi16"];
    [composeVC setMessageBody:msgBody isHTML:NO];	
    [self presentModalViewController:composeVC animated:YES];
    [composeVC release];		
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Reachability methods

-(BOOL)reachable:(NSString *)hostName {
    Reachability *r = [Reachability reachabilityWithHostName:hostName];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == NotReachable) {
        NSString *msg = [NSString stringWithFormat:@"We can't seem to reach %@. Please try again later.",hostName];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" 
                                                        message:msg
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return NO;
    }
    return YES;
}

#pragma mark - 
#pragma mark Cleanup

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];	
	DLog(@"player view memory warning");
}

@end
