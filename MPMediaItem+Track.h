//
//  MPMediaItem+Track.h
//  Bookmark
//
//  Created by Barry Ezell on 8/2/11.
//  Copyright 2011 Dockmarket LLC. All rights reserved.
//
//  Category of MPMediaItem. Added in version 1.5 to reduce 
//  dependence on Track because not all items must be persisted.
//

#import <Foundation/Foundation.h>
#import "Track.h"
#import "Bookmark.h"

@interface MPMediaItem (Track) 

@property (nonatomic, readonly) unsigned long long  persistentId;
@property (nonatomic, readonly) BOOL                isPodcast;
@property (nonatomic, readonly) long                duration;
@property (nonatomic, readonly) float               percentComplete;
@property (nonatomic, readonly) long                lastTime;
@property (nonatomic, readonly) long                maxTime;
@property (nonatomic, readonly) NSString            *title;
@property (nonatomic, readonly) NSString            *albumTitle;
@property (nonatomic, readonly) NSString            *author;
@property (nonatomic, readonly) NSDate              *releaseDate;
@property (nonatomic, readonly) int                 trackNumber;
@property (nonatomic, readonly) BOOL                hasTrack;

- (void)updateAsComplete;
- (void)updateAsNew;
- (Track *)associatedTrack;

@end
