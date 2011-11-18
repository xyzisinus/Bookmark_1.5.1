//
//  BookCellController.h
//  AudiobooksPlus
//
//  Created by Barry Ezell on 5/27/09.
//  Copyright 2009 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPMediaItem+Track.h"
#import "MPMediaItemCollection+Work.h"
#import "MasterMusicPlayer.h"
#import "SSPieProgressView.h"


@interface WorkCell : UITableViewCell {	    	
	int height;
}

@property (nonatomic, retain) IBOutlet UIImageView          *bookImageView;
@property (nonatomic, retain) IBOutlet UILabel              *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel              *secondaryLabel;
@property (nonatomic, retain) IBOutlet SSPieProgressView    *progressPie;

- (void)arrangeForCategory:(LibraryCategory)category;
- (void)setCollection:(MPMediaItemCollection *)collection;

@end
