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
//  TimeRibbonTimePicker.m
//  Bookmark
//
//  Created by Barry Ezell on 8/22/10.
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
