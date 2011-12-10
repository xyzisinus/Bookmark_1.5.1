//
//  WorkDetailViewController.m
//  Bookmark
//
//  Created by Barry Ezell on 2/13/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import "WorkDetailsViewController.h"
#import "MasterMusicPlayer.h"
#import "PlayerViewController.h"
#import "DMTimeUtils.h"

@implementation WorkDetailsViewController

@synthesize collection, selBackView;

- (void)dealloc {
	[collection release]; collection = nil;
	[selBackView release]; selBackView = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Table view background
	//tableView.backgroundColor = BACKGROUND_COLOR;
    UIImageView *imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark_leather_2.png"]] autorelease];
    [self.view addSubview:imgView];
    [self.view sendSubviewToBack:imgView]; 
    
    // Text color
    workTitleLabel.textColor = PRIMARY_TEXT_COLOR;
	
	// Setup the toolbar
	UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 40)];
	lbl.textColor = [UIColor whiteColor];
	lbl.backgroundColor = [UIColor clearColor];
	lbl.text = @"Mark all tracks:";
	UIBarButtonItem *labelItem = [[UIBarButtonItem alloc] initWithCustomView:lbl];
	
	UIBarButtonItem *completeButton = [[UIBarButtonItem alloc] initWithTitle:@"Complete" 
                                                                       style:UIBarButtonItemStyleBordered 
                                                                      target:self 
                                                                      action:@selector(markAllAsCompleteWasPressed)];
    
	UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithTitle:@"New" 
																	   style:UIBarButtonItemStyleBordered 
																	  target:self 
																	  action:@selector(markAllAsNewWasPressed)];
	
	[toolbar setItems:[NSArray arrayWithObjects:labelItem,completeButton,newButton,nil]];
	[lbl release];
	[labelItem release];
    [completeButton release];
	[newButton release];
	
	initialLoad = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if (initialLoad) {
		if (collection) {
			workTitleLabel.text = collection.title;
			trackCountLabel.text = [NSString stringWithFormat:@"%i Track%@",
									collection.count,
									((collection.count > 1) ? @"s" : @"")];
			authorLabel.text = collection.author;
		} else {
			workTitleLabel.text = @"";
		}
		initialLoad = NO;
		
	} else {
		//when coming back from the playerview, refresh details
		[tableView reloadData];
	}
}


- (void)markAllAsNewWasPressed {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Reset all track times to zero?"
													   delegate:self 
											  cancelButtonTitle:@"Cancel" 
										 destructiveButtonTitle:nil 
											  otherButtonTitles:@"Continue",nil];
	sheet.tag = 0;	
	[sheet showInView:self.view];
	[sheet release];
}

- (void)markAllAsCompleteWasPressed {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"This will set all tracks as completed"
													   delegate:self 
											  cancelButtonTitle:@"Cancel" 
										 destructiveButtonTitle:nil 
											  otherButtonTitles:@"Continue",nil];
	sheet.tag = 1;	
	[sheet showInView:self.view];
	[sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {    
    
    // Clear MMP's current collection if it's also this controller's collection.
    MasterMusicPlayer *mmp = [MasterMusicPlayer instance];
    if (mmp.currentCollection != nil && mmp.currentCollection.persistentId == collection.persistentId) {
        if (mmp.playerController.playbackState == MPMusicPlaybackStatePlaying) {
            [mmp togglePlayPause];
        }
        [mmp setCollectionForColdPlayback:nil];
        mmp.lastPlayedItem = nil;
    }
    
	if (actionSheet.tag == 0 && buttonIndex == 0) {
        [collection updateAsNew];
		[tableView reloadData];
	} else if (actionSheet.tag == 1 && buttonIndex == 0) {
		[collection updateAsComplete];
		[tableView reloadData];
	}    
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return collection.count;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85.0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MPMediaItem *item = [[collection items] objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"WorkDetailCell";
    
    WorkDetailCell *cell = (WorkDetailCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewWorkDetailCellFromNib];
		
		if (selBackView) {
			//set selected image view to use as the background (setting selected img in xib not working)
			[cell setSelectedBackgroundView:selBackView];
		}
    }
    
    cell.progressPie.pieBackgroundColor = [UIColor clearColor];
    cell.progressPie.pieBorderColor = SECONDARY_TEXT_COLOR;
    cell.progressPie.pieFillColor = SECONDARY_TEXT_COLOR;
    cell.titleLabel.textColor = PRIMARY_TEXT_COLOR;
    cell.timeLabel.textColor = SECONDARY_TEXT_COLOR;
    cell.dateLabel.textColor = SECONDARY_TEXT_COLOR;

	cell.titleLabel.text = item.title;
    cell.timeLabel.text = [DMTimeUtils formatSeconds:item.duration];
    
    if (item.isPodcast == YES) {
        NSDate *date = item.releaseDate;
        if (date != nil) {
            cell.dateLabel.text = [NSDateFormatter localizedStringFromDate:item.releaseDate
                                                                 dateStyle:NSDateFormatterMediumStyle 
                                                                 timeStyle:NSDateFormatterNoStyle]; 
        }
    }
            
	cell.progressPie.progress = item.percentComplete;
		
    return cell;
}

- (WorkDetailCell *) createNewWorkDetailCellFromNib {
	NSArray* nibContents = [[NSBundle mainBundle] loadNibNamed:@"WorkDetailCell" owner:self options:nil];
	NSEnumerator* nibEnumerator = [nibContents objectEnumerator];
	WorkDetailCell* cell = nil;
	NSObject* nibItem = nil;
	while((nibItem = [nibEnumerator nextObject]) != nil) {
		if ([nibItem isKindOfClass: [WorkDetailCell class]]) {
			cell = (WorkDetailCell *) nibItem;
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	MasterMusicPlayer *player = [MasterMusicPlayer instance];
	[player setCollectionForPlayback:collection 
                            withItem:[[collection items] objectAtIndex:indexPath.row]];
								 	
    PlayerViewController *pvc = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
	[self.navigationController pushViewController:pvc animated:YES];
	[pvc release];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


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

@end

