//
//  WorkDetailCellView.h
//  Bookmark
//
//  Created by Barry Ezell on 3/6/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSPieProgressView.h"

@interface WorkDetailCell : UITableViewCell {
	
}

@property (nonatomic, retain) IBOutlet UILabel              *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel              *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel              *dateLabel;
@property (nonatomic, retain) IBOutlet SSPieProgressView    *progressPie;

@end
