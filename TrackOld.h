//
//  Track.h
//  Bookmark
//
//  Created by Barry Ezell on 1/14/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import "BookmarkAppDelegate.h"

@interface Track :  NSManagedObject {
	MPMediaItem *mediaItem;
}

//Core Data properties
@property (nonatomic, retain) NSNumber * maxTime;
@property (nonatomic, retain) NSNumber * persistentId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * lastTime;
@property (nonatomic, retain) NSNumber * present;
@property (nonatomic, retain) NSNumber * totalTime;
@property (nonatomic, retain) NSNumber * trackNumber;
@property (nonatomic, retain) NSNumber * diskNumber;
@property (nonatomic, retain) NSManagedObject * work;
@property (nonatomic, retain) NSSet* bookmarks;

//other properties
@property (nonatomic, retain) MPMediaItem *mediaItem;

+ (Track *)trackForMediaItem:(MPMediaItem *)mediaItem 
				 andCategory:(LibraryCategory)category;

+ (Track *)trackForTitle:(NSString *)title 
				   andAuthor:(NSString *)author;

- (float)percentComplete;
- (BOOL)isNew;
- (BOOL)isComplete;
- (void)updateMetadata;
- (void)updateAsNew;
- (void)updateAsComplete;
- (void)resetMaxTime;
- (NSArray *)orderedBookmarks;
- (NSString *)formatForEmail;

@end

@interface Track (CoreDataGeneratedAccessors)
- (void)addBookmarksObject:(NSManagedObject *)value;
- (void)removeBookmarksObject:(NSManagedObject *)value;
- (void)addBookmarks:(NSSet *)value;
- (void)removeBookmarks:(NSSet *)value;
@end

