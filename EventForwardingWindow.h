//
//  EventForwardingWindow.h
//  Bookmark
//
//  Created by Barry Ezell on 6/19/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EventForwardingWindow : UIWindow <UIAccelerometerDelegate> {
	
	//needed for rocking motion detection
	//see http://stackoverflow.com/questions/150446/how-do-i-detect-when-someone-shakes-an-iphone
	BOOL histeresisExcited;
	UIAcceleration* lastAcceleration;
	BOOL listeningForRocking;
}

@property(retain) UIAcceleration* lastAcceleration;
@property(nonatomic, assign) BOOL listeningForRocking;

@end
