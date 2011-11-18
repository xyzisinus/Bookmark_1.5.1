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

@synthesize currentTrackIdx, mediaItemCollection;

- (void)dealloc {
    [mediaItemCollection release];
    [super dealloc];
}

+ (void)loadWorksForCategory:(LibraryCategory)category {
		
    //NSManagedObjectContext *context = [[CoreDataUtility sharedUtility] managedObjectContext];
    
    MPMediaQuery *query;
    NSArray *collections = [NSArray array];
    
    if (category == LibraryCategoryBooks) {
      query = [MPMediaQuery audiobooksQuery];
      
    } else if (category == LibraryCategoryPodcasts) {
      query = [MPMediaQuery podcastsQuery];
      
    } else if (category == LibraryCategoryiTunesU) {
      query = [[MPMediaQuery alloc] init];
      
      MPMediaPropertyPredicate *iTunesUPred =
          [MPMediaPropertyPredicate predicateWithValue: @"iTunes U"
                                           forProperty: MPMediaItemPropertyGenre];
      [query addFilterPredicate:iTunesUPred];
    } 
    
    // Change the grouping type to Album from the default Title
    // and get the collections
    query.groupingType = MPMediaGroupingAlbum;
    collections = [query collections];
    
    NSDate *startDate = [NSDate date];
    
    for (MPMediaItemCollection *coll in collections) {
          
          // Get a representative item for this collection
          MPMediaItem *item = [coll representativeItem];
          
          // Fetch or create a Track for this item. 
          // The Work object associated with the Track will also be
          // created if it doesn't exist.
          Track *track = [Track trackForMediaItem:item 
                       andCategory:category];
          
          // Record the number of tracks for this Work
          Work *work = (Work *) track.work;
          work.mediaItemCollection = coll;
          work.tracksCount = [NSNumber numberWithInt:[coll count]];
    }
    
    NSTimeInterval launchTime = [startDate timeIntervalSinceNow] * -1.0;
    NSLog(@"Launch time = %f",launchTime);
    
    //NSError *error = nil;
    //if (![context save:&error]) DLog(@"Save error %@",[error localizedDescription]);
}

+ (Work *)workForTitle:(NSString *)albumTitle 
			 andAuthor:(NSString *)author 
		   andCategory:(LibraryCategory)category 
			 inContext:(NSManagedObjectContext *)context {
	
	//either fetch a work by this title and author or create one
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Work" inManagedObjectContext:context]];
	
	//predicate will depend on whether is podcast (title only) or anything else (title and author)
	//podcasts frequently display different authors depending on guests of a show, etc. so it's unreliable
	NSPredicate *predicate;
	if (category == LibraryCategoryPodcasts) {	
		predicate = [NSPredicate predicateWithFormat:@"title == %@",albumTitle];
	} else {
		predicate = [NSPredicate predicateWithFormat:@"title == %@ and author == %@",albumTitle,author];
	}
	[fetchRequest setPredicate:predicate];

	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	[sort release];
	
	Work *work = nil;
	NSError *error = nil;
	NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
	if (array == nil || [array count] == 0) {
		work = (Work *) [NSEntityDescription insertNewObjectForEntityForName:@"Work" 
														inManagedObjectContext:context];
		work.title = albumTitle;
		work.sortTitle = [Work titleForSortingFromLongTitle:work.title];
		work.author = author;
		work.sortAuthor = [Work authorForSorting:author];
		[work setCategoryRaw:category];
	} else {
		work = [array objectAtIndex:0];
	}
	
	[fetchRequest release];
	
	//set new for each query
	work.present = [NSNumber numberWithBool:YES];
		
	return work;
} 

//This is used when the app is started with the goal of immediately loading
//and playing an item instead of displaying the library.  It's called by MasterMusicPlayer.
//Since tracks aren't yet loaded, it will load the target track and other tracks
//in the same work by an iPod query.
+ (Work *)workForMediaItem:(MPMediaItem *)item {
	
	//first ensure this is a valid media type
	int type = [[item valueForProperty:MPMediaItemPropertyMediaType] intValue]; 	
	if (type != MPMediaTypeAudioBook && type != MPMediaTypePodcast) {
		return nil;
	}	
		
	//construct and execute the iPod query
	NSManagedObjectContext *context = [[CoreDataUtility sharedUtility] managedObjectContext];	
	LibraryCategory category = (type == MPMediaTypeAudioBook ? LibraryCategoryBooks : LibraryCategoryPodcasts);
		
	//load all items related to this item (i.e., in the same work),
	//also handling the case where a track doesn't have an album name
	NSString *predTitle;
	MPMediaPropertyPredicate *firstPredicate;
	if (category == LibraryCategoryPodcasts) {
		//podcast
		predTitle = [item valueForProperty:MPMediaItemPropertyPodcastTitle];
		firstPredicate = [MPMediaPropertyPredicate predicateWithValue:predTitle 
														  forProperty:MPMediaItemPropertyPodcastTitle];
	} else {
		//book, check to see if we can use album title or have to rely on track title
		predTitle = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
		
		if (predTitle == nil || [predTitle length] == 0) {
			predTitle = [item valueForProperty:MPMediaItemPropertyTitle];
			firstPredicate = [MPMediaPropertyPredicate predicateWithValue:predTitle 
															  forProperty:MPMediaItemPropertyTitle];
		} else {						
			firstPredicate = [MPMediaPropertyPredicate predicateWithValue:predTitle 
															  forProperty:MPMediaItemPropertyAlbumTitle];
		}	
	}
	
	NSMutableSet *filters = [NSMutableSet setWithObject:firstPredicate];
	
	//add author only if this is a books query
	if (category == LibraryCategoryBooks) {
		//MPMediaPropertyPredicate *authorPred = [MPMediaPropertyPredicate predicateWithValue:author 
		//																		forProperty:MPMediaItemPropertyAlbumArtist];
		//[filters addObject:authorPred];
	}
	
	MPMediaQuery *query = [[MPMediaQuery alloc] initWithFilterPredicates:filters];
	NSArray *items = [query items];
	[query release];
	
	//load one track for each media item returned in the iPod query
	Work *w = nil;	
	uint64_t orgPid = [[item valueForProperty:MPMediaItemPropertyPersistentID] unsignedLongLongValue];
	for (MPMediaItem *i in items) {		
		uint64_t curPid = [[i valueForProperty:MPMediaItemPropertyPersistentID] unsignedLongLongValue];
		
		Track *t = [Track trackForMediaItem:i 
					 andCategory:category];		
		
		if (orgPid == curPid) {
			w = (Work *) t.work;
		}
	}
		
	NSError *error = nil;
	if (![context save:&error]) DLog(@"Save error %@",[error localizedDescription]);
	
	//this will set the current track and track index used by PlayerViewController
	if (w) {
		[w updateMetadataForTrackWithID:orgPid];
	}
	
	return w;
}

//return a sorting string sans "a", "an", and "the"
+ (NSString *)titleForSortingFromLongTitle:(NSString *)title {
	if ([title length] <= 3) return title;
	
	if ([[[title substringToIndex:4] lowercaseString] isEqualToString:@"the "]) 
		return [[title substringFromIndex:4] lowercaseString];
	
	if ([[[title substringToIndex:3] lowercaseString] isEqualToString:@"an "]) 
		return [[title substringFromIndex:3] lowercaseString];
	
	if ([[[title substringToIndex:2] lowercaseString] isEqualToString:@"a "]) 
		return [[title substringFromIndex:2] lowercaseString];
	
	return [title lowercaseString];
}

//attempt to create an author name for sorting by looking for token after first space
//if more than two tokens, and placing it before remainder of string with a comma.
//For instance Robert Smith becomes smith, robert.  Cher becomes cher.
+ (NSString *)authorForSorting:(NSString *)author {
	int spaceIdx = -1;
	
	for (int i=0; i < author.length; i++) {
		unichar aChar = [author characterAtIndex:i];
		if (aChar == ' ') {
			spaceIdx = i;
			break;
		}
	}
	
	if (spaceIdx > 0 && author.length > spaceIdx) {
		author = [[author substringFromIndex:spaceIdx+1] stringByAppendingFormat:@", %@",[author substringToIndex:spaceIdx]];
	} 
	
	return [author lowercaseString];
}

//generic save method
- (void)save {
	@synchronized(self) {	
		NSManagedObjectContext *context = [[CoreDataUtility sharedUtility] managedObjectContext];
		
		NSError *error = nil;		
		if(![context save:&error]) {
			DLog(@"Failed to save to data store: %@", [error localizedDescription]);
			NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
			if(detailedErrors != nil && [detailedErrors count] > 0) {
				for(NSError* detailedError in detailedErrors) {
					DLog(@"  DetailedError: %@", [detailedError userInfo]);
				}
			}
			else {
				DLog(@"  %@", [error userInfo]);
			}
		} 	
	}
}

//use these instead of directly calling work.category and [work setCategory]
-(LibraryCategory)categoryRaw {
    return (LibraryCategory) [[self category] intValue];
}

-(void)setCategoryRaw:(LibraryCategory)category {
    [self setCategory:[NSNumber numberWithInt:category]];
}

//Return an ordered array of bookmarks
- (NSArray *)orderedBookmarks {
	NSMutableArray *bookmarks = [NSMutableArray array];
	for (Track *t in [self orderedTracks]) {		
		for(Bookmark *bkmk in [t orderedBookmarks]) {
			[bookmarks addObject:bkmk];
		}		
	}	
		
	return bookmarks;
}

//this is the method that should be used by other classes instead of work.currentTrack = track 
//as this will save via CD for each call
- (void)setAndSaveCurrentTrack:(Track *)track {
	if ([[self orderedTracks] containsObject:track] == YES) {
		self.currentTrack = track;
		currentTrackIdx = [[self orderedTracks] indexOfObject:self.currentTrack];
		[self save];
	}
}

//if currentTrack is set, return that, else set the first track as the currentTrack and return
- (Track *)currentOrFirstTrack {
	if (self.currentTrack) {
		//self.currentTrack could be a CoreData relationship that's no longer valid (if referenced track was deleted).
		//If it's valid, set the currentTrackIndex and return, else control will pass to next if block to fetch first track.
		if (!hasSetInitialTrackIdx && [[self orderedTracks] containsObject:self.currentTrack] == YES) {
			currentTrackIdx = [[self orderedTracks] indexOfObject:self.currentTrack];
			return self.currentTrack;
		}
	} 
	
	if (self.tracks && [self.tracks count] > 0) {		
		currentTrackIdx = 0;
		self.currentTrack = [[self orderedTracks] objectAtIndex:currentTrackIdx];
		[self save];
	}
	
	DLog(@"current is %@",self.currentTrack.title);
	return self.currentTrack;
}

- (Track *)incrementCurrentTrack {
	if (!self.currentTrack) return nil;
	
	if (currentTrackIdx < [[self orderedTracks] count] - 1) {
		currentTrackIdx++;
		self.currentTrack = [[self orderedTracks] objectAtIndex:currentTrackIdx];
		[self save];
	}
	
	return self.currentTrack;
}

- (Track *)decrementCurrentTrack {
	if (!self.currentTrack) return nil;
	
	if (currentTrackIdx > 0) {
		currentTrackIdx--;
		self.currentTrack = [[self orderedTracks] objectAtIndex:currentTrackIdx];
		[self save];
	}
	
	return self.currentTrack;
}

//this is only called by MasterMusicPlayer
- (void)chooseCurrentTrack:(Track *)track {
	int trackIdx = 0;
	for (Track *t in [self orderedTracks]) {		
		if (t == track) {
			self.currentTrack = t;
			currentTrackIdx = trackIdx;
			DLog(@"currentTrack is %@",t.title);
			break;
		}
		
		trackIdx++;
	}	

	[self save];
}

//return an image of the artwork sized as needed
- (UIImage *)artworkAtSize:(CGSize)size {
	
	Track *track = (self.currentTrack ? self.currentTrack : [self.tracks anyObject]);
	MPMediaItem *item = track.mediaItem;
	
	//first see if it's cached locally...
	NSString *tmpImgPath = [NSString stringWithFormat:@"%@/%@_%d%d.png",NSTemporaryDirectory(),track.persistentId,size.height,size.width];
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
		if (self.categoryRaw == LibraryCategoryBooks) {
			artwork = [UIImage imageNamed:@"old_book.png"];
		} else if (self.categoryRaw == LibraryCategoryPodcasts) {
			artwork = [UIImage imageNamed:@"rss_300.png"];
		} else {
			artwork = [UIImage imageNamed:@"old_book.png"];
		}
	}
	
	return artwork;
}

//count of all present tracks
- (int)trackCount {
	return [[self orderedTracks] count];
}

//count of tracks considered new
- (int)newTrackCount {
	int i = 0;
	for (Track *t in [self orderedTracks]) {
		if ([t isNew]) i++;
	}
	return i;
}

//update the following persistent attributes:
//1. track: all metadata attributes
//2. work: percentComplete
- (void)updateMetadata {
	@synchronized(self) {		
		@try {
			
			[self.currentTrack updateMetadata];	
			
			//update when works were listened to
			self.lastListenedTo = [NSDate date];
			
			//self's percentComplete is calculated as the sum the maxTime of all tracks
			//up to the currentTrack plus the currentTrack up to lastTime / 
			//the sum of all maxTimes
			long long timesUpToCurrent = 0;
			long long currentTrackTime = 0;
			long long timesFromCurrentToLast = 0;
			
			BOOL beforeCurrent = YES;
			for (Track *t in [self orderedTracks]) {
				if (t == self.currentTrack) {
					currentTrackTime = [t.lastTime longLongValue];
					timesFromCurrentToLast += [t.totalTime longLongValue];
					beforeCurrent = NO;
				} else if (beforeCurrent == YES) {
					timesUpToCurrent += [t.totalTime longLongValue];
				} else {
					timesFromCurrentToLast += [t.totalTime longLongValue];
				}
			}
			
			long long timeCompleted = timesUpToCurrent + currentTrackTime;
			long long totalTime = timesUpToCurrent + timesFromCurrentToLast;
			
			if (totalTime > 0) {
				NSNumber *p = [NSNumber numberWithFloat:((float) timeCompleted / (float) totalTime)];
				self.percentComplete = p;
			} 
			
			[self save];			
		}
		
		@catch (NSException * e) {
			DLog(@"%@",[e reason]);			
		}
		@finally {			
		}		
		
	}//end synchronized
}

//This is called from the player when playback changes without user input (i.e., when automatically
//playing from one track to the next in the queue).  It will loop through tracks and save a reference 
//to the track with a matching persistentId
- (void)updateMetadataForTrackWithID:(uint64_t)targetId {
	
	int trackIdx = 0;
	BOOL found = NO;
	
	for (Track *t in [self orderedTracks]) {
		
		//note: doing NSNumber == or even [NSNumber isEqualToNumber...] didn't work consistently so
		//am using non-object type of persistentId which is unsigned long long
		uint64_t curPid = [t.persistentId unsignedLongLongValue];
		//DLog(@"curPId: %llu, targetPid: %llu",curPid,targetId);
		if (curPid == targetId) {
			self.currentTrack = t;
			currentTrackIdx = trackIdx;	
			[self updateMetadata];
			found = YES;
			break;
		}
		trackIdx++;
	}
	
	//TODO: remove found after testing is done and assured logic is working correctly
	if (!found) {
		DLog(@"Error finding current track for track with pId: %llu",targetId);
	} 	
}

//set currentTrack to first track and for each track,
//reset lastTime and maxTime to 0
- (void)resetAsNew {
	self.currentTrack = [[self orderedTracks] objectAtIndex:0];
	
	for (Track *t in [self orderedTracks]) {
		[t updateAsNew];
	}
	
	self.percentComplete = [NSNumber numberWithFloat:0.0];
	
	[self save];
}

//set currentTrack to first track and for each track,
//set lastTime to totalTime.  
//Also set percentComplete to 0
- (void)setAsCompleted {	
	self.currentTrack = [[self orderedTracks] objectAtIndex:0];
	
	for (Track *t in [self orderedTracks]) {
		[t updateAsComplete];
	}
	
	self.percentComplete = [NSNumber numberWithFloat:1.0];
	
	[self save];
}

//format content and child object content for email
- (NSString *)formatForEmail {
	NSMutableString *s = [[[NSMutableString alloc] init] autorelease];
	[s appendString:[NSString stringWithFormat:@"%@\n\n", self.title]];
	
	if (self.notes && [self.notes length] > 0) {
		[s appendString:[NSString stringWithFormat:@"Notes: %@\n\n", self.notes]];
	}

	for (Track *t in [self orderedTracks]) {
		[s appendString:[t formatForEmail]];		
	}
	
	return s;
}


@end
