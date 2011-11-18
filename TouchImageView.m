//
//  TouchImageView.m
//  AudiobooksPlus
//
//  Created by Barry Ezell on 7/23/09.
//  Copyright 2009 Dockmarket LLC. All rights reserved.
//

#import "TouchImageView.h"
#import <QuartzCore/QuartzCore.h>
#define MIN_SIGNIFICANT_MOVE 30.0

@implementation TouchImageView

@synthesize delegate;

/*
- (void)drawRect:(CGRect)rect {
    self.layer.shadowColor = [[UIColor blueColor] CGColor];
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowRadius = 5.0;
    self.layer.shadowOffset = CGSizeMake(0, 3); 
}
 */

#pragma mark -
#pragma mark Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { 
	startTouchPt = [[[touches allObjects] objectAtIndex:0] locationInView:[self superview]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

//testing for either a simple single touch or a swipe left, right, up, or down
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	CGPoint curTouchPt = [[[touches allObjects] objectAtIndex:0] locationInView:[self superview]];
	float xRise = curTouchPt.x - startTouchPt.x;
	float yRise = curTouchPt.y - startTouchPt.y;
	
	if (abs(xRise) >= MIN_SIGNIFICANT_MOVE || abs(yRise) >= MIN_SIGNIFICANT_MOVE) {
		//see if X or Y change is dominant and fire appropriate event
		if (abs(xRise) > abs(yRise)) {
			if (xRise > 0) {
				[self notifySwipeDetected:DetectedSwipeModeRight];
			} else {
				[self notifySwipeDetected:DetectedSwipeModeLeft];
			}
		} else {
			if (yRise > 0) {
				[self notifySwipeDetected:DetectedSwipeModeDown];
			} else {
				[self notifySwipeDetected:DetectedSwipeModeUp];
			}
		}			
	} else {
		//treat it as a single tap if applicable
		UITouch *touch = [touches anyObject]; 
		if(touch.tapCount == 1) {
			if (delegate) [delegate imageWasTouched];
		}
	}
}

- (void)notifySwipeDetected:(DetectedSwipeMode)mode {
	if (delegate && [delegate respondsToSelector:@selector(swipeDetectedForMode:)]) {
		[delegate swipeDetectedForMode:mode];
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
