//
//  LibraryViewController.h
//  Bookmark
//
//  Created by Barry Ezell on 1/13/10.
//  Copyright Dockmarket LLC 2010. All rights reserved.
//
#import "MPMediaItemCollection+Work.h"
#import "MPMediaItem+Track.h"
#import "WorkCell.h"
#import "MasterMusicPlayer.h"
#import "PlayerViewController.h"
#import "AdBannerViewController.h"

@interface LibraryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate> {
	IBOutlet UITableView                *tableView;
	IBOutlet UITabBar                   *tabBar;
	IBOutlet UIActivityIndicatorView    *loadingSpinner;
	
	UIView                              *headerView;	
	UIButton                            *titleButton;
	UIButton                            *authorButton;
	UIButton                            *recentButton;
	UIBarButtonItem                     *playingButtonItem;
		
	LibraryCategory                     currentCategory;
	LibrarySortOrder                    currentSortOrder;
	MasterMusicPlayer                   *player;
	BOOL                                inCategoryLoad;
    BOOL                                handledPlaybackInViewDidLoad;
}

@property (nonatomic, retain) UIView                    *selBackView;
@property (nonatomic, retain) UIView                    *selBackView2;
@property (nonatomic, retain) NSArray                   *collections;
@property (nonatomic, retain) UITableView               *tableView;
@property (nonatomic, retain) UITabBar                  *tabBar;
@property (nonatomic, retain) UIActivityIndicatorView   *loadingSpinner;
@property (nonatomic, assign) LibraryCategory           currentCategory;
@property (nonatomic, assign) LibrarySortOrder          currentSortOrder;
@property (nonatomic, retain) UIView                    *headerView;
@property (nonatomic, retain) UIButton                  *titleButton;
@property (nonatomic, retain) UIButton                  *authorButton;
@property (nonatomic, retain) UIButton                  *recentButton;
@property (nonatomic, retain) UIBarButtonItem           *playingButtonItem;
@property (nonatomic, retain) MasterMusicPlayer         *player;

- (void)beginCategoryLoad;
- (void)fetchWorksFromMusicLibrary;
- (void)endCategoryLoad:(NSArray *)collections;
- (WorkCell *) createNewBookCellFromNib;
- (void)setCategory:(NSNumber *)categoryNumber;
- (void)setSortOrder:(LibrarySortOrder)order;
- (void)sortOrderButtonWasPressed:(id)button;
- (IBAction)settingsButtonWasPressed;
- (void)showSettingsWithAutotutorial:(BOOL)showTutorial;
- (void)nowPlayingButtonWasPressed;
- (void)pushPlayerView:(BOOL)animated;
- (void)setupLiteVersionUI;

@end
