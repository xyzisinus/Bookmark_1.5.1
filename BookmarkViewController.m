//
//  BookmarkViewController.m
//  Bookmark
//
//  Created by Barry Ezell on 10/5/11.
//  Copyright (c) 2011 Dockmarket LLC. All rights reserved.
//

#import "BookmarkViewController.h"
#import "DMTimeUtils.h"
#import "Track.h"
#import "MPMediaItem+Track.h"
#import "MasterMusicPlayer.h"
#import "SHK.h"
#import "SHKFacebook.h"
#import "SHKTwitter.h"
#import "CoreDataUtility.h"
#import "Reachability.h"

#ifdef __IPHONE_5_0 
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#endif

@implementation BookmarkViewController

@synthesize tableView, bookmark, curIdxPath, notesHeaderView, isNew, toolbar;

- (void)dealloc {
    [tableView release]; tableView = nil;
    [bookmark release]; bookmark = nil;
    [curIdxPath release]; curIdxPath = nil;
    [notesHeaderView release]; notesHeaderView = nil;
    [toolbar release]; toolbar = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tableView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark_leather_2.png"]] autorelease];
    [self.view addSubview:imgView];
    [self.view sendSubviewToBack:imgView];    
    
    // For notes header view
    UILabel *notesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 180.0, 30.0)];
    notesLabel.text = @"Notes";
    notesLabel.backgroundColor = [UIColor clearColor];
    notesLabel.textColor = [UIColor colorWithWhite:0.95 alpha:1.0];    
    
    self.notesHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 30.0)] autorelease];
    [notesHeaderView addSubview:notesLabel];
    [notesLabel release];
    
    // This is needed for EditableTextView to estimate sizes 
    [self.view addSubview:[EditableTableViewCell dummyTextView]];
        
    MasterMusicPlayer *mmp = [MasterMusicPlayer instance];
    isPlaying = mmp.isPlaying;
    [self updateToolbar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (isNew && editingTableViewCell != nil) {
        [editingTableViewCell.textView becomeFirstResponder];
    } else if (willReturnFromTimeEdit) {
        [tableView reloadData];
        willReturnFromTimeEdit = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [CoreDataUtility save];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - TableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return notesHeaderView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section == 0 ? 10.0 : 40.0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0 ? 3 : 1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && indexPath.section == 0) {
        if (editingTableViewCell != nil && curIdxPath != nil) {
            return [editingTableViewCell suggestedHeight];
        } else {
            float height = [EditableTableViewCell heightForText:(indexPath.row == 0 ? bookmark.title : bookmark.notes)];
            return height;
        }
    } else return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    NSString *cellIdentifier = (indexPath.section == 0 && indexPath.row == 0 ? @"PlaceholderCell" : @"StandardCell");
       
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        if (cellIdentifier == @"PlaceholderCell") {
            cell = [[[EditableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
            [(EditableTableViewCell *) cell setDelegate:self];
            editingTableViewCell = (EditableTableViewCell *) cell; // setting now so viewDidAppear can make this first responder immediately (if needed)
        } else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
            cell.textLabel.font = STANDARD_FONT_15;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 2 || indexPath.section == 1) cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Set cell texts
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            EditableTableViewCell *editCell = (EditableTableViewCell *)cell;
            editCell.placeholder = @"Title";
            editCell.textView.text = bookmark.title;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = bookmark.track.mediaItem.title;
        } else {
            cell.textLabel.text = [DMTimeUtils formatSeconds:[bookmark.startTime longValue]];
        }
    } else {
        cell.isAccessibilityElement = YES;
        cell.accessibilityLabel = @"Notes";
        cell.textLabel.text = bookmark.notes;
    }    
          
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 2) {
            TimeEditTableViewController *timeEditVC = [[TimeEditTableViewController alloc] initWithNibName:@"TimeEditTableViewController" bundle:nil];
            timeEditVC.bookmark = bookmark;
            [self.navigationController pushViewController:timeEditVC animated:YES];
            [timeEditVC release];
            willReturnFromTimeEdit = YES;
        } 
    } else {
        NotesViewController *notesVC = [[NotesViewController alloc] initWithNibName:@"NotesViewController" bundle:nil];
        notesVC.notes = bookmark.notes;
        notesVC.notesDelegate = self;
        [self.navigationController pushViewController:notesVC animated:YES];
        [notesVC release];
    }    
}

#pragma mark - NotesViewDelegate

- (void)notesViewReturningWithNotes:(NSString *)notes {
    bookmark.notes = notes;
    [tableView reloadData];
}

#pragma mark -
#pragma mark EditableTableViewCellDelegate

- (void)editableTableViewCellDidBeginEditing:(EditableTableViewCell *)editableTableViewCell {
    editingTableViewCell = editableTableViewCell;
    self.curIdxPath = [tableView indexPathForCell:editableTableViewCell];    
}

- (void)editableTableViewCellDidEndEditing:(EditableTableViewCell *)editableTableViewCell {
    bookmark.title = editableTableViewCell.textView.text;
    editingTableViewCell = nil;
    self.curIdxPath = nil;
}

- (void)editableTableViewCell:(EditableTableViewCell *)editableTableViewCell heightChangedTo:(CGFloat)newHeight {
    // Calling beginUpdates/endUpdates causes the table view to reload cell geometries
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - Toolbar methods

- (IBAction)playStopButtonWasPressed:(id)sender {
    if (isPlaying) {
        [[MasterMusicPlayer instance] togglePlayPause];
        isPlaying = NO;
    } else {
        [[MasterMusicPlayer instance] playTrack:bookmark.track atTime:[bookmark.startTime longValue]];
        isPlaying = YES;
    }  
    [self updateToolbar];
}

- (IBAction)actionButtonWasPressed:(id)sender {
   	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                       delegate:self 
                                              cancelButtonTitle:@"Cancel" 
                                         destructiveButtonTitle:nil 
                                              otherButtonTitles:@"Twitter", @"Facebook", nil];	
    
	[sheet setTag:0];
	[sheet showFromToolbar:self.navigationController.toolbar];
	[sheet release];
}

- (void)shareViaNativeTwitter:(NSString *)text {
#ifdef __IPHONE_4_0 
    // Set up the built-in twitter composition view controller.
    TWTweetComposeViewController *tweetViewController = [[[TWTweetComposeViewController alloc] init] autorelease];
    
    // Set the initial tweet text. See the framework for additional properties that can be set.
    [tweetViewController setInitialText:text];
    
    // Create the completion handler block.
    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        
        switch (result) {
            case TWTweetComposeViewControllerResultCancelled:
                // The cancel button was tapped.                
                break;
            case TWTweetComposeViewControllerResultDone:
                // The tweet was sent.
                break;
            default:
                break;
        }
        
        // Dismiss the tweet composition view controller.
        [self dismissModalViewControllerAnimated:YES];
    }];
    
    // Present the tweet composition view controller modally.
    [self presentModalViewController:tweetViewController animated:YES];   
#endif
}

- (IBAction)trashButtonWasPressed:(id)sender {
    UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:nil 
                                                    delegate:self 
                                           cancelButtonTitle:@"Cancel" 
                                      destructiveButtonTitle:@"Delete"
                                           otherButtonTitles:nil] autorelease];
    as.tag = 1;
    [as showFromToolbar:toolbar];    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 0) {
        MasterMusicPlayer *mmp = [MasterMusicPlayer instance];
        NSString *msg = [NSString stringWithFormat:@"\"%@\" at %@ in %@",
                         self.bookmark.title,
                         [DMTimeUtils formatSeconds:[self.bookmark.startTime longValue]],
                         mmp.currentCollection.title];
        
        if (buttonIndex == 0) { 
            float version = [[[UIDevice currentDevice] systemVersion] floatValue];
            if (version < 5.0) { 
                SHKItem *item = [SHKItem text:msg];
                if ([self reachable:@"twitter.com"]) {
                    [SHKTwitter shareItem:item];
                }
            } else {
                [self shareViaNativeTwitter:msg];
            }
        } else if (buttonIndex == 1) {
            SHKItem *item = [SHKItem text:msg];
            if ([self reachable:@"facebook.com"]) {
                [SHKFacebook shareItem:item];
            }
        } 
    } else {    
        if (buttonIndex == 0) [self deleteBookmark];
    }
}

- (void)deleteBookmark {
    NSManagedObjectContext *context = [[CoreDataUtility sharedUtility] managedObjectContext];
    [context deleteObject:bookmark];
	
	NSError *error = nil;
	if (![context save:&error]) DLog(@"Bookmark delete error %@",[error localizedDescription]);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateToolbar {
    UIBarButtonItem *actionItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
                                                                                 target:self 
                                                                                 action:@selector(actionButtonWasPressed:)] autorelease];
    UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                                target:nil 
                                                                                action:nil] autorelease];
    UIBarButtonSystemItem systemItem = (isPlaying ? UIBarButtonSystemItemPause : UIBarButtonSystemItemPlay);
    UIBarButtonItem *playPauseBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem 
                                                                                   target:self 
                                                                                   action:@selector(playStopButtonWasPressed:)] autorelease];
    UIBarButtonItem *trashItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash 
                                                                                target:self 
                                                                                action:@selector(trashButtonWasPressed:)] autorelease];
    
    [toolbar setItems:[NSArray arrayWithObjects:actionItem, flexSpace, playPauseBtn, flexSpace, trashItem, nil] 
             animated:NO];        
}

#pragma mark - Reachability methods

-(BOOL)reachable:(NSString *)hostName {
    Reachability *r = [Reachability reachabilityWithHostName:hostName];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == NotReachable) {
        NSString *msg = [NSString stringWithFormat:@"We can't seem to reach %@. Please try again later.",hostName];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" 
                                                        message:msg
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return NO;
    }
    return YES;
}


@end
