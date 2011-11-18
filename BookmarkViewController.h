//
//  BookmarkViewController.h
//  Bookmark
//
//  Created by Barry Ezell on 10/5/11.
//  Copyright (c) 2011 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bookmark.h"
#import "NotesViewController.h"
#import "TimeEditTableViewController.h"
#import "EditableTableViewCell.h"
#import "EditableTableViewCellDelegate.h"

@interface BookmarkViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EditableTableViewCellDelegate, NotesViewDelegate, UIActionSheetDelegate> {
    EditableTableViewCell       *editingTableViewCell;
    BOOL                        willReturnFromTimeEdit;
    BOOL                        isPlaying;
}

@property (nonatomic, retain) IBOutlet UITableView      *tableView;
@property (nonatomic, retain) IBOutlet UIToolbar        *toolbar;
@property (nonatomic, retain) Bookmark                  *bookmark;
@property (nonatomic, retain) NSIndexPath               *curIdxPath;
@property (nonatomic, retain) UIView                    *notesHeaderView;
@property (nonatomic, assign) BOOL                      isNew;

- (IBAction)playStopButtonWasPressed:(id)sender;
- (IBAction)actionButtonWasPressed:(id)sender;
- (IBAction)trashButtonWasPressed:(id)sender;
- (void)updateToolbar;
- (void)deleteBookmark;
- (void)shareViaNativeTwitter:(NSString *)text;
- (BOOL)reachable:(NSString *)hostName;

@end
