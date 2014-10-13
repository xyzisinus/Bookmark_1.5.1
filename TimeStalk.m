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
//  TimeStalk.m
//  TestSlider
//
//  Created by Barry Ezell on 7/10/09.
//

#import "TimeStalk.h"

#define X_SHIFT 0.52
#define Y_SHIFT 0.8

@implementation TimeStalk

@synthesize x, shiftType, seconds, title;

- (void)dealloc {
	[title release];
    [super dealloc];
}

-(id)initWithTitle:(NSString *)t xPos:(float)startX timeShift:(TimeShiftType)shift seconds:(int)secs {
	if (self = [super init]) {	
		title = t;
		[title retain];
		
		self.x = startX;
		self.shiftType = shift;
		self.seconds = secs;
		animationSequence = 0;
		self.backgroundColor = [UIColor clearColor];	
	}
	
	return self;
}

//this needs to occur after init else graphics context will be invalid
- (void)loadImage {	
	//load self with image if file exists for this title, else create it
	NSString *tmpImgPath = [NSString stringWithFormat:@"%@/stalk_%@.png",NSTemporaryDirectory(),title];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:tmpImgPath];
	
	UIImage *img = nil;
	if (!fileExists) {			
		[self createImage];				
	}
	
	img = [UIImage imageWithContentsOfFile:tmpImgPath];
	self.image = img;	
}

- (void)createImage {	

	//create graphics context and get content for use when making CG calls
	UIGraphicsBeginImageContext(CGSizeMake(self.frame.size.width, self.frame.size.height)); 
	CGContextRef cg = UIGraphicsGetCurrentContext();
	
	//create image in color cosmic latte 255, 248, 231
	UIColor *color = [UIColor colorWithRed:1.0 green:0.973 blue:0.906 alpha:1.0];
	[color set];
	
	int halfX = self.frame.size.width / 2;
	int stalkY = self.frame.size.height * 0.37;
	
	//draw "stalk" line
	if (seconds != 0) {
		const CGFloat *components = CGColorGetComponents(color.CGColor);
		CGContextSetRGBStrokeColor(cg, components[0], components[1], components[2], 1); 	
		CGContextMoveToPoint(cg, halfX, stalkY);	
		CGContextAddLineToPoint(cg, halfX, 50);	
		CGContextStrokePath(cg);
	}
	
	UIFont *font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:14];	
	[self drawCenteredText:title atCenterX:halfX andY:0 usingFont:font];
	
	//get image object and save to disk
	UIImage *imageObj = UIGraphicsGetImageFromCurrentImageContext();
	NSString *tmpImgPath = [NSString stringWithFormat:@"%@/stalk_%@.png",NSTemporaryDirectory(),title];	
	NSData *imgData = UIImagePNGRepresentation(imageObj);	
	[imgData writeToFile:tmpImgPath atomically:NO];	
	UIGraphicsEndImageContext();	
}

//this reference for UIKit additions to NSString is very useful: 
//http://developer.apple.com/iphone/library/documentation/UIKit/Reference/NSString_UIKit_Additions/Reference/Reference.html
- (void)drawCenteredText:(NSString*)text 
			   atCenterX:(CGFloat)_x
					andY:(CGFloat)_y			 		   
			   usingFont:(UIFont *)font {
	
	CGSize size = [text sizeWithFont:font];
	CGPoint point = CGPointMake(_x - (size.width/2), _y);   
	[text drawAtPoint:point withFont:font];	
}		  

@end
