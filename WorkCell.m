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
//  BookCellController.m
//  AudiobooksPlus
//
//  Created by Barry Ezell on 5/27/09.
//

#import "WorkCell.h"

#define DATE_1970 [NSDate dateWithTimeIntervalSince1970:0]

@interface WorkCell (Private)
- (void)loadAlbumArtInBackgroundForCollection:(MPMediaItemCollection *)collection;
- (void)setImage:(UIImage *)image;
@end

@implementation WorkCell

@synthesize bookImageView, titleLabel, secondaryLabel, progressPie;

- (void)dealloc {
    [bookImageView release]; bookImageView = nil;
    [titleLabel release]; titleLabel = nil;
    [secondaryLabel release]; secondaryLabel = nil;
    [progressPie release]; progressPie = nil;
    [super dealloc];
}

- (void)arrangeForCategory:(LibraryCategory)category {
	//currently only handling alterations for podcasts...
	if (category == LibraryCategoryPodcasts) {
		[self setFrame:CGRectMake(0, 0, 320, 85)];
		[bookImageView setFrame:CGRectMake(8, 10, 68, 68)];
        progressPie.progress = 0.0;
	} 
    
    progressPie.pieBackgroundColor = [UIColor clearColor];
    progressPie.pieBorderColor = SECONDARY_TEXT_COLOR;
    progressPie.pieFillColor = SECONDARY_TEXT_COLOR;
    titleLabel.textColor = PRIMARY_TEXT_COLOR;
    secondaryLabel.textColor = SECONDARY_TEXT_COLOR;
}


- (int)height {
	return self.frame.size.height;
}

- (void)setCollection:(MPMediaItemCollection *)collection {
	
	titleLabel.text = [collection title];
    
	if ([collection isPodcast]) {
        secondaryLabel.text = @"";

        int count = [collection count];
        int newCount = [collection newCount];
        		
        progressPie.progress = (float) (count - newCount) / (float) count;
        
        NSDate *podcastDate = collection.mostRecentDate;
        if ([podcastDate compare:DATE_1970] == NSOrderedDescending) {
            secondaryLabel.text = [NSDateFormatter localizedStringFromDate:collection.mostRecentDate
                                                                 dateStyle:NSDateFormatterMediumStyle 
                                                                 timeStyle:NSDateFormatterNoStyle];
        }
         
	} else {
		secondaryLabel.text = [collection author];
		
		float perc = [collection percentComplete];
        if (perc > 0.0 && perc < 0.01) perc = 0.01;
		progressPie.progress = perc;
	}
	
	//load the album art in background to keep scrolling as smooth as possible
	[self performSelectorInBackground:@selector(loadAlbumArtInBackgroundForCollection:) withObject:collection];
}

- (void)loadAlbumArtInBackgroundForCollection:(MPMediaItemCollection *)collection {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	UIImage *img = [collection artworkAtSize:CGSizeMake(68,68)];
	[bookImageView setImage:img];	
	[pool release];
}

- (void)setImage:(UIImage *)image {
     
 }


@end
