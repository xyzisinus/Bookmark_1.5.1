//
//  BookCellController.m
//  AudiobooksPlus
//
//  Created by Barry Ezell on 5/27/09.
//  Copyright 2009 Dockmarket LLC. All rights reserved.
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
