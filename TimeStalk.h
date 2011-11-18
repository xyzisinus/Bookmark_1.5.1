//
//  TimeStalk.h
//  TestSlider
//
//  Created by Barry Ezell on 7/10/09.
//  Copyright 2009 Dockmarket LLC. All rights reserved.
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
