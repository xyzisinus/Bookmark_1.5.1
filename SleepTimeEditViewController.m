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
//  SleepTimeEditViewController.m
//  Bookmark
//
//  Created by Barry Ezell on 11/10/11.
//

#import "SleepTimeEditViewController.h"

@implementation SleepTimeEditViewController

@synthesize picker, parentVC;

- (void)dealloc {
    [picker release]; picker = nil;
    [parentVC release]; parentVC = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Countdown Time";
        
    UIImageView *imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark_leather_2.png"]] autorelease];
    [self.view addSubview:imgView];
    [self.view sendSubviewToBack:imgView]; 
        
    // Add the picker view
    self.picker = [[[UIPickerView alloc] initWithFrame:CGRectMake(10, 70.0, 300.0, 100.0)] autorelease];
    picker.showsSelectionIndicator = YES;
    picker.delegate = self;
    [self.view addSubview:picker];    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self populatePicker];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    parentVC.totalSeconds = [self totalSeconds];
    parentVC.elapsedSeconds = 0;
}

- (void)setTotalSeconds:(int)seconds {
    hours = seconds / 3600;
	seconds -= (hours * 3600);
	minutes = seconds / 60;
}

- (int)totalSeconds {
    return (hours * 3600) + (minutes * 60);
}

- (void)populatePicker {
    [picker selectRow:hours inComponent:0 animated:NO];
    [picker selectRow:minutes inComponent:1 animated:NO];
}

#pragma mark - Picker delegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {    
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {         
    switch (component) {
        case 0:
            return 24;
            break;        
        default:
            return 60;
    }
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) {
        return [NSString stringWithFormat:@"%i %@",row,(component == 0 ? @"hr" : @"min")];
    } else {
        return [NSString stringWithFormat:@"%i",row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    hours = [pickerView selectedRowInComponent:0];
    minutes = [pickerView selectedRowInComponent:1]; 
}


@end
