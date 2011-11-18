//
//  WorkDetailCellView.m
//  Bookmark
//
//  Created by Barry Ezell on 3/6/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import "WorkDetailCell.h"


@implementation WorkDetailCell

@synthesize titleLabel, timeLabel, dateLabel, progressPie;

- (void)dealloc {
	[titleLabel release]; titleLabel = nil;
	[timeLabel release]; timeLabel = nil;
    [dateLabel release]; dateLabel = nil;
	[progressPie release]; progressPie = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
