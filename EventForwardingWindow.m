//
//  EventForwardingWindow.m
//  Bookmark
//
//  Created by Barry Ezell on 6/19/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
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
