//
//  BookmarksViewController.h
//  AudiobooksPlus
//
//  Created by Barry Ezell on 5/24/09.
//  Copyright 2009 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Work.h"
#import "Track.h"
#import "BookmarkCell.h"
#import "PlayerViewController.h"
#import "MasterMusicPlayer.h"

@interface BookmarksViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	Work            *work;
    int             lastSelectedIdx;
    BOOL            isPlaying;
}

@property (nonatomic, retain) IBOutlet UITableView          *tableView;
@property (nonatomic, retain) IBOutlet UIToolbar            *toolbar;
@property (nonatomic, retain) MasterMusicPlayer             *player;
@property (nonatomic, retain) UIImageView                   *selBackView;
@property (nonatomic, retain) NSArray                       *bookmarks;

- (IBAction)prevButtonWasPressed:(id)sender;
- (IBAction)playStopButtonWasPressed:(id)sender;
- (IBAction)nextButtonWasPressed:(id)sender;
- (BookmarkCell *)createNewBookmarkCellFromNib;
- (void)fetchBookmarks;
- (void)deleteBookmark:(Bookmark *)damned;
- (void)popEditController;
- (void)playCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)playbackStateChanged:(NSNotification *)notification;
- (void)updateToolbar;

@end
