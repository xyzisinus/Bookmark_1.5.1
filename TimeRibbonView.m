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
//  TimeRibbonView.m
//  TestSlider
//
//  Created by Barry Ezell on 7/8/09.
//

#import "TimeRibbonView.h"
#import "TimeRibbonSetting.h"

#define SLIDER_X 88
#define SLIDER_Y 0
#define BTN_WIDTH 144
#define BTN_HEIGHT 59
#define STALK_SPACING 27.27
#define STALK_LOWER 29
#define STALK_RAISED 16
#define STALK_VIEW_LOWER -10	
#define STALK_VIEW_RAISED -40
#define STALK_HEIGHT_SM 35
#define STALK_WIDTH_SM 35
#define STALK_WIDTH_LG 50
#define STALK_HEIGHT_LG 50

@implementation TimeRibbonView

@synthesize delegate;

- (void)dealloc {		
	[stalks removeAllObjects];
	[stalks release];
	stalks = nil;
	
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		UIImage *ribbon = [UIImage imageNamed:@"ruler.png"];
		UIImageView *bkgrnd = [[UIImageView alloc] initWithImage:ribbon];		
		[self addSubview:bkgrnd];
		[bkgrnd release];
		
		UIImage *square = [UIImage imageNamed:@"slider.png"];
		sliderView = [[UIImageView alloc] initWithFrame:CGRectMake(SLIDER_X, SLIDER_Y, BTN_WIDTH, BTN_HEIGHT)];
		sliderView.image = square;
		sliderView.isAccessibilityElement = YES;
		sliderView.accessibilityLabel = @"Time Ribbon slider";
		sliderView.accessibilityTraits = UIAccessibilityTraitNone;
		[self addSubview:sliderView];
		[sliderView release];
				
		//create layer for all number stalks
		//starts too low to view
		stalkView = [[UIView alloc] initWithFrame:CGRectMake(0, STALK_VIEW_LOWER, 320, 50)];
		stalkView.alpha = 0.0;
		[self insertSubview:stalkView belowSubview:bkgrnd];		 
		[stalkView release];
		
		//get the array of TimeRibbonSetting objects from user defaults
		NSArray *trSettings = [TimeRibbonSetting settings];		
		TimeRibbonSetting *trs0 = [trSettings objectAtIndex:0];	
		TimeRibbonSetting *trs1 = [trSettings objectAtIndex:1];
		TimeRibbonSetting *trs2 = [trSettings objectAtIndex:2];
		TimeRibbonSetting *trs3 = [trSettings objectAtIndex:3];
		TimeRibbonSetting *trs4 = [trSettings objectAtIndex:4];
		
		//create array of TimeStalk objects
		//Note we keep a border of 10 pixels at either end so users have less difficulty
		//reaching the far left and far right items.  So spacing is calculated as 300 / # of stalks. 
		stalks = [NSMutableArray arrayWithCapacity:11];				
		[stalks addObject:[[[TimeStalk alloc] initWithTitle:[trs4 description:NO]
														  xPos:(STALK_SPACING * 0)
													 timeShift:TimeShiftTypeJump
													   seconds:[trs4 seconds:NO]] autorelease]];
		
		[stalks addObject:[[[TimeStalk alloc] initWithTitle:[trs3 description:NO]
														  xPos:(STALK_SPACING * 1)
													 timeShift:TimeShiftTypeJump
													   seconds:[trs3 seconds:NO]] autorelease]];
		
		[stalks addObject:[[[TimeStalk alloc] initWithTitle:[trs2 description:NO] 
														  xPos:(STALK_SPACING * 2)
													 timeShift:TimeShiftTypeJump
													   seconds:[trs2 seconds:NO]] autorelease]];
		
		[stalks addObject:[[[TimeStalk alloc] initWithTitle:[trs1 description:NO] 
														  xPos:(STALK_SPACING * 3)
													 timeShift:TimeShiftTypeJump
													   seconds:[trs1 seconds:NO]] autorelease]];
		
		[stalks addObject:[[[TimeStalk alloc] initWithTitle:[trs0 description:NO]
														  xPos:(STALK_SPACING * 4)
													 timeShift:TimeShiftTypeJump
													   seconds:[trs0 seconds:NO]] autorelease]];
		
		[stalks addObject:[[[TimeStalk alloc] initWithTitle:@"" 
														  xPos:(STALK_SPACING * 5)
													 timeShift:TimeShiftTypeNone
													   seconds:0] autorelease]];
		
		[stalks addObject:[[[TimeStalk alloc] initWithTitle:[trs0 description:YES] 
														  xPos:(STALK_SPACING * 6)
													 timeShift:TimeShiftTypeJump
													   seconds:[trs0 seconds:YES]] autorelease]];
		
		[stalks addObject:[[[TimeStalk alloc] initWithTitle:[trs1 description:YES] 
														  xPos:(STALK_SPACING * 7)
													 timeShift:TimeShiftTypeJump
													   seconds:[trs1 seconds:YES]] autorelease]];
		
		[stalks addObject:[[[TimeStalk alloc] initWithTitle:[trs2 description:YES]
														  xPos:(STALK_SPACING * 8)
													 timeShift:TimeShiftTypeJump
													   seconds:[trs2 seconds:YES]] autorelease]];
		
		[stalks addObject:[[[TimeStalk alloc] initWithTitle:[trs3 description:YES] 
														  xPos:(STALK_SPACING * 9)
													 timeShift:TimeShiftTypeJump
													   seconds:[trs3 seconds:YES]] autorelease]];
		
		[stalks addObject:[[[TimeStalk alloc] initWithTitle:[trs4 description:YES]
														  xPos:(STALK_SPACING * 10)
													 timeShift:TimeShiftTypeJump
													   seconds:[trs4 seconds:YES]] autorelease]];			
		[stalks retain];
			
		//Draw timestalks:
		//setting frame initially at the largest size so text font looks correct (when drawn smaller, looks pixelated when sized larger later)
		for(TimeStalk *stalk in stalks) {			
			stalk.frame = CGRectMake(stalk.x, STALK_LOWER, STALK_WIDTH_LG, STALK_HEIGHT_LG);
			[stalkView addSubview:stalk];				
			
			//stalk will load number image from disk or create/save/load if it doesn't exist
			[stalk loadImage];
			
			//now redraw smaller
			stalk.frame = CGRectMake(stalk.x, STALK_LOWER, STALK_WIDTH_SM, STALK_HEIGHT_SM);
		}	
		 
	}
    return self;
}


//set inButtonMove flag to true if touch intsersects with button	
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	CGPoint touched = [touch locationInView:self];
	if (CGRectContainsPoint(sliderView.frame,touched)) {		
		inButtonMove = YES;
				
		//create a buttonFingerOffset which defines the difference between the x of the
		//button and the actual touch.  This will prevent a "jump" effect where the button
		//abruptly recenters itself under the touch when touchesMoved is first called
		buttonFingerOffset = touched.x - sliderView.frame.origin.x;
		
		//raise number stalk layer
		[self raiseStalkLayer];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!inButtonMove) return;
	
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	CGPoint touched = [touch locationInView:self];
	
	//keep the button without a reasonable visual bounds
	if (touched.x < 16 || touched.x > 300) return;
		
	[sliderView setFrame:CGRectMake(touched.x - buttonFingerOffset, SLIDER_Y, BTN_WIDTH, BTN_HEIGHT)];	
	
	//determine whether we're under a stalk and raise if so
	//(measure from center of button, not touch)
	for(TimeStalk *stalk in stalks) {
		int btnCenter = sliderView.center.x;
		if (btnCenter >= stalk.x + 8 && btnCenter <= stalk.x + 18) {
			
			//canceling if this stalk is already selected
			if (raisedStalk && raisedStalk == stalk) {
				break;
			}
			
			//lower existing raised stalk if present
			if (raisedStalk) {
				if (raisedStalk == stalk) return;
				[self lowerSingleStalk:raisedStalk];
			}				
			
			//notify delegate of change
			if (stalk.shiftType == TimeShiftTypeJump) {
				[self.delegate jump:stalk.seconds];
			} else if (stalk.shiftType == TimeShiftTypeNone) {
				//nothing currently				
			} else if (stalk.shiftType == TimeShiftTypeSeekBack) {
				[self.delegate seekBackward];
			} else {
				[self.delegate seekForward];
			}
			
			[self raiseSingleStalk:stalk];
			break;
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	inButtonMove = NO;
	[self endSelection];
	[self.delegate timeRibbonEnd];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	inButtonMove = NO;
	[self endSelection];
	[self.delegate timeRibbonEnd];
}

//perform animations of button and stalks
-(void)endSelection {
	[self animateButtonReturn];
	[self lowerStalkLayer];
}

-(void)animateButtonReturn {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1];	
	[UIView setAnimationDelegate:self];
	//[UIView setAnimationDidStopSelector:@selector(feastHasFinished:finished:context:)];
	
	//setting end state of animation
	[sliderView setFrame:CGRectMake(SLIDER_X, SLIDER_Y, BTN_WIDTH, BTN_HEIGHT)];	
	[UIView commitAnimations];	
}

-(void)raiseStalkLayer {
	[UIView beginAnimations:@"raise_all" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	//[UIView setAnimationDidStopSelector:@selector(feastHasFinished:finished:context:)];
	stalkView.alpha = 1.0;
	stalkView.frame = CGRectMake(0, STALK_VIEW_RAISED, 320, 50);
	[UIView commitAnimations];
}

-(void)lowerStalkLayer {
	[UIView beginAnimations:@"lower_all" context:nil];
	if (raisedStalk) {
		[self lowerSingleStalk:raisedStalk];
	}
	
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	//[UIView setAnimationDidStopSelector:@selector(feastHasFinished:finished:context:)];
	stalkView.alpha = 0.0;
	stalkView.frame = CGRectMake(0, STALK_VIEW_LOWER, 320, 50);
	[UIView commitAnimations];
}

-(void)raiseSingleStalk:(TimeStalk *)ts {		
	[UIView beginAnimations:@"raise_one" context:nil];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationDelegate:self];	
	UIImageView *bStalk = ts;
	[bStalk setFrame:CGRectMake(ts.x - ((STALK_WIDTH_LG - STALK_WIDTH_SM) / 2), STALK_RAISED, STALK_WIDTH_LG, STALK_HEIGHT_LG)];
	[UIView commitAnimations];
	
	raisedStalk = ts;	
}


-(void)lowerSingleStalk:(TimeStalk *)ts {			
	[UIView beginAnimations:@"lower_one" context:nil];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationDelegate:self];	
	UIImageView *aStalk = raisedStalk;
	[aStalk setFrame:CGRectMake(ts.x, STALK_LOWER, STALK_WIDTH_SM, STALK_WIDTH_SM)];
	[UIView commitAnimations];
	
	raisedStalk = nil;	
}

-(void)seekForward {
	
}

-(void)seekBackward {
	
}


@end
