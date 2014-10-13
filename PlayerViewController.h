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
//  PlayerViewController.h
//  Bookmark
//
//  Created by Barry Ezell on 1/31/10.
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
