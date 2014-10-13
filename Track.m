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
