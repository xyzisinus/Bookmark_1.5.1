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
	int currentTrackIdx;
	BOOL hasSetInitialTrackIdx;
}

@property (nonatomic, retain) NSString* author;
@property (nonatomic, retain) NSString* sortAuthor;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* sortTitle;
@property (nonatomic, retain) NSString* notes;
@property (nonatomic, retain) NSNumber* category;
@property (nonatomic, retain) NSNumber* present;
@property (nonatomic, retain) NSNumber* percentComplete;
@property (nonatomic, retain) NSNumber* tracksCount;
@property (nonatomic, retain) NSSet* tracks;
@property (nonatomic, retain) Track * currentTrack;
@property (nonatomic, readonly) int currentTrackIdx;
@property (nonatomic, retain) NSDate   * lastListenedTo;
@property (nonatomic, retain) MPMediaItemCollection *mediaItemCollection;

+ (void)loadWorksForCategory:(LibraryCategory)category;
+ (Work *)workForTitle:(NSString *)albumTitle 
			 andAuthor:(NSString *)author 
		   andCategory:(LibraryCategory)category 
			 inContext:(NSManagedObjectContext *)context;
+ (Work *)workForMediaItem:(MPMediaItem *)item;
+ (NSString *)titleForSortingFromLongTitle:(NSString *)title;
+ (NSString *)authorForSorting:(NSString *)author;

- (void)save;
- (UIImage *)artworkAtSize:(CGSize)size;
- (int)trackCount;
- (int)newTrackCount;
- (LibraryCategory)categoryRaw;
- (void)setCategoryRaw:(LibraryCategory)category;
- (NSArray *)orderedBookmarks;
- (Track *)currentOrFirstTrack;
- (Track *)incrementCurrentTrack;
- (Track *)decrementCurrentTrack;
- (void)chooseCurrentTrack:(Track *)track;
- (void)setAndSaveCurrentTrack:(Track *)track;
- (void)updateMetadata;
- (void)updateMetadataForTrackWithID:(uint64_t)targetId;
- (void)resetAsNew;
- (void)setAsCompleted;
- (NSString *)formatForEmail;

@end

@interface Work (CoreDataGeneratedAccessors)
- (void)addTracksObject:(Track *)value;
- (void)removeTracksObject:(Track *)value;
- (void)addTracks:(NSSet *)value;
- (void)removeTracks:(NSSet *)value;

@end

