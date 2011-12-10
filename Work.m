// 
//  Work.m
//  Bookmark
//
//  Created by Barry Ezell on 1/14/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import "Work.h"
#import "Track.h"
#import "MasterMusicPlayer.h"
#import "CoreDataUtility.h"

@implementation Work 

@dynamic persistentId;
@dynamic author;
@dynamic sortAuthor;
@dynamic title;
@dynamic sortTitle;
@dynamic notes;
@dynamic category;
@dynamic tracks;
@dynamic currentTrack;
@dynamic present;
@dynamic percentComplete;
@dynamic lastListenedTo;
@dynamic tracksCount;

@synthesize currentTrackIdx;

- (void)dealloc {
    [super dealloc];
}

// Fetch the Work associated with a MPMediaEntityPersistentID (if any).
+ (Work *)workForPersistentId:(unsigned long long)persistentId {
    NSManagedObjectContext *context = [[CoreDataUtility sharedUtility] managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Work" inManagedObjectContext:context]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"persistentId == %lld",persistentId];
	[fetchRequest setPredicate:predicate];
    
	Work *work = nil;
	NSError *error = nil;
	NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
	
	if ([array count] > 0) {
        work = [array objectAtIndex:0];
    }
    [fetchRequest release];
        
    return work;
}

// Fetch the Work object associated with an MPMediaItem (if any).
+ (Work *)workForMediaItem:(MPMediaItem *)item {
    
    // Lookup by author and title    
    NSString *author = [item author];		
	NSString *albumTitle = [item albumTitle];
		
	// In the case where a track doesn't have an album name,
    // use the track's title.
	if (albumTitle == nil || [albumTitle length] == 0) {
		albumTitle = [item title];
	}

    NSManagedObjectContext *context = [[CoreDataUtility sharedUtility] managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Work" inManagedObjectContext:context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"author == %@ and title = %@",author,albumTitle];
	[fetchRequest setPredicate:predicate];
    
	Work *work = nil;
	NSError *error = nil;
	NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
	
	if ([array count] > 0) {
        work = [array objectAtIndex:0];
    }
    [fetchRequest release];
    
    return work;
}

+ (Work *)createObject:(MPMediaItemCollection *)collection {
    NSManagedObjectContext *context = [[CoreDataUtility sharedUtility] managedObjectContext];
    Work *work = (Work *) [NSEntityDescription insertNewObjectForEntityForName:@"Work" 
                                                    inManagedObjectContext:context];
    
    // Populate attributes from representative item
    MPMediaItem *representativeItem = [collection representativeItem];
    work.author = [representativeItem author];
    work.title = [representativeItem albumTitle];
    // ignoring category for now (unsure if absolutely required)
    // ignoring sort author and sort title (can be done on the fly)
    
    // Persistent ID
    work.persistentId = [NSNumber numberWithLongLong:[collection persistentId]];
         
    if (![CoreDataUtility save]) {
        work = nil;
    }
    
    return work;
}

// Update relevant attributes for this Work and the current Track
- (void)saveState {
    
    // BOOL lock
    //if (inSave) return;
    //inSave = YES;
    
    MasterMusicPlayer *mmp = [MasterMusicPlayer instance];
    MPMediaItem *item = [mmp currentItem];
    
    // Get the relevant track
    Track *track = [Track trackForPersistentId:[item persistentId]];
    
    // Create a track if needed
    if (track == nil) {        
        track = [Track createObject:item];
        track.work = self;
    } else if (track.work == nil) {
        // Added this because of very infrequently occurrence in beta of 1.5. Feels hacky.
        // TODO, fix root cause!
        track.work = self;
    }
    
    // Update track attributes
    NSNumber *curTime = [NSNumber numberWithLong:[mmp currentPlaybackTime]];    
    track.lastTime = curTime;
    if ([curTime compare:track.maxTime] == NSOrderedDescending) track.maxTime = curTime;
    
    // Update work attributes
    self.currentTrack = track;
    self.lastListenedTo = [NSDate date];
    
    // Calculate percent complete by rough approximation (not by counting seconds for all tracks)
    // as this track # - 1 / total tracks + this track's % complete.
    float percPerTrack = 1.0 / (float) [mmp totalItems];
    float trackPercComplete = ((float) [mmp currentPlaybackTime] / (float) [mmp totalPlaybackTime]) * percPerTrack;    
    float percentage = 0.0;
    
    if ([mmp indexOfNowPlayingItem] > 0) {
        percentage += ((float) [mmp indexOfNowPlayingItem]) * percPerTrack;
    }
    
    percentage += trackPercComplete;
    self.percentComplete = [NSNumber numberWithFloat:percentage];
    
    [CoreDataUtility save];
    inSave = NO;
    
    //DLog(@"Saved state: lastTime: %ld, maxTime: %ld", [track.lastTime longValue], [track.maxTime longValue]);
}

- (NSString *)formatForEmail {
    NSMutableString *s = [[[NSMutableString alloc] init] autorelease];    
    for (Track *track in self.tracks) {
        for (Bookmark *bkmk in track.bookmarks) {
            [s appendString:[bkmk formatForEmail]];
        }
    }
    return s;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Work - title: %@, author: %@", self.title, self.author];
}

@end
