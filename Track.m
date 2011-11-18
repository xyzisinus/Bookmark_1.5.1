// 
//  Track.m
//  Bookmark
//
//  Created by Barry Ezell on 1/14/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import "Track.h"
#import "MasterMusicPlayer.h"
#import "Work.h"
#import "CoreDataUtility.h"

@interface Track ()
@property (nonatomic, retain) MPMediaItem *_mediaItem;
@end

@implementation Track 

@dynamic maxTime;
@dynamic persistentId;
@dynamic lastTime;
@dynamic work;
@dynamic bookmarks;

@synthesize _mediaItem;

// Return the Track for this persistentId if one exists
+ (Track *)trackForPersistentId:(unsigned long long)persistentId {
        
    NSManagedObjectContext *context = [[CoreDataUtility sharedUtility] managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Track" inManagedObjectContext:context]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"persistentId == %lld",persistentId];
	[fetchRequest setPredicate:predicate];
    
	Track *track = nil;
	NSError *error = nil;
	NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
	
	if ([array count] > 0) {
        track = (Track *) [array objectAtIndex:0];
    }
    [fetchRequest release];
    
    return track;
}

+ (Track *)createObject:(MPMediaItem *)item {
    
    NSManagedObjectContext *context = [[CoreDataUtility sharedUtility] managedObjectContext];
    Track * track = (Track *) [NSEntityDescription insertNewObjectForEntityForName:@"Track" 
                                                        inManagedObjectContext:context];
    
    track.persistentId = [NSNumber numberWithLongLong:[item persistentId]];
    
    // Note: not saving here because Tracks are always created in the context of 
    // saving state on a Work, which will call [self save];
    
    return track;
}

- (void)resetMaxTime {
	self.maxTime = [NSNumber numberWithInt:0];
}

// Return either the cached item else fetch from MPMusicPlayer.
- (MPMediaItem *)mediaItem {
	if (_mediaItem == nil) {
        MasterMusicPlayer *mmp = [MasterMusicPlayer instance];
        self._mediaItem = [mmp mediaItemForPersistentId:self.persistentId];        
	}
    
    return _mediaItem;
}

//Return an ordered array of bookmarks sorted by startTime
- (NSArray *)orderedBookmarks {
		
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[self.bookmarks count]];
	for (Bookmark *b in self.bookmarks) {
		[arr addObject:b];
	}
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
	NSArray *bkmks = [arr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sort,nil]];
	[sort release];
		
	return bkmks;
}

- (NSString *)formatForEmail {
	NSMutableString *s = [[[NSMutableString alloc] init] autorelease];
	//[s appendString:[NSString stringWithFormat:@"Track: %@\n", self.title]];
	
	for (Bookmark *b in [self orderedBookmarks]) {
		[s appendString:[b formatForEmail]];
	}
	
	[s appendString:@"\n"];	
	return s;	
}

- (void)dealloc {
	[_mediaItem release];
	[super dealloc];	
}


@end
