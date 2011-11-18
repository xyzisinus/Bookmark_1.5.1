//
//  MasterMusicPlayer.h
//  Bookmark
//
//  Created by Barry Ezell on 10/20/09.
//  Copyright 2009 Dockmarket LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>
#include "MPMediaItem+Track.h"
#include "MPMediaItemCollection+Work.h"

@interface MasterMusicPlayer : NSObject <AVAudioSessionDelegate> {
	long currentTrackTotalTime;	
	BOOL ignoreNowPlayingItemChange;
    BOOL didUserRequestItemChange;
	long forcePlaybackTime;
    BOOL clickBuzz;
    BOOL chimeBuzz;
    BOOL bellBuzz;
}

+ (MasterMusicPlayer *)instance;
+ (void)clearInstance;

@property (nonatomic, retain) MPMusicPlayerController   *playerController; 
@property (nonatomic, retain) MPMediaItemCollection     *currentCollection;
@property (nonatomic, retain) MPMediaItem               *currentItem;
@property (nonatomic, retain) MPMediaItem               *lastPlayedItem;
@property (nonatomic, retain) NSMutableDictionary       *mediaItemsDict;
@property (nonatomic, retain) AVAudioPlayer             *bellPlayer;
@property (nonatomic, retain) AVAudioPlayer             *clickPlayer;
@property (nonatomic, retain) AVAudioPlayer             *chimePlayer;

- (void)evalTime;
- (void)setCollectionForColdPlayback:(MPMediaItemCollection *)collection;
- (void)setCollectionForPlayback:(MPMediaItemCollection *)collection withItem:(MPMediaItem *)item;
- (void)beginPlaying;
- (void)togglePlayPause;
- (BOOL)isPlaying;
- (int)indexOfNowPlayingItem;
- (int)totalItems;
- (void)incrementTrack;
- (void)decrementTrack;
- (void)playTrack:(Track *)track atTime:(long)time;
- (BOOL)attemptCurrentWorkAssignmentForPlayingItem;
- (BOOL)attemptPlaybackOfLastPlayedItem;
- (void)nowPlayingItemChanged:(NSNotification *)notification;
- (void)playbackStateChanged:(NSNotification *)notification;
- (void)libraryChanged:(NSNotification *)notification;
- (void)registerForNotifications;
- (void)unregisterForNotifications;
- (void)updateWork;
- (void)clearMediaItemCache;
- (MPMediaItem *)mediaItemForPersistentId:(NSNumber *)persistentId;
- (long)currentPlaybackTime;
- (long)totalPlaybackTime;
- (void)setCurrentPlaybackTime:(long)time;
- (void)jumpPlaybackTime:(long)seconds;
- (void)jumpToMaxTime;
- (NSString *)currentPlaybackTimeString:(BOOL)accesible;
- (NSString *)currentRemainingTimeString:(BOOL)accessible;
- (void)setPlayerVolumes;
- (void)click;
- (void)chime;
- (void)bell;
- (void)buzz;

@end
