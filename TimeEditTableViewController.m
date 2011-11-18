//
//  TimeEditTableViewController.m
//  Bookmark
//
//  Created by Barry Ezell on 10/10/11.
//  Copyright (c) 2011 Dockmarket LLC. All rights reserved.
//

#import "TimeEditTableViewController.h"
#import "DMTimeUtils.h"
#import "MasterMusicPlayer.h"
#import "Track.h"
#import "MPMediaItem+Track.h"
#import "CoreDataUtility.h"

@implementation TimeEditTableViewController

@synthesize bookmark, tableView, picker, toolbar;

- (void)dealloc {
    [tableView release]; tableView = nil;
    [bookmark release]; bookmark = nil;
    [picker release]; picker = nil;
    [toolbar release]; toolbar = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tableView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark_leather_2.png"]] autorelease];
    [self.view addSubview:imgView];
    [self.view sendSubviewToBack:imgView];   
        
    // Add the picker view
    self.picker = [[[UIPickerView alloc] initWithFrame:CGRectMake(10, 180.0, 300.0, 100.0)] autorelease];
    picker.showsSelectionIndicator = YES;
    picker.delegate = self;
    [self.view addSubview:picker];
       
    MPMediaItem *item = bookmark.track.mediaItem;
    duration = item.duration;
    seconds = (int) duration;
    hours = seconds / 3600;
	seconds -= (hours * 3600);
	minutes = seconds / 60;
	seconds -= (minutes * 60);
            
    isPlaying = [[MasterMusicPlayer instance] isPlaying];
    [self updateToolbar];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self populatePicker:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [CoreDataUtility save];    
}

- (void)populatePicker:(BOOL)animated {
    // Set the picker's hour, min, sec rows   
    NSDateComponents *comps = [DMTimeUtils dateComponents:[bookmark.startTime floatValue]];
    [picker selectRow:comps.hour inComponent:0 animated:animated];
    [picker selectRow:comps.minute inComponent:1 animated:animated];
    [picker selectRow:comps.second inComponent:2 animated:animated];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row == 0 ? 44.0 : 100.0);
}

- (CGFloat)tableView:(UITableView *)tv heightForHeaderInSection:(NSInteger)section {
    return (section == 0 ? 50.0 : 40.0);
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.detailTextLabel.text = [DMTimeUtils formatSeconds:[bookmark.startTime longValue]];
    cell.textLabel.text = @"Start";
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
}

#pragma mark - Picker delegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {    
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {         
    switch (component) {
        case 0:
            return hours + 1;
            break;        
        default:
            return 60;
    }
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    int val = (component == 0 ? row : row % 60);
    return [NSString stringWithFormat:@"%i",val];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    int hour = [pickerView selectedRowInComponent:0];
    int min = [pickerView selectedRowInComponent:1] % 60;
    int sec = [pickerView selectedRowInComponent:2] % 60;    
    long totalSeconds = sec + (min * 60) + (hour * 3600);
    
    BOOL reloadPicker = NO;
    if (totalSeconds > duration) {
        totalSeconds = duration - 1;        
        reloadPicker = YES;
    }
    
    bookmark.startTime = [NSNumber numberWithLong:totalSeconds];
    [tableView reloadData];
    
    if (reloadPicker) [self populatePicker:YES];
}

#pragma mark - Time control methods

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

- (void)updateToolbar {   
    UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                                target:nil 
                                                                                action:nil] autorelease];
    UIBarButtonSystemItem systemItem = (isPlaying ? UIBarButtonSystemItemPause : UIBarButtonSystemItemPlay);
    UIBarButtonItem *playPauseBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem 
                                                                                   target:self 
                                                                                   action:@selector(playStopButtonWasPressed:)] autorelease];
    
    [toolbar setItems:[NSArray arrayWithObjects:flexSpace, playPauseBtn, flexSpace,nil] 
             animated:NO];        
}

@end
