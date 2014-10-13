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
//  TimeStalk.h
//  TestSlider
//
//  Created by Barry Ezell on 7/10/09.
//

#import <Foundation/Foundation.h>

typedef enum {
	TimeStalkLowered,
	TimeStalkPartiallyRaised,
	TimeStalkFullyRaised
} TimeStalkRaised;

typedef enum {
	TimeShiftTypeSeekFwd,
	TimeShiftTypeSeekBack,
	TimeShiftTypeJump,
	TimeShiftTypeNone
} TimeShiftType;


@interface TimeStalk : UIImageView {
	NSString *title;
	float x;
	float curX;
	float y;
	float curY;
	float width;
	float curWidth;
	float height;
	float curHeight;
	BOOL hasSetSizes;
	int seconds;
	int animationSequence;
	TimeShiftType shiftType;
}

@property (nonatomic) float x;
@property (nonatomic, retain) NSString *title;
@property (nonatomic) int seconds;
@property (nonatomic) TimeShiftType shiftType;

-(id)initWithTitle:(NSString *)t xPos:(float)startX timeShift:(TimeShiftType)shift seconds:(int)secs;
- (void)drawCenteredText:(NSString*)text 
			   atCenterX:(CGFloat)x
					andY:(CGFloat)y			 		   
			   usingFont:(UIFont *)font;

- (void)loadImage;
- (void)createImage;

@end
