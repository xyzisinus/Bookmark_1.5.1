//
//  LibraryViewController.m
//  Bookmark
//
//  Created by Barry Ezell on 1/13/10.
//  Copyright Dockmarket LLC 2010. All rights reserved.
//

#import "LibraryViewController.h"
#import "WorkDetailsViewController.h"
#import "SettingsViewController.h"
#import "IFPreferencesModel.h"
#import "BookmarkAppDelegate.h"

#define TITLE_FONT [UIFont fontWithName:@"TrebuchetMS-Bold" size:16.0]
#define BAR_BUTTON_FONT [UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0]
#define SORT_SELECT_COLOR [UIColor colorWithRed:1.0 green:0.855 blue:0.524 alpha:1.0]

@implementation LibraryViewController

@synthesize collections;
@synthesize tableView, tabBar;
@synthesize headerView, loadingSpinner;
@synthesize currentSortOrder, currentCategory;
@synthesize titleButton, authorButton, recentButton;
@synthesize selBackView, selBackView2, playingButtonItem;
@synthesize player;

static BOOL showedNoMediaMsg = NO;

- (void)dealloc {	
    [collections release];
	[tableView release];
	[tabBar release];	
	[loadingSpinner release];
	[headerView release];
 	
	[titleButton release];
	[authorButton release];
	[recentButton release];
	
	[selBackView release];
	[selBackView2 release];
	//[playingButtonItem release];
	[player release];	
		
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	//table view background
	//self.tableView.backgroundColor = BACKGROUND_COLOR;    
    UIImageView *imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark_leather_2.png"]] autorelease];
    [self.view addSubview:imgView];
    [self.view sendSubviewToBack:imgView]; 
	
	//settings button and possibly refresh
	UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:@selector(settingsButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	infoButton.frame = CGRectMake(0, 0, 50, 50);
    infoButton.accessibilityLabel = @"Settings";
	[leftView addSubview:infoButton];
		
	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:leftView]; 
	self.navigationItem.leftBarButtonItem = buttonItem;
	[buttonItem release];
	[leftView release];
    
	//now playing button
    self.playingButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Playing" 
																		  style:UIBarButtonItemStyleBordered 
																		 target:self 
																		 action:@selector(nowPlayingButtonWasPressed)] autorelease];
	self.navigationItem.rightBarButtonItem = playingButtonItem;
	
	//back button for child views
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Library" 
																   style:UIBarButtonItemStyleBordered 
																  target:nil 
																  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release]; 
	
	//create the sort view just below the nav bar
	//HSV color 0,78,24

	UIColor *color = [UIColor colorWithHue:0.0 saturation:0.306 brightness:0.094 alpha:0.8];
	UIView *sortView = [[UIView alloc] initWithFrame:CGRectMake(0,35,320,43)];
	[sortView setBackgroundColor:color];
	[self.view addSubview:sortView];
	[sortView release];
	
	//add buttons to the bar
	self.titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[titleButton setTitle:@"Title" forState:UIControlStateNormal];
	[titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[titleButton.titleLabel setFont:BAR_BUTTON_FONT];
	[titleButton setFrame:CGRectMake(10,11,90,27)];
	[titleButton addTarget:self action:@selector(sortOrderButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[sortView addSubview:titleButton];
	
	self.authorButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[authorButton setTitle:@"Author" forState:UIControlStateNormal];
	[authorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[authorButton.titleLabel setFont:BAR_BUTTON_FONT];
	[authorButton setFrame:CGRectMake(115,11,90,27)];
	[authorButton addTarget:self action:@selector(sortOrderButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[sortView addSubview:authorButton];
	
	self.recentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[recentButton setTitle:@"Recent" forState:UIControlStateNormal];
	[recentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[recentButton.titleLabel setFont:BAR_BUTTON_FONT];
	[recentButton setFrame:CGRectMake(230,11,90,27)];
	[recentButton addTarget:self action:@selector(sortOrderButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	[sortView addSubview:recentButton];
	
	//get the category and sort order from prefs
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if ([prefs valueForKey:@"currentCategory"]) currentCategory = [prefs integerForKey:@"currentCategory"];
	else currentCategory = LibraryCategoryBooks;	
	
	//set the tab selected item to the correct category
	switch (currentCategory) {
		case LibraryCategoryBooks:
			[tabBar setSelectedItem:[[tabBar items] objectAtIndex:0]];
			break;
		case LibraryCategoryPodcasts:
			[tabBar setSelectedItem:[[tabBar items] objectAtIndex:1]];
			break;
		case LibraryCategoryPlaylist:
			[tabBar setSelectedItem:[[tabBar items] objectAtIndex:2]];
			break;
        default:
            break;
	}
	
	if ([prefs valueForKey:@"currentSortOrder"]) currentSortOrder = [prefs integerForKey:@"currentSortOrder"];
	else currentSortOrder = LibrarySortOrderTitle;
	
	//hide the author sort button on Podcasts where it's irrelevant
	if (currentCategory == LibraryCategoryPodcasts) [authorButton setHidden:YES];
	
	switch (currentSortOrder) {
		case LibrarySortOrderTitle:
			[titleButton setTitleColor:SORT_SELECT_COLOR forState:UIControlStateNormal];
			[titleButton.titleLabel setFont:TITLE_FONT];
			break;
		case LibrarySortOrderAuthor:
			[authorButton setTitleColor:SORT_SELECT_COLOR forState:UIControlStateNormal];
			[authorButton.titleLabel setFont:TITLE_FONT];
			break;
		case LibrarySortOrderRecent:
			[recentButton setTitleColor:SORT_SELECT_COLOR forState:UIControlStateNormal];
			[recentButton.titleLabel setFont:TITLE_FONT];
			break;
		default:
			break;
	}
	
	//image view for selected rows (LibraryVC and WorkDetailVC differ in placement of spinner)
	self.selBackView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 95)] autorelease];
	self.selBackView2 = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 95)] autorelease];
	
	UIImageView *selBaseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_95_highlight.png"]];	
	[self.selBackView addSubview:selBaseView];
	
	UIImageView *selBaseView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_85_highlight.png"]];
	[self.selBackView2 addSubview:selBaseView2];
	
	UIActivityIndicatorView *selSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(291, 12, 15, 15)];
	selSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
	[selSpinner startAnimating];	
	[self.selBackView addSubview:selSpinner];
	
	UIActivityIndicatorView *selSpinner2 = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(291, 36, 20, 20)];
	selSpinner2.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
	[selSpinner2 startAnimating];	
	[self.selBackView2 addSubview:selSpinner2];
	
	[selBaseView release];
	[selBaseView2 release];
	[selSpinner release];
	[selSpinner2 release];
	
#ifdef PODCASTS_LITE
	[self setupLiteVersionUI];
#endif
		
	self.player = [MasterMusicPlayer instance];
	
	// Startup logic:
	// 1. if a track is playing currently and it's a supported media type, show it now 
	//   (if not, stop playback and go to 3)
	// 2. if a last played book is present, play that
	// 3. load books list (in viewDidAppear)
	
	handledPlaybackInViewDidLoad = NO;
	
	if ([player isPlaying] == YES) {	
		if ([player attemptCurrentWorkAssignmentForPlayingItem] == YES) {							
			handledPlaybackInViewDidLoad = YES;
            DLog(@"playing item already playing at launch");
            [self pushPlayerView:NO];
		} else {
			//end playback of nonsupported track
			[player togglePlayPause];
		}
	} else if ([prefs valueForKey:@"endedInPlayer"] && 
			   [prefs boolForKey:@"endedInPlayer"] == YES && 
			   [prefs valueForKey:@"autoplay"] && 
			   [prefs integerForKey:@"autoplay"] == 1 &&
			   [player attemptPlaybackOfLastPlayedItem]) {
		
		handledPlaybackInViewDidLoad = YES;
        DLog(@"playing last item");
       	[self pushPlayerView:NO];
	} 
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];	
        
	//load table data	
	if (!handledPlaybackInViewDidLoad) {
		[self beginCategoryLoad];
	}
	
	if ([player isPlaying]) {
		[playingButtonItem setTitle:@"Playing"];
	} else {
		[playingButtonItem setTitle:@"Last Played"];		
	}
	
	//Reload the library for this category if either of these situations occured:
	//1.  the app started playing back a book (meaning PlayerViewController was visible before the library)
	//2.  the library has been modified via an iTunes sync or over-the-air download
	//[self beginCategoryLoad];
	
	//note: upgrade check will occur in endCategoryLoad
}

- (void)viewDidDisappear:(BOOL)animated {
	[player clearMediaItemCache];
}

#pragma mark -
#pragma mark Lite setup with AdMob delegate methods

- (void)setupLiteVersionUI {
#if defined(PODCASTS_LITE)	
	[tabBar setItems:[NSArray array]];
	
	AdBannerViewController *adVC = [[AdBannerViewController alloc] initWithNibName:@"AdViewController" bundle:nil];
	adVC.view.frame = CGRectMake(0, 411, 320, 49);
	[self.view addSubview:adVC.view];
#endif
}

#pragma mark -
#pragma mark Category loading

//A category has been selected. If this category hasn't yet been loaded, start that 
//process in the background then call endCategoryLoad which will request CoreData
//to load the table.
- (void)beginCategoryLoad {
	[self.view bringSubviewToFront:loadingSpinner];
	[loadingSpinner startAnimating];		
	inCategoryLoad = YES;
	
    [self performSelector:@selector(fetchWorksFromMusicLibrary) 
               withObject:nil 
               afterDelay:0.1];
}

// Get an array of MPMediaItemCollections from Work
- (void)fetchWorksFromMusicLibrary {
    //NSDate *startDate = [NSDate date];
	
    [self endCategoryLoad:[MPMediaItemCollection collectionsForCategory:currentCategory 
                                                               withSort:currentSortOrder]
     ];

    /*
    NSTimeInterval interval = [startDate timeIntervalSinceNow];
    NSString *msg = [NSString stringWithFormat:@"Time: %f",interval];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Benchmark" 
                                                    message:msg 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
    [alert show];
     */    
}

- (void)endCategoryLoad:(NSArray *)coll {
    
    if (coll != nil) self.collections = coll;
    
	inCategoryLoad = NO;
	[tableView reloadData];	
	[loadingSpinner stopAnimating];
	
	// Raise message if no objects found
	if ([collections count] == 0 && showedNoMediaMsg == NO) {
		NSString *msg = nil;
		NSString *title = nil;
		if (currentCategory == LibraryCategoryBooks) {
			title = @"No books found";
			msg = @"Click View Tutorial to learn how to add audiobooks to Bookmark.";
		} else {
			title = @"No podcasts found";
			msg = @"Click View Tutorial to learn how to add podcasts to Bookmark.";			
		}
		
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"View Tutorial",@"Close",nil] autorelease];
		[alert show];
        showedNoMediaMsg = YES;
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self showSettingsWithAutotutorial:YES];
	} 
}

#pragma mark -
#pragma mark TabBarDelegate, category, sort methods

- (void)tabBar:(UITabBar *)tb didSelectItem:(UITabBarItem *)item {
	int idx = [[tabBar items] indexOfObject:item];
	switch (idx) {
		case 0:
			[self setCategory:[NSNumber numberWithInt:0]];
			[authorButton setHidden:NO];
			break;
		case 1:			
			[self setCategory:[NSNumber numberWithInt:1]];
			//[self setCategory:LibraryCategoryPodcasts];
			[authorButton setHidden:YES];
			break;
		case 2:
			[self setCategory:[NSNumber numberWithInt:2]];
			//[self setCategory:LibraryCategoryPlaylist];
			[authorButton setHidden:YES];
			break;
	}
}

//This method will be called when user has tapped a new category tab. 
//TODO: switch back from NSNumber to enum for LibraryCategory
- (void)setCategory:(NSNumber *)categoryNumber {		
	self.currentCategory = [categoryNumber intValue];	
	[[NSUserDefaults standardUserDefaults] setInteger:self.currentCategory forKey:@"currentCategory"];	
	[self beginCategoryLoad];	
}

- (void)sortOrderButtonWasPressed:(id)button {
	[titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[titleButton.titleLabel setFont:TITLE_FONT];
	[authorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[authorButton.titleLabel setFont:TITLE_FONT];
	[recentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[recentButton.titleLabel setFont:TITLE_FONT];
	
	if (button == titleButton) {
		[titleButton setTitleColor:SORT_SELECT_COLOR forState:UIControlStateNormal];
		[titleButton.titleLabel setFont:TITLE_FONT];
		[self setSortOrder:0];
	} else if (button == authorButton) {
		[authorButton setTitleColor:SORT_SELECT_COLOR forState:UIControlStateNormal];
		[authorButton.titleLabel setFont:TITLE_FONT];
		[self setSortOrder:1];
	} else if (button == recentButton) {
		[recentButton setTitleColor:SORT_SELECT_COLOR forState:UIControlStateNormal];
		[recentButton.titleLabel setFont:TITLE_FONT];
		[self setSortOrder:2];
	}
}

- (void)setSortOrder:(LibrarySortOrder)order {
	self.currentSortOrder = order;	
	[[NSUserDefaults standardUserDefaults] setInteger:order forKey:@"currentSortOrder"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self beginCategoryLoad];
}

#pragma mark -
#pragma mark Settings

- (IBAction)settingsButtonWasPressed {
	[self showSettingsWithAutotutorial:NO];
}

- (void)showSettingsWithAutotutorial:(BOOL)showTutorial {		
	SettingsViewController *viewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];	
	viewController.model = [DMUserDefaults sharedInstance];
	viewController.navigationItem.title = @"Info & Settings";
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];	
}

- (void)nowPlayingButtonWasPressed {
	if ([player isPlaying] == YES) {
        [self pushPlayerView:YES];
	} else {
		if ([player attemptPlaybackOfLastPlayedItem]) {
            [self pushPlayerView:YES];
		} else {
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Track Not Found" 
															 message:@"The track may have been unsynced from this device.  Please choose another track or restart Bookmark if you believe this is in error." 
															delegate:nil 
												   cancelButtonTitle:@"Close" 
												   otherButtonTitles:nil] autorelease];
			[alert show];
		}
	}
}


#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [collections count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"WorkCell";
    
    WorkCell *cell = (WorkCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [self createNewBookCellFromNib];
		
		//set selected image view to use as the background (setting selected img in xib not working)
		[cell setSelectedBackgroundView:selBackView];
	}
    
    // Get the collection for this cell
    MPMediaItemCollection *coll = [collections objectAtIndex:indexPath.row];
    [cell setCollection:coll];
		 
    return cell;
}

- (WorkCell *) createNewBookCellFromNib {
	NSArray* nibContents = [[NSBundle mainBundle] loadNibNamed:@"WorkCell" owner:self options:nil];
	NSEnumerator* nibEnumerator = [nibContents objectEnumerator];
	WorkCell* workCell = nil;
	NSObject* nibItem = nil;
	while((nibItem = [nibEnumerator nextObject]) != nil) {
		if ([nibItem isKindOfClass: [WorkCell class]]) {
			workCell = (WorkCell *) nibItem;
			[workCell arrangeForCategory:currentCategory];
		}
	}
	return workCell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MPMediaItemCollection *coll = [collections objectAtIndex:indexPath.row];	    
    [player setCollectionForColdPlayback:coll];
	[self pushPlayerView:YES];
}

- (void)pushPlayerView:(BOOL)animated {
	PlayerViewController *pvc = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
    pvc.currentCategory = currentCategory;
        
    // De-select the selected row (if any) so activity indicator
    // stops spinning.
    NSIndexPath* selection = [self.tableView indexPathForSelectedRow];
    if (selection) [self.tableView deselectRowAtIndexPath:selection animated:NO];
    
	[self.navigationController pushViewController:pvc animated:animated];
	[pvc release];
    
    // Reset so tracks would be presented on a second viewDidAppear regardless
    // of first action
    handledPlaybackInViewDidLoad = NO;
}

//load the WorkDetailView when accessory disclosure indicator is tapped
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    MPMediaItemCollection *coll = [collections objectAtIndex:indexPath.row];
	
    WorkDetailsViewController *wdvc = [[WorkDetailsViewController alloc] initWithNibName:@"WorkDetailsViewController" bundle:nil];
	wdvc.collection = coll;
	wdvc.selBackView = self.selBackView2;
	[self.navigationController pushViewController:wdvc animated:YES];
	[wdvc release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	//if (currentCategory == LibraryCategoryPodcasts) return 85;
	//else return 95;
	return 95;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark -
#pragma mark Memory management

//TODO: release collection here if not top-level view
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	// Relinquish ownership of any cached data, images, etc that aren't in use.
}


@end

