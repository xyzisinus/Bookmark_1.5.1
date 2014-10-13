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
//  MasterMusicPlayer.m
//  Bookmark
//
//  Created by Barry Ezell on 10/20/09.
//

#import <AudioToolbox/AudioToolbox.h>
#import "MasterMusicPlayer.h"
#import "CoreDataUtility.h"
#import "DMTimeUtils.h"

@implementation MasterMusicPlayer

static MasterMusicPlayer *_instance;

@synthesize playerController, currentCollection, currentItem;
@synthesize bellPlayer, clickPlayer, chimePlayer;
@synthesize lastPlayedItem;
@synthesize mediaItemsDict;
@synthesize isIPad;

- (void)dealloc {		
	[self unregisterForNotifications];
	[playerController release];
    [currentCollection release];
	[bellPlayer release];
    [clickPlayer release];
    [chimePlayer release];
	[mediaItemsDict release];
    [currentItem release];
    [lastPlayedItem release];
	[super dealloc];
}

+ (MasterMusicPlayer *)instance {
	@synchronized(self) {
		if (_instance == NULL) {
			_instance = [[self alloc] init];
		}
	}    
	return _instance;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

//release instance for memory mgmt purposes
+ (void)clearInstance {
	if (_instance) [_instance release];
}

- (id)init {
    self = [super init];
	if (self != nil) {
		
		// Setup the audio behaviors we want.	
		// Using ambient instead of playback because playback "ducks" volume on startup
		AVAudioSession *session = [AVAudioSession sharedInstance];
		[session setDelegate:self];
		NSError *setCategoryError = nil;				
		[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient 
                                               error: &setCategoryError];
        
		// Make sure ringer switch turned off doesn't mute playback 
		UInt32 doSetProperty = true;
        OSStatus propertySetError = 0;
		propertySetError = AudioSessionSetProperty (
                                                    kAudioSessionProperty_OverrideCategoryMixWithOthers,
                                                    sizeof (doSetProperty),
                                                    &doSetProperty
                                                    );
        if (propertySetError != 0) {
            DLog(@"Error setting OverrideCategoryMixWithOthers on session");
        }             
        
        NSError *setActiveError = nil;
		[session setActive:YES error:&setActiveError];
        
        if (setActiveError != nil) {
            DLog(@"Error configuring audio session: %@",[setActiveError localizedDescription]);
        }
        
        // Get reference to MPMediaPlayerController
        self.playerController = [MPMusicPlayerController iPodMusicPlayer];
		
		// Add a gentle bell sound used for 1-minute warning in Sleep Timer.
		NSString *bellFilePath = [[NSBundle mainBundle] pathForResource:@"longbell_01a" ofType:@"wav"];
		NSURL *bellUrl = [[NSURL alloc] initFileURLWithPath:bellFilePath];
		self.bellPlayer  = [[[AVAudioPlayer alloc] initWithContentsOfURL:bellUrl error:nil] autorelease];
		[bellUrl release];
		[bellPlayer prepareToPlay];
        
        // Add the click sound
        NSString *clickFilePath = [[NSBundle mainBundle] pathForResource:@"click_09" ofType:@"caf"];
		NSURL *clickUrl = [[NSURL alloc] initFileURLWithPath:clickFilePath];
		self.clickPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:clickUrl error:nil] autorelease];
		[clickUrl release];
		[clickPlayer prepareToPlay];		
        
        // Add the chime sound (used in SleepTimerVC and quick bookmarking)		
		NSString *chimeFilePath = [[NSBundle mainBundle] pathForResource:@"Sound_18" ofType:@"caf"];
		NSURL *chimeUrl = [[NSURL alloc] initFileURLWithPath:chimeFilePath];
		self.chimePlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:chimeUrl error:nil] autorelease];
		[chimeUrl release];
		[chimePlayer prepareToPlay];			
        
        // Set volumes and buzz prefs
        [self setPlayerVolumes];
        
		// Create a dictionary for temporarily storing mediaitems (we go this b/c tracks are quickly faulted
		// by CoreData and would have to otherwise request MediaItems from MPMusicPlayer frequently)
		self.mediaItemsDict = [[[NSMutableDictionary alloc] init] autorelease];
        
		// Turn OFF repeating and shuffle
		[self.playerController setRepeatMode:MPMusicRepeatModeNone];
		[self.playerController setShuffleMode:MPMusicShuffleModeOff];
        
		// Set this to zero. Will be set when bookmarks are selected
		forcePlaybackTime = 0;	
        
        // Ignore any item pre-set on MPMusicPlayerController unless playing
        // because nowPlayingItemChanged WILL be triggered after subscribing to notifications (below)
        if (playerController.nowPlayingItem != nil && playerController.playbackState != MPMusicPlaybackStatePlaying) {
            ignoreNowPlayingItemChange = YES;
        }
        
        // Determine if this is an iPad because of a bug that requires special handling in setCollectionForPlayback
        NSString *device = [[UIDevice currentDevice] platformString];
        if ([device rangeOfString:@"iPad"].length > 0) {
            isIPad = YES;
            isFirstPlayback = YES;
        }
		
		// Register for playback change notifications        
		[self registerForNotifications];
        
	}
	return self;
}

- (NSObject *)currentWork {
    return nil; //just to keep shit from not breaking while switching away from Work!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
}

#pragma mark -
#pragma mark AVAudioSessionDelegate methods

- (void)beginInterruption {
	DLog(@"begin interruption");
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setValue:@"interrupted" forKey:@"endedWithInterruption"];
	[prefs synchronize];
}

- (void)endInterruption {
	DLog(@"end interruption");
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if ([prefs valueForKey:@"endedWithInterruption"]) {		
		[prefs removeObjectForKey:@"endedWithInterruption"];
		[prefs synchronize];
	}	
}

// Triggered on the iPod player's item being changed.
// Set the correct playback time based on didUserRequestChange state.
- (void)nowPlayingItemChanged:(NSNotification *)notification {
    
    DLog(@"nowPlayingItemChanged");
    	
	if (itemSetManually == NO) self.currentItem = playerController.nowPlayingItem; 
    currentTrackTotalTime = [currentItem duration];
    
    // Disregard repeat requests (iPod often notifies > once).
    // Also can occur when the same collection was tapped by the user twice by playing,
    // backing out, then re-tapping same collection.
	if (lastPlayedItem != nil && lastPlayedItem.persistentId == currentItem.persistentId) {                
        DLog(@"ignoring nowPlayingItem because ID's match: %lld",lastPlayedItem.persistentId);        
        itemSetManually = NO;
		return;
	} 
    
    if (ignoreNowPlayingItemChange == NO) {
        
        if (didUserRequestItemChange == YES) {            
            [self evalTime];            
        } else {            
            // Track was auto-advanced during playback. Set last track as completed.
            if (lastPlayedItem != nil && lastPlayedItem != currentItem) {           
                [lastPlayedItem updateAsComplete];
                [CoreDataUtility save];                
            }       
        }
        
        self.lastPlayedItem = currentItem;
        
        // Save to prefs
        [[DMUserDefaults sharedInstance] setObject:[NSNumber numberWithLongLong:currentItem.persistentId] 
                                            forKey:@"lastPlayedId"];
        
        // Broadcast to listeners
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayingItemChanged" object:nil];
        
        itemSetManually = NO;
        isFirstPlayback = NO;
        
    } else {
        DLog(@"ignoring nowPlayingItem because of flag");
    }
}

// Evaluate whether time should be changed for the current item
- (void)evalTime {
    
    if (forcePlaybackTime > 0) {
        
		// This occurs when a bookmark is played.  It's one of the only times that the time position
		// isn't affected by the iPod at all.
		
        [self.playerController setCurrentPlaybackTime:forcePlaybackTime];
		forcePlaybackTime = 0;		
		
	} else {
        
		// Choose the later of the iPod's or stored current time UNLESS (stored time is zero AND it was listened to previously)
		
        long iPodTime = self.playerController.currentPlaybackTime;
		long dbTime = self.currentItem.lastTime;
		
		if (currentItem.percentComplete == 1.0) {
            [self.playerController setCurrentPlaybackTime:0.0];
        } else if ((dbTime > iPodTime) || (dbTime == 0 && currentItem.hasTrack == YES)) {
			[playerController setCurrentPlaybackTime:dbTime];
        }              
    } 
    
    didUserRequestItemChange = NO;
}

// Sets the current collection and the index of the item in the collection,
// then sets the nowPlayingItem to the last item played (or first).
- (void)setCollectionForColdPlayback:(MPMediaItemCollection *)collection {
    MPMediaItem *item = [collection lastItem];
    DLog(@"cold playback of item %@",item.title);
    [self setCollectionForPlayback:collection 
                          withItem:item]; 
}

// Sole method of changing tracks except when auto-advanced, or via << or >> buttons.
// DO NOT lightly change flags. Test with iOS 4 iPod Touch, iOS 5 phone, and iPad.
- (void)setCollectionForPlayback:(MPMediaItemCollection *)collection withItem:(MPMediaItem *)item {
        
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version < 5.0) { 
        MPMediaItemCollection *newColl = [MPMediaItemCollection collectionWithItems:[collection items]];
        self.currentCollection = newColl;
    } else {        
        self.currentCollection = collection; 
    }
       
    // Set temporarily else would trigger nowPlayingItemChanged twice (once for collection, once for item)
    ignoreNowPlayingItemChange = YES;       
    [playerController setQueueWithItemCollection:currentCollection];   
    ignoreNowPlayingItemChange = NO;
    
    // Differentiates from auto-advance, also set by << or >>
    didUserRequestItemChange = YES; 
          
    // On iOS 4 compiled against iOS 5, MP is all fucked up
    if (version < 5.0) { 
        // When YES, nowPlayingItemChanged won't set item from player 
        itemSetManually = YES;        
        self.currentItem = item;        
    }
        
    playerController.nowPlayingItem = item;
    
    // Special handling due to iPad bug that causes nowPlayingItem to not fire until the 2nd reques
    if (isIPad == YES && isFirstPlayback == YES) {
        [self nowPlayingItemChanged:nil];
    }
}

- (void)playbackStateChanged:(NSNotification *)notification {
    
    DLog(@"playback state: %i",playerController.playbackState);
	
	//notify listeners like PlayerVC
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PlaybackStateChanged" object:nil];
	
    // In version 1.5.1 removed auto-saving here. There are too many ways for this to go wrong including
    // saving before the current time is loaded from DB and when transitioning from pause to playing.
    // Better to save at specific events.
}

- (void)libraryChanged:(NSNotification *)notification {
	//NSLog(@"Library changed");
	//Have PlayerVC pop back to Library!
}

- (void)registerForNotifications {
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	[notificationCenter
	 addObserver: self
	 selector:    @selector (nowPlayingItemChanged:)
	 name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
	 object:      nil];
	
	[notificationCenter
	 addObserver: self
	 selector:    @selector (playbackStateChanged:)
	 name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
	 object:      nil];
    
	[self.playerController beginGeneratingPlaybackNotifications];
	
	[notificationCenter
	 addObserver: self 
	 selector:    @selector(libraryChanged:) 
	 name:        MPMediaLibraryDidChangeNotification 
	 object:      nil];
	
	[[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
}

- (void)unregisterForNotifications {		
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self 
								  name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification 
								object:nil];
	
	[notificationCenter removeObserver:self 
								  name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
								object:nil];
	
	[self.playerController endGeneratingPlaybackNotifications];
	
	[notificationCenter removeObserver:self
								  name:MPMediaLibraryDidChangeNotification
								object:nil];
	
	[[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
}

- (void)updateWork {	
    if (currentCollection != nil && lastPlayedItem != nil) {         
        [currentCollection saveState];
    }	
}

- (BOOL)isPlaying {	
	return self.playerController.playbackState == MPMusicPlaybackStatePlaying;
}

// Returns index of the current MPMediaItem.
// Note: in iOS 5, this method is available on MPMusicPlayerController
- (int)indexOfNowPlayingItem {
    return [[currentCollection items] indexOfObject:playerController.nowPlayingItem];
}

// Returns count of items in current collection.
- (int)totalItems {
    return [[currentCollection items] count];
}

//Called when app launches with a playing track.  This will determine if the media item is of
//a supported type and load the associated Work as current work if so.
- (BOOL)attemptCurrentWorkAssignmentForPlayingItem {
    self.currentItem = self.playerController.nowPlayingItem;	   
    self.currentCollection = [MPMediaItemCollection collectionForItem:currentItem];
    
    return (currentCollection == nil ? NO : YES);
}

// Attempt to launch the last played track recorded in prefs at app exit.
- (BOOL)attemptPlaybackOfLastPlayedItem {
    
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	@try {
		
		if ([prefs valueForKey:@"lastPlayedId"]) {
			NSNumber *persistentId = (NSNumber *) [prefs valueForKey:@"lastPlayedId"];
			
			//attempt to get media item with this ID
			MPMediaQuery *query = [[[MPMediaQuery alloc] init] autorelease];
			MPMediaPropertyPredicate *idPredicate = [MPMediaPropertyPredicate predicateWithValue:persistentId 
																					 forProperty:MPMediaItemPropertyPersistentID
																				  comparisonType:MPMediaPredicateComparisonEqualTo];
			[query addFilterPredicate:idPredicate];				
			NSArray *results = [query items];
			
			if (results && [results count] > 0) {
				MPMediaItem *item = [results objectAtIndex:0];
				MPMediaItemCollection *coll = [MPMediaItemCollection collectionForItem:item];
				
				if (coll != nil) {
                    [self setCollectionForPlayback:coll 
                                          withItem:item];                   										
					return YES;
				} else {
					return NO; 
				}
			}				
		}		
	} @catch (NSException * e) {
		NSLog(@"Exception trying to play last played %@",[e description]);
		if ([prefs valueForKey:@"lastPlayedId"]) {
			[prefs removeObjectForKey:@"lastPlayedId"];
		}
	}
	
	return NO;	
}

// This method should be called when starting playback, not when toggling play/pause
- (void)beginPlaying {
	if (![self isPlaying]) [self.playerController play];
}

//this should be called after beginPlaying:
- (void)togglePlayPause {			
	if ([self isPlaying]) {
        [self.playerController pause];
    }
	else [self.playerController play];		
}

//advance playback one track and set now playing item to this track's item
- (void)incrementTrack {
    if ([self indexOfNowPlayingItem] < [self totalItems] - 1) {
        [currentCollection saveState];
        didUserRequestItemChange = YES;
        [playerController skipToNextItem];
    }
}

//go back one track and set now playing item to this track's item
- (void)decrementTrack {
	if ([self indexOfNowPlayingItem] > 0) {
        [currentCollection saveState];
        didUserRequestItemChange = YES;
        [playerController skipToPreviousItem];
    }
}

//a track has been selected directly, for instance by a bookmark being selected
- (void)playTrack:(Track *)track atTime:(long)time{
	MPMediaItem *item = track.mediaItem;
    
	if (item.persistentId == currentItem.persistentId) {
		[self.playerController setCurrentPlaybackTime:time];
	} else {
        forcePlaybackTime = time;
        didUserRequestItemChange = YES;        
		playerController.nowPlayingItem	= item;
	}
	
	if (![self isPlaying]) [self.playerController play];
}

//in low memory conditions, clear out cached media items
- (void)clearMediaItemCache {
    if (mediaItemsDict != nil) 
        [mediaItemsDict removeAllObjects];
}

//Return a MediaItem for a track's persistent ID either from this class' dicitonary
//or by requesting it from MPMusicPlayer.
- (MPMediaItem *)mediaItemForPersistentId:(NSNumber *)persistentId {
	
	//first see if item is cached
	NSString *sPid = [[NSString alloc] initWithFormat:@"%@",persistentId];
	MPMediaItem *item = [mediaItemsDict objectForKey:sPid];
	
	if (item) {
		[sPid release];
		return item;
	}
	
	//it wasn't cached so query from iPod and add to cache
	MPMediaQuery *query = [[MPMediaQuery alloc] init];
	MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:persistentId 
																		   forProperty:MPMediaItemPropertyPersistentID];
	[query addFilterPredicate:predicate];
	
	NSArray *items = [query items];
	if ([items count] > 0) {
		item = [items objectAtIndex:0];
		[mediaItemsDict setValue:item forKey:sPid];
	}	
	[query release];
	[sPid release];
	
	return item;
}

- (long)currentPlaybackTime {
	return self.playerController.currentPlaybackTime;
}

- (void)setCurrentPlaybackTime:(long)time {
	[self.playerController setCurrentPlaybackTime:time];
}

- (long)totalPlaybackTime {
    return currentTrackTotalTime;
}

- (void)jumpPlaybackTime:(long)seconds {
	long time = self.playerController.currentPlaybackTime + seconds;	
	if (time >= 0 && time < currentTrackTotalTime) {		
		[self.playerController setCurrentPlaybackTime:time];
	} else if (time < 0) {
		[self.playerController setCurrentPlaybackTime:0];
	}
}

- (void)jumpToMaxTime {
    if (currentItem.maxTime > playerController.currentPlaybackTime) {
        playerController.currentPlaybackTime = currentItem.maxTime;
    }
}

- (NSString *)currentPlaybackTimeString:(BOOL)accesible {
	long seconds = self.playerController.currentPlaybackTime; 
	
	if (seconds < 0.0f) {
		return @"00:00"; //yes, I've seen it return -01
	} else {
        return [DMTimeUtils formatSeconds:seconds accessible:accesible];
	}	
}

- (NSString *)currentRemainingTimeString:(BOOL)accesible {
	long secsRemaining = currentTrackTotalTime - self.playerController.currentPlaybackTime;
	
	if (secsRemaining > 0) {
        if (accesible == NO)
            return [NSString stringWithFormat:@"-%@",[DMTimeUtils formatSeconds:secsRemaining]];
        else 
            return [DMTimeUtils formatSeconds:secsRemaining accessible:YES];
	} else return @"0:00:00";
}

#pragma mark -
#pragma mark AVPlayer methods

- (void)setPlayerVolumes {
    DMUserDefaults *def = [DMUserDefaults sharedInstance];
    [bellPlayer setVolume:[[def objectForKey:BELL_VOL] floatValue]];
    [clickPlayer setVolume:[[def objectForKey:CLICK_VOL] floatValue]];
    [chimePlayer setVolume:[[def objectForKey:CHIME_VOL] floatValue]];
    bellBuzz = [[[DMUserDefaults sharedInstance] objectForKey:BELL_BUZZ] boolValue];
    clickBuzz = [[[DMUserDefaults sharedInstance] objectForKey:CLICK_BUZZ] boolValue]; 
    chimeBuzz = [[[DMUserDefaults sharedInstance] objectForKey:CHIME_BUZZ] boolValue];
}

//sound a click
- (void)click {
    [clickPlayer play];  
    if (clickBuzz) [self buzz];
}

- (void)chime {
    [chimePlayer play];	 
    if (chimeBuzz) [self buzz];
}

- (void)bell {
	[bellPlayer play];
    if (bellBuzz) [self buzz];
}

- (void)buzz {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


@end