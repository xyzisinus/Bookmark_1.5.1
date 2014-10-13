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
//  SoundsViewController.m
//  Bookmark
//
//  Created by Barry Ezell on 11/8/11.
//

#import "SoundsViewController.h"
#import "MasterMusicPlayer.h"

@implementation SoundsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self updateDefaults];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {    
    switch (section) {
        case 0:
            return @"Click";                
        case 1:
            return @"Chime";               
        case 2:
            return @"Bell";  
        default:
            return @"";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"For time changes via the Time Ribbon";                
        case 1:
            return @"For quick bookmarks and the sleep timer";               
        case 2:
            return @"For 1 min. sleep timer warning";  
        default:
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"none"] autorelease];
    if (indexPath.row == 0) {
        
        UISlider *slider = [[[UISlider alloc] initWithFrame:CGRectMake(100,10,160,23)] autorelease];
        slider.minimumValue = 0.0;
        slider.maximumValue = 1.0;
        [cell addSubview:slider];
        cell.accessoryView = slider;
        cell.textLabel.text = @"Volume";
        
        float val = 0.0;
        switch (indexPath.section) {
            case 0:
                val = [[[DMUserDefaults sharedInstance] objectForKey:CLICK_VOL] floatValue];
                break;
                
            case 1:
                val = [[[DMUserDefaults sharedInstance] objectForKey:CHIME_VOL] floatValue];
                break;
               
            case 2:
                val = [[[DMUserDefaults sharedInstance] objectForKey:BELL_VOL] floatValue];
                break;
        }
        slider.value = val;
        sliders[indexPath.section] = slider;
        
    } else if (indexPath.row == 1) {
        
        UISwitch *aSwitch = [[[UISwitch alloc] initWithFrame:CGRectMake(100, 10, 50, 30)] autorelease];
        cell.textLabel.text = @"Vibrate";
        [cell addSubview:aSwitch];
        cell.accessoryView = aSwitch;
        
        BOOL isOn = NO;
        switch (indexPath.section) {
            case 0:
                isOn = [[[DMUserDefaults sharedInstance] objectForKey:CLICK_BUZZ] boolValue];
                break;
            
            case 1:
                isOn = [[[DMUserDefaults sharedInstance] objectForKey:CHIME_BUZZ] boolValue];
                break;
               
            case 2:
                isOn = [[[DMUserDefaults sharedInstance] objectForKey:BELL_BUZZ] boolValue];
                break;                
        }
        
        [aSwitch setOn:isOn animated:NO];
        switches[indexPath.section] = aSwitch;
        
    } else {
        cell.textLabel.text = @"Play";
    }
    
    return cell;
}

- (void)updateDefaults {
    DMUserDefaults *def = [DMUserDefaults sharedInstance];
    [def setObject:[NSNumber numberWithFloat:sliders[0].value] forKey:CLICK_VOL];
    [def setObject:[NSNumber numberWithFloat:sliders[1].value] forKey:CHIME_VOL];
    [def setObject:[NSNumber numberWithFloat:sliders[2].value] forKey:BELL_VOL];
    [def setObject:[NSNumber numberWithBool:switches[0].isOn] forKey:CLICK_BUZZ];
    [def setObject:[NSNumber numberWithBool:switches[1].isOn] forKey:CHIME_BUZZ];
    [def setObject:[NSNumber numberWithBool:switches[2].isOn] forKey:BELL_BUZZ];
    
    MasterMusicPlayer *mmp = [MasterMusicPlayer instance];
    [mmp setPlayerVolumes];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        [self updateDefaults];
        
        MasterMusicPlayer *mmp = [MasterMusicPlayer instance];
        switch (indexPath.section) {
            case 0:
                [mmp click];
                break;
                
            case 1:
                [mmp chime];
                break;
                
            case 2:
                [mmp bell];
                break;
        }
    }
}

@end
