//
//  MPMediaItem+Track.m
//  Bookmark
//
//  Created by Barry Ezell on 8/2/11.
//  Copyright 2011 Dockmarket LLC. All rights reserved.
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
