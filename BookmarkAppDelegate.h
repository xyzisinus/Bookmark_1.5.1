//
//  BookmarkAppDelegate.h
//  Bookmark
//
//  Created by Barry Ezell on 1/13/10.
//  Copyright Dockmarket LLC 2010. All rights reserved.
//
#import "EventForwardingWindow.h"

@interface BookmarkAppDelegate : NSObject <UIApplicationDelegate> {    	
    EventForwardingWindow *window;
    UINavigationController *navigationController;	
	BOOL isBackgroundingSupported;
	BOOL didEnterBackground;
}

@property (nonatomic, retain) IBOutlet EventForwardingWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, readonly) BOOL isBackgroundingSupported;
@property (nonatomic, assign) BOOL didEnterBackground;

- (void)setDeviceAwakeState:(BOOL)awake;
- (void)saveOnExit;

@end

