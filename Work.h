//
//  Work.h
//  Bookmark
//
//  Created by Barry Ezell on 1/14/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Track;
@class Bookmark;

@protocol WorkDelegate
@required
- (void)worksWereLoaded;
@end

@interface Work :  NSManagedObject {
    BOOL        inSave;
}

@property (nonatomic, retain) NSNumber      *persistentId;
@property (nonatomic, retain) NSString      *author;
@property (nonatomic, retain) NSString      *sortAuthor;
@property (nonatomic, retain) NSString      *title;
@property (nonatomic, retain) NSString      *sortTitle;
@property (nonatomic, retain) NSString      *notes;
@property (nonatomic, retain) NSNumber      *category;
@property (nonatomic, retain) NSNumber      *present;
@property (nonatomic, retain) NSNumber      *percentComplete;
@property (nonatomic, retain) NSNumber      *tracksCount;
@property (nonatomic, retain) NSSet         *tracks;
@property (nonatomic, retain) Track         *currentTrack;
@property (nonatomic, readonly) int         currentTrackIdx;
@property (nonatomic, retain) NSDate        *lastListenedTo;

+ (Work *)workForPersistentId:(unsigned long long)persistentId;
+ (Work *)workForMediaItem:(MPMediaItem *)item;
+ (Work *)createObject:(MPMediaItemCollection *)collection;

- (void)saveState;
- (NSString *)formatForEmail;

@end

@interface Work (CoreDataGeneratedAccessors)
- (void)addTracksObject:(Track *)value;
- (void)removeTracksObject:(Track *)value;
- (void)addTracks:(NSSet *)value;
- (void)removeTracks:(NSSet *)value;
@end

