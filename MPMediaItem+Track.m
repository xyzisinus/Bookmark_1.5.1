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
//  MPMediaItem+Track.m
//  Bookmark
//
//  Created by Barry Ezell on 8/2/11.
//

#import "MPMediaItem+Track.h"
#import "Track.h"

@interface MPMediaItem (Private) 
- (Track *)associatedTrackOrNew;
@end

@implementation MPMediaItem (Track)

- (unsigned long long) persistentId {
    return (unsigned long long) [[self valueForProperty:MPMediaItemPropertyPersistentID] unsignedLongLongValue];
}

- (NSString *)title {
    return [self valueForProperty:MPMediaItemPropertyTitle];
}

- (NSString *)albumTitle {        
    NSString *at;
    if ([self isPodcast]) {
        at = [self valueForProperty:MPMediaItemPropertyPodcastTitle];
    } else {
        at = [self valueForProperty:MPMediaItemPropertyAlbumTitle];
    }
     
    // Because some tracks (from Audible) have title but not album title...
    if (at && [at length] > 0) return at;
    return [self title];
}

- (BOOL)isPodcast {
    return ([[self valueForProperty:MPMediaItemPropertyMediaType] intValue] == MPMediaTypePodcast);
}

- (NSString *)author {
    NSString *albumAuthor = [self valueForProperty:MPMediaItemPropertyAlbumArtist];
	NSString *itemAuthor = [self valueForProperty:MPMediaItemPropertyArtist];
    return (albumAuthor ? albumAuthor : itemAuthor);
}

- (NSDate *)releaseDate {
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 4.0) {
        return [self valueForProperty:MPMediaItemPropertyReleaseDate];
    } else return nil;
}

- (int)trackNumber {
    return [[self valueForProperty:MPMediaItemPropertyAlbumTrackNumber] intValue];
}

- (BOOL)hasTrack {
    return [self associatedTrack] != nil;
}

- (long)duration {
    return [[self valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue];
}

- (float)percentComplete {
    Track *track = [self associatedTrack];
    if (track != nil) {
        return ([track.lastTime floatValue] / (float) [self duration]);
    } else return 0.0;
}

- (long)lastTime {
    Track *track = [self associatedTrack];
    return (track != nil ? [track.lastTime longValue] : 0.0);
}

- (long)maxTime {
    Track *track = [self associatedTrack];
    return (track != nil ? [track.maxTime longValue] : 0.0);
}

#pragma mark - Associated track persistence

- (void)updateAsComplete {
    Track *track = [self associatedTrackOrNew];
    track.lastTime = [NSNumber numberWithLong:[self duration]];
    track.maxTime = [NSNumber numberWithLong:[self duration]];
}

- (void)updateAsNew {
    Track *track = [self associatedTrackOrNew];
    track.lastTime = [NSNumber numberWithLong:0];
    track.maxTime = [NSNumber numberWithLong:0];    
}

// Returns persisted Track object associated with this item, if any.
- (Track *)associatedTrack {
    
    Track *track = nil;
    
    // Try fetching track by its pId.    
    track = [Track trackForPersistentId:[self persistentId]];
    
    return track;
}

// Calls above method and returns a new object if nil
- (Track *)associatedTrackOrNew {
    Track *track = [self associatedTrack];
    return (track == nil ? [Track createObject:self] : track);
}

@end
