//
//  WorkDetailViewController.h
//  Bookmark
//
//  Created by Barry Ezell on 2/13/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPMediaItemCollection+Work.h"
#import "WorkDetailCell.h"

@interface WorkDetailsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	IBOutlet UITableView *tableView;		
	IBOutlet UILabel *workTitleLabel;
	IBOutlet UILabel *trackCountLabel;
	IBOutlet UILabel *authorLabel;
	IBOutlet UIToolbar *toolbar;
		
	UIView *selBackView;
	BOOL initialLoad;
}

@property (nonatomic, retain) MPMediaItemCollection     *collection;
@property (nonatomic, retain) UIView                    *selBackView;

- (void)markAllAsNewWasPressed;
- (WorkDetailCell *) createNewWorkDetailCellFromNib;

@end
