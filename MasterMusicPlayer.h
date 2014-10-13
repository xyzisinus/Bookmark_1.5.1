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
//  MasterMusicPlayer.h
//  Bookmark
//
//  Created by Barry Ezell on 10/20/09.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>
#include "MPMediaItem+Track.h"
#include "MPMediaItemCollection+Work.h"
#include "UIDevice+Hardware.h"

@interface MasterMusicPlayer : NSObject <AVAudioSessionDelegate> {
	long currentTrackTotalTime;		
    BOOL didUserRequestItemChange;
    BOOL ignoreNowPlayingItemChange;
    BOOL itemSetManually;
    BOOL isFirstPlayback;
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
@property (nonatomic, readonly) BOOL                    isIPad;

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
