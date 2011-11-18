//
//  SleepTimerViewController.h
//  Bookmark
//
//  Created by Barry Ezell on 3/20/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeadsUpViewController.h"
#import "SSPieProgressView.h"

@interface SleepTimerViewController : HeadsUpViewController {
	float   initialVol;
    int     remainingSeconds;
    BOOL    isPlaying;
	
	//note: player defined in HUDViewController
}

@property (nonatomic, retain) NSTimer                       *timer;
@property (nonatomic, retain) IBOutlet UILabel              *timeLabel;
@property (nonatomic, retain) IBOutlet UIToolbar            *toolbar;
@property (nonatomic, assign) int                           totalSeconds;
@property (nonatomic, assign) int                           elapsedSeconds;

- (void)updateDisplay;
- (void)updateToolbar;
- (IBAction)playPauseButtonWasPressed:(id)sender;
- (IBAction)addTimeButtonWasPressed:(id)sender;
- (IBAction)timeSetButtonWasPressed:(id)sender;
- (void)rockingMotionDetected;
- (void)restoreVolume;

- (void)timerStop;
- (void)timerStart;
- (void)addSecondsToTimer:(int)seconds;
- (void)handleTimeRemaining:(int)seconds;

@end
