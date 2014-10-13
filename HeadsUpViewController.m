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
//  HeadsUpController.m
//  Bookmark
//
//  Created by Barry Ezell on 11/1/09.
//

#import "HeadsUpViewController.h"
#import "BookmarkAppDelegate.h"

@implementation HeadsUpViewController

@synthesize player, artView, instLabel, showInstructions;

- (void)dealloc {
	[player release];
	[artView release];
    [instLabel release];
	[super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	albumFrame = CGRectMake(20, 70, 280, 280);
    
    UIImageView *imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark_leather_2.png"]] autorelease];
    [self.view addSubview:imgView];
    [self.view sendSubviewToBack:imgView]; 
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	//keep awake if true in settings
	if ([prefs boolForKey:@"keepAwakeInHUD"]) {
		BookmarkAppDelegate *delegate = (BookmarkAppDelegate *) [[UIApplication sharedApplication] delegate];
		[delegate setDeviceAwakeState:YES];
		keepingAwake = YES;
	}
		
	//remove now because of bug that I wasn't able to repair that occurs when...
	//1. HUD displayed
	//2. Hit back until in LibraryViewController
	//3. Hit Current or choose another book
	//4. PlayerViewController checks "endedInHUD" pref and re-launches HUD
	//but it goes bad in that the HUD goes through viewDidLoad but the actual view doesn't show, but 
	//the navigationItem changes.  Hitting the back button moves the navigationItems correctly, but the 
	//view doesn't change (the PlayerViewController stays up)	
	if ([prefs valueForKey:@"endedInHUD"]) [prefs removeObjectForKey:@"endedInHUD"];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[artView setFrame:albumFrame];
	[self.view addSubview:artView];
	artView.delegate = self;
	
	//for shake events (PlayerViewController still handles them)
	[artView becomeFirstResponder]; 
    
	//show instructions for 30 seconds
    if (showInstructions == YES) {
        instLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 390, 280, 44)];
        instLabel.backgroundColor = [UIColor clearColor];
        instLabel.textColor = [UIColor whiteColor];
        instLabel.numberOfLines = 2;
        instLabel.textAlignment = UITextAlignmentCenter;
        instLabel.font = [UIFont fontWithName:@"Trebuchet MS" size:14];
        instLabel.text = @"Swipe Up or Down to Play/Pause\nSwipe Left or Right to jump 15 sec.";
        [self.view addSubview:instLabel];
        [self performSelector:@selector(hideInstructions) withObject:nil afterDelay:30];
        [instLabel release];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (keepingAwake) {
		BookmarkAppDelegate *delegate = (BookmarkAppDelegate *) [[UIApplication sharedApplication] delegate];
		[delegate setDeviceAwakeState:NO];
	}
}

- (void)hideInstructions {
	[UIView beginAnimations:@"hide_inst" context:nil];
	[UIView setAnimationDuration:4];
	[instLabel setAlpha:0.0];
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark TouchImageViewDelegate methods

- (void)imageWasTouched {
	//ignore single touch
}

- (void)swipeDetectedForMode:(DetectedSwipeMode)mode {
	if (mode == DetectedSwipeModeLeft) {
		[self animateAlbumArtInX:-15 andY:0];
		[player jumpPlaybackTime:-15];
		[player performSelector:@selector(click) withObject:nil afterDelay:0.1];		
	} else if (mode == DetectedSwipeModeRight) {
		[self animateAlbumArtInX:15 andY:0];
		[player jumpPlaybackTime:15];	
		[player performSelector:@selector(click) withObject:nil afterDelay:0.1];		
	} else if (mode == DetectedSwipeModeUp) {
		[self animateAlbumArtInX:0 andY:-15];
		[player performSelector:@selector(togglePlayPause) withObject:nil afterDelay:0.1];			
	} else if (mode == DetectedSwipeModeDown) {
		[self animateAlbumArtInX:0 andY:15];
		[player performSelector:@selector(togglePlayPause) withObject:nil afterDelay:0.1];		
	}
}

- (void)animateAlbumArtInX:(int)xMod andY:(int)yMod {
	[UIView beginAnimations:@"album_swipe" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.1];
	[UIView setAnimationDidStopSelector:@selector(moveHasFinished:finished:context:)];
	[artView setCenter:CGPointMake(artView.center.x + xMod, artView.center.y + yMod)];
	//[artView setFrame:CGRectMake(x,y,albumFrame.size.width,albumFrame.size.height)];
	[UIView commitAnimations];
}

- (void)moveHasFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context { 
	//reverse more slowly
	[UIView beginAnimations:@"album_swipe_return" context:nil];
	[UIView setAnimationDuration:0.15];
	[artView setFrame:albumFrame];
	[UIView commitAnimations];	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	
}


@end
