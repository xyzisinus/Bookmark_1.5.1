//
//  TimeRibbonTimePicker.m
//  Bookmark
//
//  Created by Barry Ezell on 8/22/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import "TimeRibbonTimePicker.h"

@implementation TimeRibbonTimePicker

@synthesize picker, curSetting, parentController;

- (void)dealloc {
	[picker release];
	[curSetting release];
	[parentController release];
    [super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
        
    UIImageView *imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark_leather_2.png"]] autorelease];
    [self.view addSubview:imgView];
    [self.view sendSubviewToBack:imgView];
}

//set the picker from the current TimeRibbonSetting object
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
		
	NSString *scale = [curSetting timeScale];
	if (scale == @"Seconds") {
		[picker selectRow:0 inComponent:1 animated:NO];
		[picker selectRow:[curSetting seconds] -1 inComponent:0 animated:NO];
	} else if (scale == @"Minutes") {
		[picker selectRow:1 inComponent:1 animated:NO];
		[picker selectRow:[curSetting minutes] -1 inComponent:0 animated:NO];
	} else {
		[picker selectRow:2 inComponent:1 animated:NO];
		[picker selectRow:[curSetting hours] -1 inComponent:0 animated:NO];
	}
}

//update the current TimeRibbonSetting object before this view disappears
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	int val = [picker selectedRowInComponent:0] + 1;
	switch ([picker selectedRowInComponent:1]) {
		case 0:
			[curSetting setSeconds:val];
			break;
		case 1:
			[curSetting setMinutes:val];
			break;
		case 2:
			[curSetting setHours:val];
			break;
	}
	
	//notify parent to update
	[parentController updateSettings];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {	
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	if (component == 1) return 3;
	else return 90;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if (component == 0) {
		return [NSString stringWithFormat:@"%i",row + 1];
	} else {
		switch (row) {
			case 0:
				return @"Seconds";
				break;
			case 1:
				return @"Minutes";
				break;
			default:
				return @"Hours";
				break;
		}
	}
}

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
