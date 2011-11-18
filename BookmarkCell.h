//
//  BookmarkCellController.h
//  AudiobooksPlus
//
//  Created by Barry Ezell on 5/24/09.
//  Copyright 2009 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookmarkCell : UITableViewCell {
	IBOutlet UILabel *timeLabel;
	IBOutlet UILabel *titleLabel;
	IBOutlet UIImageView *playImageView;
}

@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *playImageView;

@end
