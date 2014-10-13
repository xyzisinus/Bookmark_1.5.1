// Copyright Barry Ezell. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
//  1. Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in the
//     documentation and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of its contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  LibraryViewController.h
//  Bookmark
//
//  Created by Barry Ezell on 1/13/10.
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
    BOOL                                waitingItemChange;
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
- (void)nowPlayingItemChanged:(NSNotification *)notification;
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
