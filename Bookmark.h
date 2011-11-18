//
//  Bookmark.h
//  Bookmark
//
//  Created by Barry Ezell on 1/14/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NotesViewController.h"

@class Track;

@interface Bookmark :  NSManagedObject<NotesViewDelegate> {
}

@property (nonatomic, retain) NSNumber  * startTime;
@property (nonatomic, retain) NSString  * title;
@property (nonatomic, retain) NSString  * notes;
@property (nonatomic, retain) NSNumber  * stopTime;
@property (nonatomic, retain) NSString  * kind;
@property (nonatomic, retain) Track     * track;

// Non-persistent attributes
@property (nonatomic, assign) int       itemIdx;

+ (Bookmark *)createBookmarkForStartTime:(long)seconds isQuickBookmark:(BOOL)quick;

- (void)setDefaultTitle:(MPMediaItemCollection *)col;
- (NSString *)formatForEmail;

@end



