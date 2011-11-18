//
//  PlayerViewController.h
//  Bookmark
//
//  Created by Barry Ezell on 1/31/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "TimeRibbonView.h"
#import "MasterMusicPlayer.h"
#import "Work.h"
#import "BookmarkViewController.h"
#import "NotesViewController.h"
#import "TouchImageView.h"
#import "TouchLabel.h"

@interface PlayerViewController : UIViewController<UIActionSheetDelegate, TimeRibbonDelegate,
NotesViewDelegate, TouchImageViewDelegate, TouchLabelDelegate, MFMailComposeViewControllerDelegate> {
		
	int                         workTitleLabelWidth;
	int                         trackTitleLabelWidth;
	int                         animationDuration;
	
	UIImage                     *playImage;
	UIImage                     *pauseImage;	
	UIBarButtonItem             *forwardButton;	
	UIView                      *hudView;
	
	NSManagedObjectContext      *managedObjectContext;
	MasterMusicPlayer           *player;
	BOOL                        inHeadsUpMode;
    BOOL                        userChangingTimeSlider;
	BOOL                        hasSetupPlayer;
	BOOL                        needsCurrentTrackUpdate; //see nowPlayingItemChanged
	BOOL                        willReturnFromBookmarksView;  //see viewDidAppear
	BOOL                        willReturnFromHudView;
	BOOL                        willAnimateLabels;
	BOOL                        isQuickBookmarkDefault;
	BOOL                        inLongTap;
	long long                   totalWorkSeconds;
	NSTimer                     *currentTimeUpdateTimer;
	NSTimer                     *jumpSecondsPauseTimer; //there is an intentional slight pause before jumping to a new selected time	
	long                        willJumpSeconds; //the number of seconds last chosen via the time ribbon
}

@property (nonatomic, retain)   NSManagedObjectContext  *managedObjectContext;
@property (nonatomic, retain)   UIImage                 *playImage;
@property (nonatomic, retain)   UIImage                 *pauseImage;
@property (nonatomic, retain)   IBOutlet TouchLabel     *workTitleLabel;
@property (nonatomic, retain)   IBOutlet TouchLabel     *trackTitleLabel;
@property (nonatomic, retain)   IBOutlet UILabel        *timeElapsedLabel;
@property (nonatomic, retain)   IBOutlet UILabel        *timeRemainingLabel;	
@property (nonatomic, retain)   IBOutlet UILabel        *trackNumLabel;	
@property (nonatomic, retain)   IBOutlet UIToolbar      *toolbar;
@property (nonatomic, retain)   IBOutlet UISlider       *timeSlider;
@property (nonatomic, retain)   IBOutlet TouchImageView *artView;		
@property (nonatomic, retain)   IBOutlet UIButton       *playPauseButton;
@property (nonatomic, assign)   LibraryCategory         currentCategory;

- (IBAction)timeSliderTouchDown;
- (IBAction)timeSliderTouchUp;
- (IBAction)togglePlayPause;
- (IBAction)backwardButtonTouchUp;
- (IBAction)backwardButtonTouchDown;
- (IBAction)forwardButtonTouchUp;
- (IBAction)forwardButtonTouchDown;
- (IBAction)notesButtonWasPressed;
- (IBAction)hudButtonWasPressed;
- (IBAction)bookmarkButtonTouchUp;
- (IBAction)bookmarkButtonTouchDown;

- (void)performShortBookmarkTapAction;
- (void)performLongBookmarkTapAction;
- (void)createQuickBookmark;
- (void)createStandardBookmark;
- (void)moreButtonWasPressed;
- (void)afterBookmarkDismissal:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
- (void)configurePlayerForCurrentWork:(BOOL)shouldBeginPlaying;
- (void)labelTimerStart;
- (void)labelTimerStop;
- (void)updateCurrentTime;
- (void)playbackStateChanged:(NSNotification *)notification;
- (void)nowPlayingItemChanged:(NSNotification *)notification;
- (void)updateTrackAndTitleLabelsWithAnimation:(BOOL)animation;
- (void)updateBookmarksButton;
- (void)jumpTimerHasFired;
- (void)triggerUpdateMetadata;
- (void)showShareMenu;
- (void)shareViaNativeTwitter:(NSString *)text;
- (void)showBookmarksView;
- (void)startHudMode;
- (void)startSleepMode;
- (void)toggleAlbumArt;
- (void)email:(BOOL)details;
- (void)shakeWasDetected;
- (void)labelSlideLeftHasFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
- (void)labelSlideRightHasFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
- (int)calculateStringWidthForLabel:(UILabel *)label;
- (BOOL)reachable:(NSString *)hostName;

@end
