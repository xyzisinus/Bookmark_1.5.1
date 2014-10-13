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
//  EventForwardingWindow.m
//  Bookmark
//
//  Created by Barry Ezell on 6/19/10.
//

#import "EventForwardingWindow.h"
#import "MasterMusicPlayer.h"

@implementation EventForwardingWindow

@synthesize lastAcceleration, listeningForRocking;

- (void)makeKeyAndVisible {
	[super makeKeyAndVisible];
 #ifdef __IPHONE_4_0  
	UIDevice* device = [UIDevice currentDevice];	
	if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {
		[[UIApplication sharedApplication] beginReceivingRemoteControlEvents]; 
	}		
 #endif
	
	[self becomeFirstResponder];
	
	//register self to receive shake and rocking events via the accelerometer	
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval: 0.3];		
	[[UIAccelerometer sharedAccelerometer] setDelegate: self]; 
	listeningForRocking = NO;
} 

- (BOOL)canBecomeFirstResponder {
	return YES;
}

#pragma mark -
#pragma mark Shake/Rocking events

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	[super motionEnded:motion withEvent:event];
	if (motion == UIEventSubtypeMotionShake) {		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ShakeEvent" object:nil];
	}
}

// Ensures the shake is strong enough on at least two axes before declaring it a shake.
// "Strong enough" means "greater than a client-supplied threshold" in G's.
static BOOL L0AccelerationIsShaking(UIAcceleration* last, UIAcceleration* current, double threshold) {
	double
	deltaX = fabs(last.x - current.x),
	deltaY = fabs(last.y - current.y),
	deltaZ = fabs(last.z - current.z);
	
	return
	(deltaX > threshold && deltaY > threshold) ||
	(deltaX > threshold && deltaZ > threshold) ||
	(deltaY > threshold && deltaZ > threshold);
}

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	
	if (!listeningForRocking) return;
	
	if (self.lastAcceleration) {
		if (!histeresisExcited && L0AccelerationIsShaking(self.lastAcceleration, acceleration, 0.35)) {
			histeresisExcited = YES;
			
			/* ROCKING DETECTED */			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"RockingEvent" object:nil];
			
		} else if (histeresisExcited && !L0AccelerationIsShaking(self.lastAcceleration, acceleration, 0.2)) {
			histeresisExcited = NO;
		}
	}
	
	self.lastAcceleration = acceleration;
}


///////////////////////////////////////////////////////////////////////////////
#ifdef __IPHONE_4_0

- (void)remoteControlReceivedWithEvent:(UIEvent *)theEvent
{
	if (theEvent.type == UIEventTypeRemoteControl)
	{
		//NSLog(@"remoteControlEvent");
		switch(theEvent.subtype)
		{
			case UIEventSubtypeRemoteControlPlay:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"TogglePlayPause" object:nil];
				break;
			case UIEventSubtypeRemoteControlPause:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"TogglePlayPause" object:nil];
				break;
			case UIEventSubtypeRemoteControlStop:
				break;
			case UIEventSubtypeRemoteControlTogglePlayPause:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"TogglePlayPause" object:nil];
				break;
			case UIEventSubtypeRemoteControlNextTrack:
				break;
			case UIEventSubtypeRemoteControlPreviousTrack:
				break;
			default:
				return;
		}
	}
}

#endif

@end
