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
//  SleepTimerViewController.h
//  Bookmark
//
//  Created by Barry Ezell on 3/20/10.
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
