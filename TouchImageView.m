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
//  TouchImageView.m
//  AudiobooksPlus
//
//  Created by Barry Ezell on 7/23/09.
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
