// Copyright Barry Ezell. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
//  1. Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in the
//     documentation and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of its contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  MPMediaItemCollection+Work.m
//  Bookmark
//
//  Created by Barry Ezell on 8/2/11.
//

#import "MPMediaItemCollection+Work.h"
#import "MPMediaItem+Track.h"
#import "Track.h"
#import "CoreDataUtility.h"

@implementation MPMediaItemCollection (Work)

+ (NSArray *)collectionsForCategory:(LibraryCategory)category withSort:(LibrarySortOrder)sortOrder {
            
    NSArray *collections = nil;
    if (category == LibraryCategoryBooks) {
        collections = [self audiobookCollections];       
    } else if (category == LibraryCategoryPodcasts) {
        collections = [self podcastCollections];        
    } 
                
    // Apply sort
    NSString *sortKey = @"sortTitle";
    if (sortOrder == LibrarySortOrderAuthor) sortKey = @"sortAuthor";
    else if (sortOrder == LibrarySortOrderRecent) sortKey = @"lastListenedTo";
    
    BOOL ascending = (sortOrder == LibrarySortOrderRecent ? NO : YES);
    
    NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:sortKey 
                                                          ascending:ascending] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sort];
        
    return [collections sortedArrayUsingDescriptors:sortDescriptors];      
}

+ (NSArray *)audiobookCollections {
   
    // If set in Settings, return the unique collections from the Audiobooks tab, and genres "Speech", "Audiobook", and "Audiobooks".
    MPMediaQuery *q1 = [MPMediaQuery audiobooksQuery];
    q1.groupingType = MPMediaGroupingAlbum;
    
    if ([[[DMUserDefaults sharedInstance] objectForKey:EXPANDED_BOOK_SEARCH] boolValue] == NO) {
        return [q1 collections];
    }
        
    MPMediaPropertyPredicate *spokenGenrePred = [MPMediaPropertyPredicate predicateWithValue:@"Speech" 
                                                                                 forProperty:MPMediaItemPropertyGenre];   
    MPMediaQuery *q2 = [[[MPMediaQuery alloc] init] autorelease];
    [q2 addFilterPredicate:spokenGenrePred];
    q2.groupingType = MPMediaGroupingAlbum;
    
    MPMediaPropertyPredicate *audiobookPred = [MPMediaPropertyPredicate predicateWithValue:@"Audiobook" 
                                                                               forProperty:MPMediaItemPropertyGenre];
    MPMediaQuery *q3 = [[[MPMediaQuery alloc] init] autorelease];
    [q3 addFilterPredicate:audiobookPred];
    q3.groupingType = MPMediaGroupingAlbum;
    
    MPMediaPropertyPredicate *audiobooksPred = [MPMediaPropertyPredicate predicateWithValue:@"Audiobooks" 
                                                                               forProperty:MPMediaItemPropertyGenre];
    MPMediaQuery *q4 = [[[MPMediaQuery alloc] init] autorelease];
    [q4 addFilterPredicate:audiobooksPred];
    q4.groupingType = MPMediaGroupingAlbum;
    
    // Using a set because it only adds unique objects.
    NSMutableSet *superSet = [NSMutableSet setWithArray:[q1 collections]];        
    [superSet addObjectsFromArray:[q2 collections]];
    [superSet addObjectsFromArray:[q3 collections]];
    [superSet addObjectsFromArray:[q4 collections]];
        
    return [superSet allObjects];
}

+ (NSArray *)podcastCollections {
    MPMediaQuery *q1 = [MPMediaQuery podcastsQuery];
    return [q1 collections];
}

// When the app is launched with a playing item, the collection is unknown. 
// Return the appropriate collection for the item, given its media type. 
+ (MPMediaItemCollection *)collectionForItem:(MPMediaItem *)item {
    
    // TODO: attempt to make this more efficient by using media predicates instead of looping
    MPMediaQuery *query = nil;
    if ([item isPodcast] == NO) {
        query = [MPMediaQuery audiobooksQuery];
    } else {
        query = [MPMediaQuery podcastsQuery];
    }
    query.groupingType = MPMediaGroupingAlbum;
    
    for (MPMediaItemCollection *coll in [query collections]) {
        if ([[coll items] containsObject:item]) {
            return coll;
        }
    }    
    
    return nil;
}

// Returns album title or podcast title as appropriate
- (NSString *)title {    
    MPMediaItem *mediaItem = [self representativeItem];
    return [mediaItem albumTitle];    
}

// Title with filtering for The, A, An (need to internationalize this)
- (NSString *)sortTitle {
    NSString *t = [self title];
    if ([t length] <= 3) return t;
	
	if ([[[t substringToIndex:4] lowercaseString] isEqualToString:@"the "]) 
		return [[t substringFromIndex:4] lowercaseString];
	
	if ([[[t substringToIndex:3] lowercaseString] isEqualToString:@"an "]) 
		return [[t substringFromIndex:3] lowercaseString];
	
	if ([[[t substringToIndex:2] lowercaseString] isEqualToString:@"a "]) 
		return [[t substringFromIndex:2] lowercaseString];
	
	return [t lowercaseString];
}

- (NSString *)author {
    return [[self representativeItem] valueForProperty:MPMediaItemPropertyAlbumArtist];
}

// Create an author name for sorting by looking for token after first space
// (if more than two tokens) and placing it before remainder of string with a comma.
// For instance Robert Smith becomes smith, robert.  Cher becomes cher.
- (NSString *)sortAuthor {
    NSString *a = [self author];
    
    int spaceIdx = -1;
	
	for (int i=0; i < a.length; i++) {
		unichar aChar = [a characterAtIndex:i];
		if (aChar == ' ') {
			spaceIdx = i;
			break;
		}
	}
	
	if (spaceIdx > 0 && a.length > spaceIdx) {
		a = [[a substringFromIndex:spaceIdx+1] stringByAppendingFormat:@", %@",[a substringToIndex:spaceIdx]];
	} 
	
	return [a lowercaseString];
}

- (NSDate *)mostRecentDate {
    NSDate *latestDate = [NSDate dateWithTimeIntervalSince1970:0];
    
    for (MPMediaItem *item in [self items]) {
        if ([latestDate compare:item.releaseDate] == NSOrderedAscending) {
            latestDate = item.releaseDate;
        }
    }
    
    return latestDate;
}

- (BOOL)isPodcast {
    return [[self representativeItem] isPodcast];
}

// Returns an image of the artwork sized as needed
- (UIImage *)artworkAtSize:(CGSize)size {
	
    MPMediaItem *item = [self representativeItem];
	
	//first see if it's cached locally...
	NSString *tmpImgPath = [NSString stringWithFormat:@"%@/%lld_%d%d.png",NSTemporaryDirectory(),[item persistentId],size.height,size.width];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:tmpImgPath];
	
	UIImage *artwork = nil;	
	if (fileExists) {			
		artwork = [UIImage imageWithContentsOfFile:tmpImgPath];			
	} else {			
		MPMediaItemArtwork *coverArt = [item valueForProperty:MPMediaItemPropertyArtwork]; 
		if (coverArt) {
			artwork = [coverArt imageWithSize:size];
			NSData *imgData = UIImagePNGRepresentation(artwork);	
			[imgData writeToFile:tmpImgPath atomically:NO];
		} 		
	}
	
	if (!artwork) {
		//load placeholder image
		artwork = [UIImage imageNamed:([self isPodcast] ? @"rss_300.png" : @"default_album_art.png")];
	}
	
	return artwork;
}

// Returns MPMediaEntityPropertyPersistentID property for all 
// iOS >= 4.2, else 0.
- (unsigned long long)persistentId {
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 4.2) {
        unsigned long long eId = [[self valueForProperty:MPMediaEntityPropertyPersistentID] unsignedLongLongValue];
        return eId;
    }
    
    return 0;
}

// Returns the percentComplete of the assocated work if any, else 0.0;
- (float)percentComplete {
    Work *work = [self associatedWork];
    return (work != nil ? [[work percentComplete] floatValue] : 0.0f);
}

- (NSDate *)lastListenedTo {
    Work *work = [self associatedWork];
    return (work != nil ? [work lastListenedTo] : nil);
}

// Notes are get or set on track
- (NSString *)notes {
    Work *work = [self associatedWork];
    return (work != nil ? work.notes : nil);
}

- (void)setNotes:(NSString *)newNotes {
    Work *work = [self associatedWork:YES];
    if (newNotes != nil && [work.notes isEqualToString:newNotes] == NO) {
        work.notes = newNotes;
        [CoreDataUtility save];
    }
}

- (int)count {
    return [[self items] count];
}

// Count of items whose percentComplete == 0
- (int)newCount {
    int new = 0;
    for (MPMediaItem *item in [self items]) {
        if (item.percentComplete == 0.0) new++;
    }
    return new;
}

// Returns the last MPMediaItem played else the
// item at index 0;
- (MPMediaItem *)lastItem {
    Work *work = [self associatedWork];
    
    if (work != nil) {
        Track *track = work.currentTrack;
        if (track != nil) {            
            for (MPMediaItem *anItem in [self items]) {
                if ([anItem persistentId] == [track.persistentId longLongValue]) return anItem;
            }            
        }
    }
    
    return [[self items] objectAtIndex:0];
}

#pragma mark - Bookmarking

// Returns bookmarks from associated Work's Tracks.
- (NSArray *)bookmarks {
    
    // To ensure the bookmark order matches the presented track order, 
    // iterate over MPMediaItems, adding all related bookmarks. Each bookmark will
    // have a non-persistent itemIdx attribute set, for final sorting.
    NSMutableArray *arr = [NSMutableArray array];
    for (int i=0; i < [[self items] count]; i++) {
        MPMediaItem *anItem = [[self items] objectAtIndex:i];
        Track *track = [anItem associatedTrack];
        if (track != nil) {
            for (Bookmark *b in track.bookmarks) {
                b.itemIdx = i;
                [arr addObject:b];
            }
        }
    } 
        
    NSSortDescriptor *sortFirst = [[[NSSortDescriptor alloc] initWithKey:@"itemIdx" 
                                                               ascending:YES] autorelease];    
    NSSortDescriptor *sortTime = [[[NSSortDescriptor alloc] initWithKey:@"startTime" 
                                                          ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortFirst,sortTime,nil];
    
    return [arr sortedArrayUsingDescriptors:sortDescriptors];
}

#pragma mark - Persisted Work methods

// Persist metadata attributes like play date and last track
// to the associated Work object.
- (void)saveState {
    Work *work = [self associatedWork:YES];        
    [work saveState];
}

// Private method returns persisted Work object 
// associated with this collection. 
- (Work *)associatedWork:(BOOL)shouldCreate {
           
    Work *work = nil;
       
    // If entityId is valid, first try looking up using it.
    if ([self persistentId] != 0) {
        work = [Work workForPersistentId:[self persistentId]];
    } 
    
    // Next try looking up via attributes on work and item
    if (work == nil) {
        work = [Work workForMediaItem:[self representativeItem]];
    }
    
    // Create if none exists and flag is set.
    if (work == nil && shouldCreate == YES) {
        work = [Work createObject:self];
    }
            
    return work;
}

- (Work *)associatedWork {
    return [self associatedWork:NO];
}

- (void)updateAsComplete {
    Work *work = [self associatedWork:YES];    
    work.currentTrack = nil;
    work.percentComplete = [NSNumber numberWithFloat:1.0];
    for(MPMediaItem *item in [self items]) {
        [item updateAsComplete];
    }
    [CoreDataUtility save];
}

- (void)updateAsNew {
    Work *work = [self associatedWork:YES];    
    work.currentTrack = nil;
    work.percentComplete = [NSNumber numberWithFloat:0.0];
    for(MPMediaItem *item in [self items]) {
        [item updateAsNew];
    }
    [CoreDataUtility save];
}

#pragma mark - Sharing

- (NSString *)formatForEmail {    
    NSMutableString *s = [[[NSMutableString alloc] init] autorelease];
    [s appendString:[NSString stringWithFormat:@"%@\n", self.title]];
    if ([self isPodcast] == NO) {
        [s appendFormat:@"Author: %@\n\n",self.author];
    }
    
    if (self.notes && [self.notes length] > 0) {
        [s appendString:[NSString stringWithFormat:@"Notes: %@\n\n", self.notes]];
    }
   
    [s appendString:[[self associatedWork] formatForEmail]];
    
    return s;    
}

@end
