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
//  Track.m
//  Bookmark
//
//  Created by Barry Ezell on 1/14/10.
//

#import "Track.h"
#import "MasterMusicPlayer.h"
#import "Work.h"
#import "CoreDataUtility.h"

@implementation Track 

@dynamic maxTime;
@dynamic persistentId;
@dynamic title;
@dynamic lastTime;
@dynamic totalTime;
@dynamic work;
@dynamic bookmarks;
@dynamic present;
@dynamic trackNumber;
@dynamic diskNumber;

@synthesize mediaItem;

+ (Track *)trackForMediaItem:(MPMediaItem *)mediaItem andCategory:(LibraryCategory)category {
	NSString *title = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
	NSNumber *pId = (NSNumber *) [mediaItem valueForProperty:MPMediaItemPropertyPersistentID];
	
	//either fetch a track by this persistentId or create one for it
    NSManagedObjectContext *context = [[CoreDataUtility sharedUtility] managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Track" inManagedObjectContext:context]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"persistentId == %@",pId];
	[fetchRequest setPredicate:predicate];
		
	Track *track = nil;
	NSError *error = nil;
	NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
	
	if (array == nil || [array count] == 0) {
		track = (Track *) [NSEntityDescription insertNewObjectForEntityForName:@"Track" 
														inManagedObjectContext:context];
		track.persistentId = pId;
		track.title = title;
		track.totalTime = (NSNumber *) [mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
		
		//Note: the diskNum test was added because Apple changed the SDK in 4.2.1 to return null if disk number
		//isn't set, instead of 0 as before 4.2.1
		NSString *trackNumStr = [mediaItem valueForProperty:MPMediaItemPropertyAlbumTrackNumber];
		track.trackNumber = (trackNumStr ? (NSNumber *)trackNumStr : [NSNumber numberWithInt:1]);
		NSString *diskNumStr = [mediaItem valueForProperty:MPMediaItemPropertyDiscNumber];        		
		track.diskNumber = (NSNumber *) (diskNumStr ? (NSNumber *)diskNumStr : [NSNumber numberWithInt:0]);
		//NSLog(@"diskNumStr for %@ is %@, trackNumber is %@",title,diskNumStr,trackNumStr);
		
	} else {
		track = [array objectAtIndex:0];
	}
	
	[fetchRequest release];
	
	//get the work associated with this track (will be created if doesn't yet exist)
	NSString *albumAuthor = [mediaItem valueForProperty:MPMediaItemPropertyAlbumArtist];
	NSString *itemAuthor = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
	NSString *author = (albumAuthor ? albumAuthor : itemAuthor);
	//NSLog(@"albumAuthor = %@, itemAuthor=%@",albumAuthor,itemAuthor);
	
	NSString *albumTitle;
	if (category == LibraryCategoryPodcasts) albumTitle = [mediaItem valueForProperty:MPMediaItemPropertyPodcastTitle];
	else albumTitle = [mediaItem valueForProperty:MPMediaItemPropertyAlbumTitle];
	
	//handle the case where a track doesn't have an album name
	if (albumTitle == nil || [albumTitle length] == 0) {
		albumTitle = title;
	}
	
	Work *work = [Work workForTitle:albumTitle andAuthor:author andCategory:category inContext:context];
	
	if (!track.work || track.work != work) {
		[work addTracksObject:track];
	}
		
	//transient properties set for each run should go here
	track.mediaItem = mediaItem;
	
	//set new for each query
	track.present = [NSNumber numberWithBool:YES];
	
	return track;	
}

//this is currently only used by UpgradeController
+ (Track *)trackForTitle:(NSString *)title 
			   andAuthor:(NSString *)author {
	
    NSManagedObjectContext *context = [[CoreDataUtility sharedUtility] managedObjectContext];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Track" inManagedObjectContext:context]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@ and work.author == %@",title,author];
	[fetchRequest setPredicate:predicate];
	
	Track *track = nil;
	NSError *error = nil;
	NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
	if (array && [array count] > 0) {
		return (Track *) [array objectAtIndex:0];
	}
		
	return track;
}

- (float)percentComplete {
	if (self.totalTime > 0) {
		return ((float) [self.lastTime longValue] / (float) [self.totalTime longValue]);
	} else return 0.0;
}

//return YES if less than 1% complete
- (BOOL)isNew {
	if ([self percentComplete] <= 0.01) return YES;
	return NO;
}

//return YES if less than 5 seconds left
- (BOOL)isComplete {
	if ([self.totalTime longValue] - [self.lastTime longValue] < 5) return YES;
	return NO;
}

//update these persistent fields:
//1. lastTime
//2. maxTime
//save is called in [work updateMetadata]
- (void)updateMetadata {
	MasterMusicPlayer *mmp = [MasterMusicPlayer instance];	
    if (![mmp shouldRecordLatestTime]) return;

	long playerCurTime = [mmp currentPlaybackTime];
	
	if (playerCurTime > 0.0) {
		self.lastTime = [NSNumber numberWithLongLong:playerCurTime];	
		if (self.lastTime > self.maxTime) self.maxTime = self.lastTime;	
	}
}

//calling object must call save
- (void)updateAsNew {
	self.maxTime = [NSNumber numberWithInt:0];
	self.lastTime = [NSNumber numberWithInt:0];	
}

//calling object must call save
- (void)updateAsComplete {
	DLog(@"update as complete");
	self.maxTime = [NSNumber numberWithInt:0];	 	
	self.lastTime = self.totalTime;	
}

- (void)resetMaxTime {
	self.maxTime = [NSNumber numberWithInt:0];
}

//when a Track is faulted, it will lose its associated mediaItem. Either return that if present,
//or fetch from MPMusicPlayer if nil
- (MPMediaItem *)mediaItem {
	if (mediaItem) return mediaItem;
	else {
		MasterMusicPlayer *mmp = [MasterMusicPlayer instance];
		return [mmp mediaItemForPersistentId:self.persistentId];
	}
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
	[s appendString:[NSString stringWithFormat:@"Track: %@\n", self.title]];
	
	for (Bookmark *b in [self orderedBookmarks]) {
		[s appendString:[b formatForEmail]];
	}
	
	[s appendString:@"\n"];	
	return s;	
}

- (void)dealloc {
	[mediaItem release];
	[super dealloc];	
}


@end
