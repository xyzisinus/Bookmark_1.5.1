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
//  BookmarksViewController.m
//  AudiobooksPlus
//
//  Created by Barry Ezell on 5/24/09.
//

#import "BookmarksViewController.h"
#import "BookmarkAppDelegate.h"
#import "Bookmark.h"
#import "CoreDataUtility.h"
#import "DMTimeUtils.h"

@implementation BookmarksViewController

@synthesize player, selBackView, bookmarks, toolbar, tableView;

- (void)dealloc {
	//NSLog(@"BookmarksVC dealloc");	
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:MPMusicPlayerControllerPlaybackStateDidChangeNotification 
                                                  object:nil];
    
    [tableView release]; tableView = nil;
	[player release]; player = nil;
	[selBackView release]; selBackView = nil;
    [bookmarks release]; bookmarks = nil;
    [toolbar release]; toolbar = nil;
	
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.player = [MasterMusicPlayer instance];
				
	// Customize tableview 	
	//tableView.backgroundColor = BACKGROUND_COLOR;
    UIImageView *imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark_leather_2.png"]] autorelease];
    [self.view addSubview:imgView];
    [self.view sendSubviewToBack:imgView];
		
	// Image view for selected rows (orange border)
	self.selBackView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_74_highlight.png"]] autorelease];
			
	[self.navigationItem setTitle:@"Bookmarks"];
        
	[[NSNotificationCenter defaultCenter]
	 addObserver: self
	 selector:    @selector (playbackStateChanged:)
	 name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
	 object:      nil];
    
    isPlaying = [[MasterMusicPlayer instance] isPlaying];
    [self updateToolbar];
    
    lastSelectedIdx = -1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchBookmarks];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)fetchBookmarks {    
    self.bookmarks = [player currentCollection].bookmarks;
    [tableView reloadData]; 
}

#pragma mark Table view methods

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [bookmarks count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *CellIdentifier = @"BookmarkCell";
    
    BookmarkCell *cell = (BookmarkCell *) [tView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [self createNewBookmarkCellFromNib];				
	
		//set selected image view to use as the background (setting selected img in xib not working)
		[cell setSelectedBackgroundView:selBackView];
        cell.titleLabel.textColor = PRIMARY_TEXT_COLOR;
        cell.timeLabel.textColor = SECONDARY_TEXT_COLOR;
	}
	
	Bookmark *bookmark = [bookmarks objectAtIndex:indexPath.row];	  
	cell.titleLabel.text = bookmark.title;
	
	// Time label was revised to time + track
    MPMediaItem *item = [bookmark.track mediaItem];
    
    if (item == nil) {
        DLog(@"Nil item for bookmark: %@",bookmark.title);
        return cell;
    }
    
	NSString *startStr = [[NSString alloc] initWithFormat:@"%@ - %@", 
                          [DMTimeUtils formatSeconds:[bookmark.startTime longValue]],
						  item.title];
	cell.timeLabel.text = startStr;
	[startStr release];	
	
    return cell;
}

- (BookmarkCell *) createNewBookmarkCellFromNib {
	NSArray* nibContents = [[NSBundle mainBundle] loadNibNamed:@"BookmarkCell" owner:self options:nil];
	NSEnumerator* nibEnumerator = [nibContents objectEnumerator];
	BookmarkCell* bookmarkCell = nil;
	NSObject* nibItem = nil;
	while((nibItem = [nibEnumerator nextObject]) != nil) {
		if ([nibItem isKindOfClass: [BookmarkCell class]]) {
			bookmarkCell = (BookmarkCell *) nibItem;
		}
	}
	
	return bookmarkCell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
    [self playCellAtIndexPath:indexPath];
}

//load the detail of this bookmark
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	BookmarkViewController *bkmkView = [[BookmarkViewController alloc] initWithNibName:@"BookmarkViewController" bundle:nil];	
	Bookmark *b = [bookmarks objectAtIndex:indexPath.row];
	bkmkView.bookmark = b;
	[self.navigationController pushViewController:bkmkView animated:YES];
	[bkmkView release];	 
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {	
	return UITableViewCellEditingStyleDelete;
}

 // Support editing the table view.
- (void)tableView:(UITableView *)tView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		Bookmark *damned = [bookmarks objectAtIndex:indexPath.row];	
		[self deleteBookmark:damned];
		
		//note: method below will handle removal from UI
	} 	
}

//member of NSFetchedResultsControllerDelegate
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject 
	   atIndexPath:(NSIndexPath *)indexPath 
	 forChangeType:(NSFetchedResultsChangeType)type 
	  newIndexPath:(NSIndexPath *)newIndexPath {
	
	if (type == NSFetchedResultsChangeDelete) {
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];	
	} else if (type == NSFetchedResultsChangeUpdate) {
		[tableView reloadData];
	}
}

//this is abstracted b/c is used by self and by BookmarksEditViewController
- (void)deleteBookmark:(Bookmark *)damned {
    NSManagedObjectContext *context = [[CoreDataUtility sharedUtility] managedObjectContext];
    [context deleteObject:damned];
	
	NSError *error = nil;
	if (![context save:&error]) DLog(@"Bookmark delete error %@",[error localizedDescription]);
    else [self fetchBookmarks];
}

//after a delete, this will remove the BookmarksEditViewController and refresh the table
- (void)popEditController {
	[self.navigationController popViewControllerAnimated:YES];
	[tableView reloadData];
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Toolbar and playback methods

- (void)playCellAtIndexPath:(NSIndexPath *)indexPath {
    
	// Get the bookmark object, change track if necessary, then set the playback time from the bookmark
	Bookmark *bkmk = [bookmarks objectAtIndex:indexPath.row];
	[player playTrack:bkmk.track atTime:[bkmk.startTime longValue]];
	
	// Show the play image on this cell
	//BookmarkCell *cell = (BookmarkCell *) [tableView cellForRowAtIndexPath:indexPath];
	
    lastSelectedIdx = indexPath.row;
}

- (void)playbackStateChanged:(NSNotification *)notification {
    [self updateToolbar];
}

- (IBAction)prevButtonWasPressed:(id)sender {
    if (lastSelectedIdx > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastSelectedIdx-1 
                                                    inSection:0];
        [tableView selectRowAtIndexPath:indexPath 
                               animated:NO
                         scrollPosition:YES];
        [self playCellAtIndexPath:indexPath];
    }
}

- (IBAction)nextButtonWasPressed:(id)sender {
    if (lastSelectedIdx < [bookmarks count] - 1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastSelectedIdx+1 
                                                    inSection:0];
        [tableView selectRowAtIndexPath:indexPath 
                               animated:NO 
                         scrollPosition:YES];
        [self playCellAtIndexPath:indexPath];
    }
}

- (IBAction)playStopButtonWasPressed:(id)sender {
    [[MasterMusicPlayer instance] togglePlayPause];    
}

- (void)updateToolbar {
    isPlaying = [[MasterMusicPlayer instance] isPlaying];
    UIBarButtonItem *prevItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                                                 target:self 
                                                                                 action:@selector(prevButtonWasPressed:)] autorelease];
    UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                                target:nil 
                                                                                action:nil] autorelease];
    UIBarButtonSystemItem systemItem = (isPlaying ? UIBarButtonSystemItemPause : UIBarButtonSystemItemPlay);
    UIBarButtonItem *playPauseBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem 
                                                                                   target:self 
                                                                                   action:@selector(playStopButtonWasPressed:)] autorelease];
    UIBarButtonItem *nextItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                                                                target:self 
                                                                                action:@selector(nextButtonWasPressed:)] autorelease];
    
    [toolbar setItems:[NSArray arrayWithObjects:prevItem, flexSpace, playPauseBtn, flexSpace, nextItem, nil] 
             animated:NO];        
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

@end
