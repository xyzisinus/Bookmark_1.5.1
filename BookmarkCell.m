//
//  BookmarkCellController.m
//  AudiobooksPlus
//
//  Created by Barry Ezell on 5/24/09.
//  Copyright 2009 Dockmarket LLC. All rights reserved.
//

#import "BookmarkCell.h"

@implementation BookmarkCell

@synthesize timeLabel, titleLabel, playImageView;

- (void)dealloc {
	[timeLabel release];
	[titleLabel release];
	[playImageView release];	
		
    [super dealloc];
}


@end
