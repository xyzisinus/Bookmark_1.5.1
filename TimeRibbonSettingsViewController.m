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
//  TimeRibbonSettingsViewController.m
//  Bookmark
//
//  Created by Barry Ezell on 8/20/10.
//

#import "TimeRibbonSettingsViewController.h"
#import "TimeRibbonTimePicker.h"

@implementation TimeRibbonSettingsViewController

@synthesize tableView, timeRibbon, trSettings;

- (void)dealloc {
	[timeRibbon release];
	[tableView release];
	[trSettings release];
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if ([self.tableView respondsToSelector:@selector(backgroundView)]) {
		self.tableView.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark_leather_2.png"]] autorelease];
	}
	
	self.timeRibbon = [[[TimeRibbonView alloc] initWithFrame:CGRectMake(0, 75, 320, 49)] autorelease];
	
	self.trSettings = [TimeRibbonSetting settings];
}

// Persist settings changes and refresh the relevant views
- (void)updateSettings {
	self.trSettings = [TimeRibbonSetting persistArray:self.trSettings];
	[self.tableView reloadData];
	self.timeRibbon = [[[TimeRibbonView alloc] initWithFrame:CGRectMake(0, 75, 320, 49)] autorelease];
}

- (IBAction)restoreDefaultsButtonWasPressed {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Restore default times?"
										delegate:self 
							   cancelButtonTitle:@"No" 
						  destructiveButtonTitle:nil 
							   otherButtonTitles:@"Yes",nil];
	[sheet showInView:self.view];
	[sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		
		//remove stored settings - when [TimeRibbonSetting settings] is called, will create defaults
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		
		for (int i=0; i<5; i++) {
			if ([prefs valueForKey:[NSString stringWithFormat:@"trs_%i_desc",i]]) {
				[prefs removeObjectForKey:[NSString stringWithFormat:@"trs_%i_desc",i]];
			}
			
			if ([prefs integerForKey:[NSString stringWithFormat:@"trs_%i_sec",i]]) {
				[prefs removeObjectForKey:[NSString stringWithFormat:@"trs_%i_sec",i]];
			}
		}
		
		[prefs synchronize];
		
		self.trSettings = [TimeRibbonSetting settings];
		[self.tableView reloadData];
		self.timeRibbon = [[TimeRibbonView alloc] initWithFrame:CGRectMake(0, 75, 320, 49)];
	}
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [trSettings count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"trCell"];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"trCell"] autorelease];
	}
	
	TimeRibbonSetting *curSetting = (TimeRibbonSetting *) [self.trSettings objectAtIndex:indexPath.row];	
	cell.textLabel.text = [curSetting longDescription];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TimeRibbonTimePicker *picker = [[TimeRibbonTimePicker alloc] initWithNibName:@"TimeRibbonTimePicker" bundle:nil];
	picker.curSetting = [self.trSettings objectAtIndex:indexPath.row];
	picker.parentController = self;
	[self.navigationController pushViewController:picker animated:YES];
	[picker release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 170;
}

//Create large UIView as the table header with a TimeRibbon and instructions
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *aView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 325, 245)] autorelease];
	aView.backgroundColor = [UIColor clearColor];
	[aView addSubview:self.timeRibbon];	
	
	UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 132, 290, 40)];
	aLabel.font = [UIFont fontWithName:@"Trebuchet MS" size:13];
	aLabel.textColor = [UIColor whiteColor];
	aLabel.backgroundColor = [UIColor clearColor];
	aLabel.text = @"Customize Time Ribbon times below:";
	[aView addSubview:aLabel];
	[aLabel release];
	
	return aView;
}


#pragma mark -
#pragma mark Cleanup methods

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


@end
