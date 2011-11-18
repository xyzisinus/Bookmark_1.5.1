//
//  MPMediaItemCollection+Work.h
//  Bookmark
//
//  Created by Barry Ezell on 8/2/11.
//  Copyright 2011 Dockmarket LLC. All rights reserved.
//
//  Category of MPMediaItemCollection with added static methods
//  for loading audiobook and pocast collections. 
//  
//  Added in version 1.5 to reduce dependence on Work because not all
//  collections must be persisted.
//

#import <Foundation/Foundation.h>
#import "MasterMusicPlayer.h"
#import "Work.h"

@interface MPMediaItemCollection (Work) 

+ (NSArray *)collectionsForCategory:(LibraryCategory)category withSort:(LibrarySortOrder)sortOrder;
+ (NSArray *)audiobookCollections;
+ (NSArray *)podcastCollections;
+ (MPMediaItemCollection *)collectionForItem:(MPMediaItem *)item;

@property (nonatomic, readonly) NSString            *title;
@property (nonatomic, readonly) NSString            *sortTitle;
@property (nonatomic, readonly) BOOL                isPodcast;
@property (nonatomic, readonly) NSString            *author;
@property (nonatomic, readonly) NSString            *sortAuthor;
@property (nonatomic, readonly) NSDate              *mostRecentDate;
@property (nonatomic, readonly) unsigned long long  persistentId;
@property (nonatomic, readonly) float               percentComplete;
@property (nonatomic, readonly) NSDate              *lastListenedTo;
@property (nonatomic, assign)   NSString            *notes;
@property (nonatomic, readonly) int                 count;
@property (nonatomic, readonly) int                 newCount;
@property (nonatomic, readonly) MPMediaItem         *lastItem;
@property (nonatomic, readonly) NSArray             *bookmarks;

- (UIImage *)artworkAtSize:(CGSize)size;

- (void)saveState;

// Use this only when necessary (e.g., creating a Bookmark). 
// Instead default to using above properties.
- (Work *)associatedWork:(BOOL)shouldCreate;
- (Work *)associatedWork;
- (void)updateAsComplete;
- (void)updateAsNew;
- (NSString *)formatForEmail;

@end
