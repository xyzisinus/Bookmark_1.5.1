//
//  BookmarkAppDelegate.m
//  Bookmark
//
//  Created by Barry Ezell on 1/13/10.
//  Copyright Dockmarket LLC 2010. All rights reserved.
//

#import "BookmarkAppDelegate.h"
#import "LibraryViewController.h"
#import "MasterMusicPlayer.h"
#import "CoreDataUtility.h"
#import "Flurry.h"
#import "ABNotifier.h"

//for memory calls 
#import <mach/mach.h>
#import <mach/mach_host.h>

@implementation BookmarkAppDelegate

@synthesize window, navigationController, isBackgroundingSupported, didEnterBackground;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
	[application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    // Start TestFlight
    //[TestFlight takeOff:@"34c35fbe6dba1fb14bbc9cd68a77fb2a_MTA3MDAyMDExLTExLTA0IDEwOjMwOjIxLjU2MTYzNA"];
        
    // Start Airbrake
    [ABNotifier startNotifierWithAPIKey:@"a3ea610653195063da492e56220bb3fd"
                        environmentName:ABNotifierAutomaticEnvironment
                                 useSSL:YES
                               delegate:nil];
        
    // Start Flurry
    [Flurry startSession:@"8CAFIEM1JJK1WZEIBY6I"];
            
    // Set defaults
    [[DMUserDefaults sharedInstance] initializeDefaults];
    	   
	//determine if backgrounding is supported
	UIDevice* device = [UIDevice currentDevice];
	isBackgroundingSupported = NO;
	if ([device respondsToSelector:@selector(isMultitaskingSupported)])
		isBackgroundingSupported = device.multitaskingSupported;
		
	//create the singleton instance of the MasterMusicPlayer now so it attaches to the main thread (otherwise
	//playback notifications don't work correctly)
	[MasterMusicPlayer instance];
    
    // Initialize the database
    [[CoreDataUtility sharedUtility] managedObjectContext];
    
    // Global UI settings    
    //[[UISlider appearance] setMinimumTrackTintColor:[UIColor colorWithRed:0.928 green:0.468 blue:0.000 alpha:1.000]];
		
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	
	return YES;
}

- (void)setDeviceAwakeState:(BOOL)awake {
	UIApplication* myApp = [UIApplication sharedApplication];
	myApp.idleTimerDisabled = awake;
}

- (void)saveOnExit {
	
	//set the current book as the last-played book unless we ended in LibraryViewController
	MasterMusicPlayer *mmp = [MasterMusicPlayer instance];
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	//record an "ended in player" flag unless user was in Library view
	if ([[navigationController topViewController] isKindOfClass:[LibraryViewController class]]) {
		[prefs setBool:NO forKey:@"endedInPlayer"];
	} else {
		[prefs setBool:YES forKey:@"endedInPlayer"];
	}
	
	[prefs synchronize];
	
	//If there is a current work, save its metatdata before exit
	if (mmp.currentItem != nil) {        	        
		[mmp.currentCollection saveState];
	}
	
    NSError *error = nil;
    NSManagedObjectContext *moc = [[CoreDataUtility sharedUtility] managedObjectContext];
    if (moc != nil) {
        if ([moc hasChanges] && ![moc save:&error]) {
			DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
	
	//clear the media item cache (because on iOS 4 with backgrounding, this could save memory)
	//[mmp clearMediaItemCache];
    
    [prefs synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	/**
	 save changes in the application's managed object context before the application terminates.
	 */
	[self saveOnExit];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	DLog(@"did become active");	
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	//[self saveOnExit];	
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	
	DLog(@"will enter foreground");
	
	/*
	[[MasterMusicPlayer instance] registerForNotifications];
	
	//User could have exited Bookmark and later changed tracks to a non-audiobook/podcast track
	//via the iPod.  Check to see if the track is supported.	
	MasterMusicPlayer *mmp = [MasterMusicPlayer instance];
	if ([mmp isPlaying]) {	
		if (![mmp attemptCurrentWorkAssignmentForPlayingItem]) {
			
			//end playback of nonsupported track
			[mmp togglePlayPause];
						
			//pop back to the LibraryViewController
			for (UIViewController *vc in navigationController.viewControllers) {
				if ([vc.nibName isEqualToString:@"LibraryViewController"]) {
					[navigationController popToViewController:vc animated:NO];
				}
			}
			
			return;  //don't want to evaluate code below
		}
	}	
	
	//If we popped back to LibraryViewController on didEnterBackground and set the "autoplay" pref,
	//will need to restore a PlayerViewController on top of the nav stack
	//Loop through all the VC's in the navigation controller stack and do the following:	
	[mmp attemptPlaybackOfLastPlayedItem];
	
	if ([mmp attemptPlaybackOfLastPlayedItem]) {
		PlayerViewController *playerVC = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
		[playerVC configurePlayerForCurrentWork:YES];
		[navigationController pushViewController:playerVC animated:NO];
	}*/	
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	DLog(@"app delegate memory warning");
	
	//release cached media items
	MasterMusicPlayer *mmp = [MasterMusicPlayer instance];
	[mmp clearMediaItemCache];
}

- (void)dealloc {
    
	[navigationController release];
	[window release];
		
	[super dealloc];
}


@end

