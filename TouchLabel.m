//
//  TouchLabel.m
//  Bookmark
//
//  Created by Barry Ezell on 8/2/09.
//  Copyright 2009 Dockmarket LLC. All rights reserved.
//

#import "TouchLabel.h"


@implementation TouchLabel

@synthesize labelDelegate;


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { 
	if (labelDelegate) {
		[labelDelegate labelWasTouched:self];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)dealloc {
	[super dealloc];
}

@end
