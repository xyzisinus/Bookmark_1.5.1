//
//  Track.h
//  Bookmark
//
//  Created by Barry Ezell on 1/14/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import "BookmarkAppDelegate.h"

@interface Track :  NSManagedObject {
	
}

//Core Data properties
@property (nonatomic, retain) NSNumber * maxTime;
@property (nonatomic, retain) NSNumber * persistentId;
@property (nonatomic, retain) NSNumber * lastTime;
@property (nonatomic, retain) NSManagedObject * work;
@property (nonatomic, retain) NSSet* bookmarks;

//other properties
@property (nonatomic, readonly) MPMediaItem *mediaItem;

+ (Track *)trackForPersistentId:(unsigned long long)persistentId;
+ (Track *)createObject:(MPMediaItem *)item;

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

