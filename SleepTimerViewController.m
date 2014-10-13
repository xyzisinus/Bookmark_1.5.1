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
//  SleepTimerViewController.m
//  Bookmark
//
//  Created by Barry Ezell on 3/20/10.
//

#import "SleepTimerViewController.h"
#import "MasterMusicPlayer.h"
#import "EventForwardingWindow.h"
#import "DMTimeUtils.h"
#import "SleepTimeEditViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation SleepTimerViewController

@synthesize timer, timeLabel, toolbar, totalSeconds, elapsedSeconds;

- (void)dealloc {
    [timer release]; timer = nil;
    [timeLabel release]; timeLabel = nil;      
    [toolbar release]; toolbar = nil;
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark_leather_2.png"]] autorelease];
    [self.view addSubview:imgView];
    [self.view sendSubviewToBack:imgView]; 
	
	albumFrame = CGRectMake(25, 65, 270, 270);
    
    timeLabel.textColor = SECONDARY_TEXT_COLOR;
    timeLabel.layer.shadowColor = [[UIColor blueColor] CGColor];
    timeLabel.layer.shadowOpacity = 0.5;
    timeLabel.layer.shadowRadius = 3.0;
    timeLabel.layer.shadowOffset = CGSizeMake(0, 3); 
    
    // Get time, dead man switch, and chime preferences
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	totalSeconds = [prefs integerForKey:SLEEP_TIMER_SEC];	
		
	// Possibly listen for rocking events and add +10 minutes on rock    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	if ([prefs boolForKey:SLEEP_TIMER_DEAD_MAN] == YES) {
		
		//first tell EventForwardingWindow to begin listening for rocks
		EventForwardingWindow *window = (EventForwardingWindow *) [[UIApplication sharedApplication] keyWindow];
		window.listeningForRocking = YES;
            
		[notificationCenter
		 addObserver: self
		 selector:    @selector (rockingMotionDetected)
		 name:        @"RockingEvent"
		 object:      nil];
	}	
    
    // Register for playback state changes on MMP    
	[notificationCenter
	 addObserver: self
	 selector:    @selector (playbackStateChanged:)
	 name:        @"PlaybackStateChanged"
	 object:      nil];
    
    isPlaying = [MasterMusicPlayer instance].isPlaying;
    [self updateToolbar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateDisplay];
    DLog(@"totalTime is %i",totalSeconds);
        
    if (player.isPlaying == YES) {
        [self timerStart];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];	
    
    //record the time for this session in prefs				
    if (totalSeconds > 0) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:totalSeconds forKey:SLEEP_TIMER_SEC];
        [prefs synchronize];
    }
    
    //stop the timer
    [self timerStop];			
	
	//unregister for rocks
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs boolForKey:SLEEP_TIMER_DEAD_MAN] == YES) {        
        EventForwardingWindow *window = (EventForwardingWindow *) [[UIApplication sharedApplication] keyWindow];
        window.listeningForRocking = NO;
                
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter removeObserver:self 
                                      name:@"RockingEvent" 
                                    object:nil];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;		
}

- (IBAction)playPauseButtonWasPressed:(id)sender {
    [player togglePlayPause];    
}

- (IBAction)addTimeButtonWasPressed:(id)sender {
    [self addSecondsToTimer:300];
}

- (IBAction)timeSetButtonWasPressed:(id)sender {
    SleepTimeEditViewController *stevc = [[SleepTimeEditViewController alloc] initWithNibName:@"SleepTimeEditViewController" 
                                                                                bundle:nil];
    [self.navigationController pushViewController:stevc 
                                         animated:YES];
    stevc.parentVC = self;
    stevc.totalSeconds = self.totalSeconds;
    [stevc populatePicker];
    [stevc release];
}

- (void)playbackStateChanged:(NSNotification *)notification {	
	if (player.playerController.playbackState == MPMusicPlaybackStatePlaying) {
        [self timerStart];
        isPlaying = YES;
	} else if (player.playerController.playbackState == MPMusicPlaybackStatePaused || player.playerController.playbackState == MPMusicPlaybackStateStopped) {
        [self timerStop];
        isPlaying = NO;
	}
    [self updateToolbar];
}

#pragma mark -
#pragma mark Timer methods

- (void)timerStart {	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                  target:self 
                                                selector:@selector(updateTimerProgress) 
                                                userInfo:nil 
                                                 repeats:YES];
}

- (void)timerStop {
	if (timer != nil) {		
		[timer invalidate];
		[timer release];
        timer = nil;
	}
}

- (void)addSecondsToTimer:(int)seconds {    
	totalSeconds += seconds;	
	[self updateDisplay];
	
	if (!timer) {
		[self timerStart];
	}
}

- (void)updateTimerProgress {	
	elapsedSeconds++;		
	[self updateDisplay];
	
	if (elapsedSeconds == totalSeconds) {        
		[self timerStop];		
        [self handleTimeRemaining:0];		
		
	} else if (remainingSeconds == 60) {        
        [self handleTimeRemaining:60];	        
	} else if (remainingSeconds < 10) {        
		[self handleTimeRemaining:remainingSeconds];       
	}
}

- (void)handleTimeRemaining:(int)seconds {
	if (seconds == 60) {
        [player bell];
	} else if (seconds == 0) {
		if ([player isPlaying]) {
            [player togglePlayPause];
            elapsedSeconds = 0;
            [self updateDisplay];
			[self performSelector:@selector(restoreVolume) 
					   withObject:nil 
					   afterDelay:1.0];            
        }
	} else if (seconds > 0 && seconds < 10) {
		if (seconds == 9) {
			//record starting volume
			initialVol = [player.playerController volume];
		}
		float vol = initialVol * (0.1 * seconds);
		[player.playerController setVolume:vol];
	} 
}

//this is called after delay because calling immediately after toggling play/pause can 
//cause the volume adjustment before playback is paused
- (void)restoreVolume {
	[player.playerController setVolume:initialVol];
}

- (void)updateDisplay {
    remainingSeconds = totalSeconds - elapsedSeconds;
    timeLabel.text = [DMTimeUtils formatSeconds:remainingSeconds];
    [timeLabel setAccessibilityLabel:[NSString stringWithFormat:@"%@ remaining",timeLabel.text]];
}

- (void)updateToolbar {
    UIBarButtonItem *addTimeItem = [[[UIBarButtonItem alloc] initWithTitle:@"+5" 
                                                                     style:UIBarButtonItemStylePlain 
                                                                    target:self
                                                                    action:@selector(addTimeButtonWasPressed:)] autorelease];
                                     
    UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                                target:nil 
                                                                                action:nil] autorelease];
    
    UIBarButtonSystemItem systemItem = (isPlaying ? UIBarButtonSystemItemPause : UIBarButtonSystemItemPlay);
    
    UIBarButtonItem *playPauseBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem 
                                                                                   target:self 
                                                                                   action:@selector(playPauseButtonWasPressed:)] autorelease];
    
    UIBarButtonItem *timeSetItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"78-stopwatch.png"] 
                                                                                         style:UIBarButtonItemStylePlain 
                                                                                        target:self 
                                                                                        action:@selector(timeSetButtonWasPressed:)] autorelease];
    [timeSetItem setAccessibilityLabel:@"Set Timer"];
    
    [toolbar setItems:[NSArray arrayWithObjects:addTimeItem, flexSpace, playPauseBtn, flexSpace, timeSetItem, nil] 
             animated:NO];        
}


#pragma mark -
#pragma mark Rocking motion methods

- (void)rockingMotionDetected {
	DLog(@"adding 10 minutes");	
	[self addSecondsToTimer:600];	
	[player chime];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
