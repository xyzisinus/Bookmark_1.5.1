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
//  Bookmark.m
//  Bookmark
//
//  Created by Barry Ezell on 1/14/10.
//

#import "MasterMusicPlayer.h"
#import "Bookmark.h"
#import "CoreDataUtility.h"
#import "DMTimeUtils.h"

@implementation Bookmark 

@synthesize itemIdx;

@dynamic startTime;
@dynamic title;
@dynamic notes;
@dynamic stopTime;
@dynamic kind;
@dynamic track;

+ (Bookmark *)createBookmarkForStartTime:(long)seconds isQuickBookmark:(BOOL)quick {			
	NSManagedObjectContext *context = [[CoreDataUtility sharedUtility] managedObjectContext];
    
    MPMediaItemCollection *col = [[MasterMusicPlayer instance] currentCollection];
    Work *work = [col associatedWork:YES];
    [work saveState]; //creates track if needed and sets as "current"
    Track *track = work.currentTrack;

	Bookmark* bkmk = (Bookmark *) [NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" 
																inManagedObjectContext:context];
	bkmk.track = track;
    bkmk.startTime = [NSNumber numberWithLong:seconds];
        
    if (quick) {         
        [bkmk setDefaultTitle:col];
        [CoreDataUtility save];
    } else {
        bkmk.title = @"";
    }
	
    return bkmk;
}

- (void)setDefaultTitle:(MPMediaItemCollection *)col {
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if ([prefs valueForKey:@"bookmarkTitleOption"]) {
		int idx = [prefs integerForKey:@"bookmarkTitleOption"];
		
		if (idx == 1) {
			//Bookmark #x            
			int bkmkNum = [[col bookmarks] count]; //not incrementing because this bookmark already exists
			self.title = [NSString stringWithFormat:@"Bookmark #%i",bkmkNum];
			return;
			
		} else if (idx == 2) {
			//blank
			self.title = @"";
			return;
		}
	}
	
	//option index 0 is date stamp	
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4]; //means "set formatter behavior to 10.4+ behavior"
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSDate *date = [NSDate date];
	
	NSString *formattedDateString = [dateFormatter stringFromDate:date];
	self.title = formattedDateString;
	//NSLog(@"Formatted date string for locale %@: %@", [[dateFormatter locale] localeIdentifier], formattedDateString);
	[dateFormatter release];
}

- (NSString *)formatForEmail {
	NSMutableString *s = [[[NSMutableString alloc] init] autorelease];
	[s appendString:[NSString stringWithFormat:@"Bookmark: %@\n",self.title]];
	[s appendString:[NSString stringWithFormat:@"Start Time: %@\n",[DMTimeUtils formatSeconds:[self.startTime longValue]]]];
	if (self.notes && [self.notes length] > 0) {
		[s appendString:@"Notes: "];
		[s appendString:self.notes];
	}
	[s appendString:@"\n"];	
	return s;	
}

- (NSString *)description {
    return [NSString stringWithFormat:@"title: %@, track.id: %@, track.item.title: %@",
            self.title,
            self.track.persistentId,
            self.track.mediaItem.title];
}

#pragma mark -
#pragma mark NotesView methods

- (void)notesViewReturningWithNotes:(NSString *)notes {
	//NSLog(@"%@",notes);
}


@end
